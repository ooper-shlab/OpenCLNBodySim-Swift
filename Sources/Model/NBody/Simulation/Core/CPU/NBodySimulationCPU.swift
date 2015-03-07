//
//  NBodySimulationCPU.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodySimulationCPU.h
     File: NBodySimulationCPU.mm
 Abstract:
 Utility class for managing cpu bound computes for n-body simulation.

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
    
    public class CPU: Base {
        private override init(nbodies: Int, params: NBody.Simulation.Params) {
            super.init(nbodies: nbodies, params: params)
        }
        
        deinit {destruct()}
        
        private var mbVectorized: Bool = false
        private var mbThreaded: Bool = false
        private var mbTerminated: Bool = false
        private var mnUnits: Int = 0
        private var mpDevice: cl_device_id = nil
        private var mpQueue: cl_command_queue = nil
        private var mpContext: cl_context = nil
        private var mpProgram: cl_program = nil
        private var mpKernel: cl_kernel = nil
        private var mpData: Data.Mediator!
        
        //MARK: -
        //MARK: Private - Utilities
        
        private func bind() -> cl_int {
            var err = mpData.bind(mpKernel).i
            
            if err == CL_SUCCESS {
                
                var nWorkGroupCount: size_t = (mnMaxIndex - mnMinIndex) / mnUnits
                var nTimeStamp: GLfloat      = m_ActiveParams.mnTimeStamp
                
                var values: [UnsafePointer<Void>] = [
                    withUnsafePointer(&nTimeStamp) {UnsafePointer($0)},
                    withUnsafePointer(&m_ActiveParams.mnDamping) {UnsafePointer($0)},
                    withUnsafePointer(&m_ActiveParams.mnSoftening) {UnsafePointer($0)},
                    withUnsafePointer(&mnBodyCount) {UnsafePointer($0)},    //###
                    withUnsafePointer(&nWorkGroupCount) {UnsafePointer($0)},    //###
                    withUnsafePointer(&mnMinIndex) {UnsafePointer($0)}, //###
                ]
                
                var sizes: [size_t] = [
                    mnSamples,
                    mnSamples,
                    mnSamples,
                    GLM.Size.kInt,   //### sending lower 4 byte?
                    GLM.Size.kInt,   //### sending lower 4 byte?
                    GLM.Size.kInt,   //### sending lower 4 byte?
                ]
                
                var indices: [cl_uint] = [14, 15, 16, 17, 18, 19]
                
                for i in 0..<6 {
                    err = clSetKernelArg(mpKernel, indices[i], sizes[i], values[i])
                    
                    if err != CL_SUCCESS {
                        return err
                    }
                }
            }
            
            return err
        }
        
        private func setup(options: String,
            _ vectorized: Bool,
            _ threaded: Bool) -> cl_int
        {
            var err = CL_INVALID_VALUE
            
            let pStream = CF.IFStream(name: "nbody_cpu", ext: "ocl")!
            
            if pStream.isValid {
                err = clGetDeviceIDs(nil,
                    CL_DEVICE_TYPE_CPU.ull,
                    1,
                    &mpDevice,
                    &mnDeviceCount)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                mpContext = clCreateContext(nil,
                    mnDeviceCount,
                    &mpDevice,
                    nil,
                    nil,
                    &err)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                mpQueue = clCreateCommandQueue(mpContext,
                    mpDevice,
                    0,
                    &err)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                var returned_size: size_t = 0
                var compute_units: cl_uint = 0
                
                clGetDeviceInfo(mpDevice,
                    CL_DEVICE_MAX_COMPUTE_UNITS.ui,
                    GLM.Size.kUInt,
                    &compute_units,
                    &returned_size)
                
                mnUnits = threaded ? compute_units.l : 1
                
                var pBuffer = UnsafePointer<Int8>(pStream.buffer)
                
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
                    &mpDevice,
                    options,
                    nil,
                    nil)
                
                if err != CL_SUCCESS {
                    var length: size_t = 0
                    
                    var info_log: [CChar] = Array(count: 2000, repeatedValue: 0)
                    
                    clGetProgramBuildInfo(mpProgram,
                        mpDevice,
                        CL_PROGRAM_BUILD_LOG.ui,
                        2000,
                        &info_log,
                        &length)
                    
                    NSLog(">> N-body Simulation:\n%@", String(info_log))
                    
                    return err
                }
                
                let kernelName = vectorized ? "IntegrateSystemVectorized" : "IntegrateSystemNonVectorized"
                mpKernel = clCreateKernel(mpProgram,
                    kernelName,
                    &err)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                err = mpData.acquire(mpContext).i
                
                if err != CL_SUCCESS {
                    return err
                }
                
                err = bind()
                
            }
            
            return err
        }
        
        private func execute() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                mpData.update(mpKernel)
                
                var nWorkGroupCount: size_t = (mnMaxIndex - mnMinIndex) / mnUnits
                
                var values: [UnsafeMutablePointer<Void>] = [
                    withUnsafeMutablePointer(&nWorkGroupCount) {UnsafeMutablePointer($0)},
                    withUnsafeMutablePointer(&mnMinIndex) {UnsafeMutablePointer($0)},
                ]
                
                var sizes: [size_t] = [
                    GLM.Size.kInt,   //###
                    GLM.Size.kInt,   //###
                ]
                
                var indices: [cl_uint] = [18, 19]
                
                for i in 0..<2 {
                    err = clSetKernelArg(mpKernel,
                        indices[i],
                        sizes[i],
                        values[i])
                    
                    if err != CL_SUCCESS {
                        return err
                    }
                }
                
                if mpQueue != nil {
                    
                    var local_dim: [size_t] = [1, 1]
                    
                    var global_dim: [size_t] = [mnUnits, 1]
                    
                    err = clEnqueueNDRangeKernel(mpQueue,
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
                    
                    err = clFinish(mpQueue)
                    
                    if err != CL_SUCCESS {
                        return err
                    }
                }
            }
            
            return err
        }
        
        private func restart() -> cl_int {
            mpData.reset(m_ActiveParams)
            
            return bind()
        }
        
        //MARK: -
        //MARK: Public - Constructor
        
        public convenience init(nbodies: Int,
            params: NBody.Simulation.Params,
            vectorized: Bool,
            threaded: Bool = true)
        {
            self.init(nbodies: nbodies, params: params)
            mbVectorized = vectorized
            mbThreaded   = threaded
            mbTerminated = false
            mnUnits      = 0
            mpDevice     = nil
            mpQueue      = nil
            mpContext    = nil
            mpProgram    = nil
            mpKernel     = nil
            mpData       = NBody.Simulation.Data.Mediator(nbodies: mnBodyCount)
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
                let err = setup(options, mbVectorized, mbThreaded)
                
                mbAcquired = err == CL_SUCCESS
                
                if !mbAcquired {
                    NSLog(">> N-body Simulation[\(err)]: Failed setting up cpu compute device!")
                }
                signalAcquisition()
            }
        }
        
        public override func reset() -> Int {
            var err = restart()
            
            if err != 0 {
                NSLog(">> N-body Simulation[%d]: Failed resetting devices!", err)
            }
            
            return Int(err)
        }
        
        public override func step() {
            if !isPaused || !isStopped {
                var err = execute()
                
                if err != 0 && !mbTerminated {
                    NSLog(">> N-body Simulation[%d]: Failed executing vectorized & threaded kernel!", err)
                }
                if mbIsUpdated {
                    setData(mpData.position())
                }
                
                mpData.swap()
            }
        }
        
        public override func terminate() {
            if !mbTerminated {
                if mpQueue != nil {
                    clFinish(mpQueue)
                }
                
                mpData = nil
                
                if mpQueue != nil {
                    clReleaseCommandQueue(mpQueue)
                    
                    mpQueue = nil
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
                
                mbTerminated = true
            }
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        public override func positionInRange(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            return mpData.positionInRange(mnMinIndex, max: mnMaxIndex, dst: pDst)
        }
        
        public override func position(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            return mpData.position(mnMaxIndex, dst: pDst)
        }
        
        public override func setPosition(pSrc: UnsafePointer<GLfloat>) -> Int {
            return mpData.setPosition(pSrc)
        }
        
        public override func velocity(pDst: UnsafeMutablePointer<GLfloat>) -> Int {
            return mpData.velocity(pDst)
        }
        
        public override func setVelocity(pSrc: UnsafePointer<GLfloat>) -> Int {
            return mpData.setVelocity(pSrc)
        }
    }
}