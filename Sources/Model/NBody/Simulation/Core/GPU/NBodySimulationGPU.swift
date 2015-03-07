//
//  NBodySimulationGPU.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
     File: NBodySimulationGPU.h
     File: NBodySimulationGPU.mm
 Abstract:
 Utility class for managing gpu bound computes for n-body simulation.

  Version: 3.3

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2014 Apple Inc. All Rights Reserved.

 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation {
    public class GPU: Base {
        private override init(nbodies: Int, params: NBody.Simulation.Params) {
            super.init(nbodies: nbodies, params: params)
        }
        
        private var mbTerminated: Bool = false
        private var mpHostPosition: UnsafeMutablePointer<GLfloat> = nil
        private var mpHostVelocity: UnsafeMutablePointer<GLfloat> = nil
        private var mnReadIndex: Int = 0
        private var mnWriteIndex: Int = 0
        private var mnWorkItemX: GLuint = 0
        private var mnDeviceIndex: Int = 0
        private var mpContext: cl_context = nil
        private var mpProgram: cl_program = nil
        private var mpKernel: cl_kernel = nil
        private var mpDevice: [cl_device_id] = [nil, nil]
        private var mpQueue: [cl_command_queue] = [nil, nil]
        private var mpDevicePosition: [cl_mem] = [nil, nil]
        private var mpDeviceVelocity: [cl_mem] = [nil, nil]
        private var mpBodyRangeParams: cl_mem = nil
        
        //MARK: -
        //MARK: Private - Constants
        
        private let kWorkItemsX: GLuint = 256
        private let kWorkItemsY: GLuint = 1
        
        private let kKernelParams = 11
        private let kSizeCLMem    = size_t(strideof(cl_mem))
        
        private var kIntegrateSystem: String = "IntegrateSystem"
        
        //MARK: -
        //MARK: Private - Utilities
        
        private func readBuffer(compute_commands: cl_command_queue,
            _ host_data: UnsafeMutablePointer<GLfloat>,
            _ device_data: cl_mem,
            _ size: size_t,
            _ offset: size_t)
            -> cl_int {
                return clEnqueueReadBuffer(compute_commands,
                    device_data,
                    CL_TRUE.ui,
                    offset,
                    size,
                    host_data,
                    0,
                    nil,
                    nil)
        }
        
        private func writeBuffer(compute_commands: cl_command_queue,
            _ host_data: UnsafePointer<GLfloat>,
            _ device_data: cl_mem,
            _ size: size_t)
            -> cl_int {
                return clEnqueueWriteBuffer(compute_commands,
                    device_data,
                    CL_TRUE.ui,
                    0,
                    size,
                    host_data,
                    0,
                    nil,
                    nil)
        }
        
        private func bind() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                
                let pValues: [UnsafePointer<Void>] = [
                    withUnsafePointer(&mpDevicePosition[mnWriteIndex]){UnsafePointer($0)},
                    withUnsafePointer(&mpDeviceVelocity[mnWriteIndex]){UnsafePointer($0)},
                    withUnsafePointer(&mpDevicePosition[mnReadIndex]){UnsafePointer($0)},
                    withUnsafePointer(&mpDeviceVelocity[mnReadIndex]){UnsafePointer($0)},
                    withUnsafePointer(&m_ActiveParams.mnTimeStamp){UnsafePointer($0)},
                    withUnsafePointer(&m_ActiveParams.mnDamping){UnsafePointer($0)},
                    withUnsafePointer(&m_ActiveParams.mnSoftening){UnsafePointer($0)},
                    withUnsafePointer(&mnBodyCount){UnsafePointer($0)},   //### taking lower 4 bytes
                    withUnsafePointer(&mnMinIndex){UnsafePointer($0)},   //### taking lower 4 bytes
                    withUnsafePointer(&mnMaxIndex){UnsafePointer($0)},   //### taking lower 4 bytes
                    nil,
                ]
                
                let sizes: [size_t] = [
                    kSizeCLMem,
                    kSizeCLMem,
                    kSizeCLMem,
                    kSizeCLMem,
                    mnSamples,
                    mnSamples,
                    mnSamples,
                    GLM.Size.kInt,   //### taking lower 4 bytes
                    GLM.Size.kInt,   //### taking lower 4 bytes
                    GLM.Size.kInt,   //### taking lower 4 bytes
                    4 * mnSamples * mnWorkItemX.l * kWorkItemsY.l,
                ]
                
                for i in 0..<kKernelParams {
                    err = clSetKernelArg(mpKernel, i.ui, sizes[i], pValues[i])
                    
                    if err != CL_SUCCESS {
                        return err
                    }
                }
            }
            
            return err
        }
        
        private func setup(options: String) -> cl_int {
            var stream_flags: cl_mem_flags = CL_MEM_READ_WRITE.ull
            
            var i = mnDeviceIndex
            
            var err = CL_SUCCESS
            
            err = clGetDeviceIDs(nil, CL_DEVICE_TYPE_GPU.ull, 4, &mpDevice, &mnDevices)
            
            if err != CL_SUCCESS {
                return err
            }
            
            println(">> N-body Simulation: Found \(mnDevices) devices...")
            
            var nSize: size_t = 0
            
            var name: [CChar] = Array(count: 1024, repeatedValue: 0)
            var vendor: [CChar] = Array(count: 1024, repeatedValue: 0)
            
            clGetDeviceInfo(mpDevice[i],
                CL_DEVICE_NAME.ui,
                size_t(name.count),
                &name,
                &nSize)
            
            clGetDeviceInfo(mpDevice[i],
                CL_DEVICE_VENDOR.ui,
                size_t(vendor.count),
                &vendor,
                &nSize)
            
            m_DeviceName = String(name)
            
            println(">> N-body Simulation: Using Device[\(i)] = \"\(m_DeviceName)\"")
            mpDevice[0] = mpDevice[i]
            
            mpContext = clCreateContext(nil,
                1,
                &mpDevice[0],
                nil,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return err
            }
            
            mpQueue[0] = clCreateCommandQueue(mpContext,
                mpDevice[0],
                0,
                &err)
            
            if err != CL_SUCCESS {
                return err
            }
            
            let pStream = CF.IFStream(name: "nbody_gpu", ext: "ocl")!
            
            if !pStream.isValid {
                return CL_INVALID_VALUE
            }
            
            var pBuffer = UnsafePointer<CChar>(pStream.buffer)
            
            mpProgram = clCreateProgramWithSource(mpContext,
                1,
                &pBuffer,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return err
            }
            
            err = clBuildProgram(mpProgram,
                mnDeviceCount,
                mpDevice,
                options,
                nil,
                nil)
            
            if err != CL_SUCCESS {
                var length: size_t = 0
                
                var info_log: [CChar] = Array(count: 2000, repeatedValue: 0)
                
                for i in 0..<mnDeviceCount.l {
                    clGetProgramBuildInfo(mpProgram,
                        mpDevice[i],
                        CL_PROGRAM_BUILD_LOG.ui,
                        2000,
                        &info_log,
                        &length)
                    
                    NSLog(">> N-body Simulation: Build Log for Device [\(i)]:")
                    NSLog(String(info_log))
                }
                
                return err
            }
            
            mpKernel = clCreateKernel(mpProgram,
                kIntegrateSystem,
                &err)
            
            if err != CL_SUCCESS {
                return err
            }
            
            var localSize: size_t = 0
            
            for i in 0..<mnDeviceCount.l {
                err = clGetKernelWorkGroupInfo(mpKernel,
                    mpDevice[i],
                    CL_KERNEL_WORK_GROUP_SIZE.ui,
                    GLM.Size.kULong,
                    &localSize,
                    nil)
                if err != CL_SUCCESS {
                    return err
                }
                
                mnWorkItemX = (mnWorkItemX <= localSize.ui) ? mnWorkItemX : localSize.ui
            }
            
            let isInvalidWorkDim = (mnBodyCount.ui % mnWorkItemX) != 0
            
            if isInvalidWorkDim {
                NSLog(">> N-body Simulation: Number of particlces [\(mnBodyCount)] must be evenly divisble work group size [\(mnWorkItemX)] for device!")
                return CL_INVALID_WORK_DIMENSION
            }
            
            let size: size_t = 4 * GLM.Size.kFloat * mnBodyCount
            
            mpDevicePosition[0] = clCreateBuffer(mpContext,
                stream_flags,
                size,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -100
            }
            
            mpDevicePosition[1] = clCreateBuffer(mpContext,
                stream_flags,
                size,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -101
            }
            
            mpDeviceVelocity[0] = clCreateBuffer(mpContext,
                CL_MEM_READ_WRITE.ull,
                size,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -102
            }
            
            mpDeviceVelocity[1] = clCreateBuffer(mpContext,
                CL_MEM_READ_WRITE.ull,
                size,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -103
            }
            
            mpBodyRangeParams = clCreateBuffer(mpContext,
                CL_MEM_READ_WRITE.ull,
                GLM.Size.kInt * 3,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -104
            }
            
            err = bind()
            
            return err
        }
        
        private func execute() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                
                let local_dim: [size_t] = [
                    mnWorkItemX.l,
                    1,
                ]
                
                let global_dim: [size_t] = [
                    mnMaxIndex - mnMinIndex,
                    1
                ]
                
                let values: [UnsafePointer<Void>] = [
                    withUnsafePointer(&mpDevicePosition[mnWriteIndex]) {UnsafePointer($0)},
                    withUnsafePointer(&mpDeviceVelocity[mnWriteIndex]) {UnsafePointer($0)},
                    withUnsafePointer(&mpDevicePosition[mnReadIndex]) {UnsafePointer($0)},
                    withUnsafePointer(&mpDeviceVelocity[mnReadIndex]) {UnsafePointer($0)},
                ]
                
                let sizes: [size_t] = [kSizeCLMem, kSizeCLMem, kSizeCLMem, kSizeCLMem]
                
                let indices: [GLuint] = [0, 1, 2, 3]
                
                for i in 0..<4 {
                    err = clSetKernelArg(mpKernel, indices[i], sizes[i], values[i])
                    
                    if err != CL_SUCCESS {
                        return err
                    }
                }
                
                for i in 0..<mnDeviceCount.l {
                    if mpQueue[i] != nil {
                        err = clEnqueueNDRangeKernel(mpQueue[i],
                            mpKernel,
                            2,
                            nil,
                            global_dim,
                            local_dim,
                            0,
                            nil,
                            nil)
                        
                        if err != CL_SUCCESS {
                            return err
                        }
                    }
                }
            }
            
            return err
        }
        
        private func restart() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                let rand = NBody.Simulation.Data.Random(nbodies: mnBodyCount, params: m_ActiveParams)
                
                if rand>>>(mpHostPosition, mpHostVelocity) {
                    let size: size_t = 4 * GLM.Size.kFloat * mnBodyCount
                    
                    for i in 0..<mnDeviceCount.l {
                        if mpQueue[i] != nil {
                            err = clEnqueueWriteBuffer(mpQueue[i],
                                mpDevicePosition[mnReadIndex],
                                CL_TRUE.ui,
                                0,
                                size,
                                mpHostPosition,
                                0,
                                nil,
                                nil)
                            
                            if err != CL_SUCCESS {
                                return err
                            }
                            
                            err = clEnqueueWriteBuffer(mpQueue[i],
                                mpDeviceVelocity[mnReadIndex],
                                CL_TRUE.ui,
                                0,
                                size,
                                mpHostVelocity,
                                0,
                                nil,
                                nil)
                            
                            if err != CL_SUCCESS {
                                return err
                            }
                        }
                    }
                    
                    err = bind()
                }
            }
            
            return err
        }
        
        //MARK: -
        //MARK: Public - Constructor
        
        public convenience init(nbodies: Int, params: NBody.Simulation.Params, index: Int) {
            self.init(nbodies: nbodies, params: params)
            mnDeviceCount = 1
            mnDeviceIndex = index
            mnWorkItemX   = kWorkItemsX
            mbTerminated  = false
            mnReadIndex   = 0
            mnWriteIndex  = 0
            
            mpHostPosition = nil
            mpHostVelocity = nil
            
            mpContext  = nil
            mpProgram  = nil
            mpKernel   = nil
            mpBodyRangeParams = nil
            
            mpDevice[0] = nil
            mpDevice[1] = nil
            
            mpQueue[0] = nil
            mpQueue[1] = nil
            
            mpDevicePosition[0] = nil
            mpDevicePosition[1] = nil
            
            mpDeviceVelocity[0] = nil
            mpDeviceVelocity[1] = nil
        }
        
        //MARK: -
        //MARK: Public - Destructor
        
        private func destruct() {
            stop()
            
            terminate()
        }
        
        //MARK: -
        //MARK: Public - Utilities
        
        public override func initialize(options: String) {
            if !mbTerminated {
                mnReadIndex  = 0//        mnWriteIndex = 1;
                mnWriteIndex = 1
                
                mpHostPosition = UnsafeMutablePointer<GLfloat>.alloc(mnLength)
                mpHostVelocity = UnsafeMutablePointer<GLfloat>.alloc(mnLength)
                
                let err = setup(options)
                
                mbAcquired = err == CL_SUCCESS
                
                if !mbAcquired {
                    NSLog(">> N-body Simulation[\(err)]: Failed setting up gpu compute device!")
                }
                signalAcquisition()
            }
        }
        
        public override func reset() -> Int {
            var err = restart()
            
            if err != CL_SUCCESS {
                NSLog(">> N-body Simulation[\(err)]: Failed resetting devices!")
            }
            
            return err.l
        }
        
        public override func step() {
            if !isPaused || !isStopped {
                var err = execute()
                
                if err != CL_SUCCESS {
                    NSLog(">> N-body Simulation[\(err)]: Failed executing gpu bound kernel!")
                }
                
                if mbIsUpdated {
                    for i in 0..<mnDeviceCount.l {
                        readBuffer(mpQueue[i],
                            mpHostPosition,
                            mpDevicePosition[mnWriteIndex],
                            mnSize,
                            0)
                        
                        setData(mpHostPosition)
                    }
                }
                
                swap(&mnReadIndex, &mnWriteIndex)
            }
        }
        
        public override func terminate() {
            if !mbTerminated {
                for i in 0..<mnDeviceCount.l {
                    if mpQueue[i] != nil {
                        clFinish(mpQueue[i])
                    }
                }
                
                if mpDevicePosition[0] != nil {
                    clReleaseMemObject(mpDevicePosition[0])
                    
                    mpDevicePosition[0] = nil
                }
                
                if mpDevicePosition[1] != nil {
                    clReleaseMemObject(mpDevicePosition[1])
                    
                    mpDevicePosition[1] = nil
                }
                
                if mpDeviceVelocity[0] != nil {
                    clReleaseMemObject(mpDeviceVelocity[0])
                    
                    mpDeviceVelocity[0] = nil
                }
                
                if mpDeviceVelocity[1] != nil {
                    clReleaseMemObject(mpDeviceVelocity[1])
                    
                    mpDeviceVelocity[1] = nil
                }
                
                if mpBodyRangeParams != nil {
                    clReleaseMemObject(mpBodyRangeParams)
                    
                    mpBodyRangeParams = nil
                }
                
                if mpKernel != nil {
                    clReleaseKernel(mpKernel)
                    
                    mpKernel = nil
                }
                
                if mpProgram != nil {
                    clReleaseProgram(mpProgram)
                    
                    mpProgram = nil
                }
                
                if mpContext != nil {
                    clReleaseContext(mpContext)
                    
                    mpContext = nil
                }
                
                for i in 0..<mnDeviceCount.l {
                    if mpQueue[i] != nil {
                        clReleaseCommandQueue(mpQueue[i])
                        
                        mpQueue[i] = nil
                    }
                }
                
                if mpHostPosition != nil {
                    mpHostPosition.dealloc(mnLength)
                    
                    mpHostPosition = nil
                }
                
                if mpHostVelocity != nil {
                    mpHostVelocity.dealloc(mnLength)
                    
                    mpHostVelocity = nil
                }
                
                mbTerminated = true
            }
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        public override func positionInRange(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                let data_offset_in_floats = mnMinIndex * 4
                let data_offset_bytes: size_t     = data_offset_in_floats * mnSamples
                let data_size_in_floats   = (mnMaxIndex - mnMinIndex) * 4
                let data_size_bytes       = data_size_in_floats * mnSamples
                
                let host_data = pDst.advancedBy(data_offset_in_floats)
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        host_data,
                        mpDevicePosition[mnReadIndex],
                        data_size_bytes,
                        data_offset_bytes)
                    if err != CL_SUCCESS {
                        return err.l
                    }
                }
            }
            
            return err.l
        }
        
        public override func position(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        pDst,
                        mpDevicePosition[mnReadIndex],
                        mnSize,
                        0)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err.l
        }
        
        public override func setPosition(pSrc: UnsafePointer<GLfloat>) -> Int {
            var err = CL_INVALID_VALUE
            
            if pSrc != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = writeBuffer(mpQueue[i],
                        pSrc,
                        mpDevicePosition[mnReadIndex],
                        mnSize)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err.l
        }
        
        public override func velocity(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        pDst,
                        mpDeviceVelocity[mnReadIndex],
                        mnSize,
                        0)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err.l
        }
        
        public override func setVelocity(pSrc: UnsafePointer<GLfloat>) -> Int {
            var err = CL_INVALID_VALUE
            
            if pSrc != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = writeBuffer(mpQueue[i],
                        pSrc,
                        mpDeviceVelocity[mnReadIndex],
                        mnSize)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err.l
        }
    }
}