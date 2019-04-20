//
//  NBodySimulationGPU.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
<codex>
<abstract>
Utility class for managing gpu bound computes for n-body simulation.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation {
    open class GPU: Base {
        
        private var mbTerminated: Bool = false
        private var mpHostPosition: UnsafeMutablePointer<GLfloat>? = nil
        private var mpHostVelocity: UnsafeMutablePointer<GLfloat>? = nil
        private var mnReadIndex: Int = 0
        private var mnWriteIndex: Int = 0
        private var mnWorkItemX: GLuint = 0
        private var mnDeviceIndex: Int = 0
        private var mpContext: cl_context? = nil
        private var mpProgram: cl_program? = nil
        private var mpKernel: cl_kernel? = nil
        private var mpDevice: [cl_device_id?] = [nil, nil]
        private var mpQueue: [cl_command_queue?] = [nil, nil]
        private var mpDevicePosition: [cl_mem?] = [nil, nil]
        private var mpDeviceVelocity: [cl_mem?] = [nil, nil]
        private var mpBodyRangeParams: cl_mem? = nil
        
        //MARK: -
        //MARK: Private - Constants
        
        private let kWorkItemsX: GLuint = 256
        private let kWorkItemsY: GLuint = 1
        
        private let kKernelParams = 11
        private let kSizeCLMem    = MemoryLayout<cl_mem>.stride
        
        private var kIntegrateSystem: String = "IntegrateSystem"
        
        //MARK: -
        //MARK: Private - Utilities
        
        @discardableResult
        private func readBuffer(_ compute_commands: cl_command_queue!,
            _ host_data: UnsafeMutablePointer<GLfloat>,
            _ device_data: cl_mem!,
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
        
        private func writeBuffer(_ compute_commands: cl_command_queue!,
            _ host_data: UnsafePointer<GLfloat>,
            _ device_data: cl_mem!,
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
        
        @discardableResult
        private func bind() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                
//                var pValues: [UnsafeRawPointer] = Array(repeating: nil, count: kKernelParams)
//                pValues[0] =&! &mpDevicePosition[mnWriteIndex]
//                pValues[1] =&! &mpDeviceVelocity[mnWriteIndex]
//                pValues[2] =&! &mpDevicePosition[mnReadIndex]
//                pValues[3] =&! &mpDeviceVelocity[mnReadIndex]
//                pValues[4] =&! &m_Properties.mnTimeStep
//                pValues[5] =&! &m_Properties.mnDamping
//                pValues[6] =&! &m_Properties.mnSoftening
//                pValues[7] =&! &m_Properties.mnParticles   //### taking lower 4 bytes
//                pValues[8] =&! &mnMinIndex   //### taking lower 4 bytes
//                pValues[9] =&! &mnMaxIndex   //### taking lower 4 bytes
//                pValues[10] = nil
//                
//                let sizes: [size_t] = [
//                    kSizeCLMem,
//                    kSizeCLMem,
//                    kSizeCLMem,
//                    kSizeCLMem,
//                    mnSamples,
//                    mnSamples,
//                    mnSamples,
//                    GLM.Size.kInt,   //### taking lower 4 bytes
//                    GLM.Size.kInt,   //### taking lower 4 bytes
//                    GLM.Size.kInt,   //### taking lower 4 bytes
//                    4 * mnSamples * mnWorkItemX.l * kWorkItemsY.l,
//                ]
//                
//                for i in 0..<kKernelParams {
//                    err = clSetKernelArg(mpKernel, i.ui, sizes[i], pValues[i])
//                    
//                    if err != CL_SUCCESS {
//                        return err
//                    }
//                }
                err = clSetKernelArg(mpKernel,  0, kSizeCLMem, &mpDevicePosition[mnWriteIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  1, kSizeCLMem, &mpDeviceVelocity[mnWriteIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  2, kSizeCLMem, &mpDevicePosition[mnReadIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  3, kSizeCLMem, &mpDeviceVelocity[mnReadIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  4, mnSamples, &m_Properties.mnTimeStep)
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  5, mnSamples, &m_Properties.mnDamping)
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  6, mnSamples, &m_Properties.mnSoftening)
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  7, GLM.Size.kInt, &m_Properties.mnParticles)   //### taking lower 4 bytes
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  8, GLM.Size.kInt, &mnMinIndex)   //### taking lower 4 bytes
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel,  9, GLM.Size.kInt, &mnMaxIndex)   //### taking lower 4 bytes
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel, 10, 4 * mnSamples * mnWorkItemX.l * kWorkItemsY.l, nil)
                if err != CL_SUCCESS {return err}
            }
            
            return err
        }
        
        private func setup(_ options: String) -> cl_int {
            let file_flags: cl_mem_flags = CL_MEM_READ_WRITE.ull
            
            let i = mnDeviceIndex
            
            var err = CL_SUCCESS
            
            err = clGetDeviceIDs(nil, CL_DEVICE_TYPE_GPU.ull, 4, &mpDevice, &mnDevices)
            
            if err != CL_SUCCESS {
                return err
            }
            
            print(">> N-body Simulation: Found \(mnDevices) devices...")
            
            var nSize: size_t = 0
            
            var name: [CChar] = Array(repeating: 0, count: 1024)
            var vendor: [CChar] = Array(repeating: 0, count: 1024)
            
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
            
            m_DeviceName = GLstring(cString: name)
            
            print(">> N-body Simulation: Using Device[\(i)] = \"\(m_DeviceName)\"")
            
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
            
            let file = CF.File("nbody_gpu", "ocl")
            
            let nLength = file.length
            
            if nLength == 0 {
                return CL_INVALID_VALUE
            }
            
            let source  = file.string!
            err = source.withCString {pSource in
                var err: GLint = 0
                var ptrSource: UnsafePointer<GLchar>? = pSource
                
                self.mpProgram = clCreateProgramWithSource(mpContext,
                    1,
                    &ptrSource,
                    nil,
                    &err)
                
                return err
            }
            
            if err != CL_SUCCESS {
                return err
            }
            
            err = options.withCString { pOptions in
                let ptrOptions = !options.isEmpty ? pOptions : nil
                return clBuildProgram(mpProgram,
                    mnDeviceCount,
                    mpDevice,
                    ptrOptions,
                    nil,
                    nil)
            }
            
            if err != CL_SUCCESS {
                var length: size_t = 0
                
                var info_log: [CChar] = Array(repeating: 0, count: 2000)
                
                for i in 0..<mnDeviceCount.l {
                    clGetProgramBuildInfo(mpProgram,
                        mpDevice[i],
                        CL_PROGRAM_BUILD_LOG.ui,
                        2000,
                        &info_log,
                        &length)
                    
                    NSLog(">> N-body Simulation: Build Log for Device [\(i)]:\n%@", GLstring(cString: info_log))
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
            
            let isInvalidWorkDim = (m_Properties.mnParticles.ui % mnWorkItemX) != 0
            
            if isInvalidWorkDim {
                NSLog(">> N-body Simulation: Number of particlces [\(m_Properties.mnParticles)] must be evenly divisble work group size [\(mnWorkItemX)] for device!")
                return CL_INVALID_WORK_DIMENSION
            }
            
            let size: size_t = 4 * GLM.Size.kFloat * m_Properties.mnParticles
            
            mpDevicePosition[0] = clCreateBuffer(mpContext,
                file_flags,
                size,
                nil,
                &err)
            
            if err != CL_SUCCESS {
                return -100
            }
            
            mpDevicePosition[1] = clCreateBuffer(mpContext,
                file_flags,
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
            
            bind()
            
            return 0
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
                
//                var values: [UnsafeRawPointer] = Array(repeating: nil, count: 4)
//                values[0] =&! &mpDevicePosition[mnWriteIndex]
//                values[1] =&! &mpDeviceVelocity[mnWriteIndex]
//                values[2] =&! &mpDevicePosition[mnReadIndex]
//                values[3] =&! &mpDeviceVelocity[mnReadIndex]
//                
//                let sizes: [size_t] = [kSizeCLMem, kSizeCLMem, kSizeCLMem, kSizeCLMem]
//                
//                let indices: [GLuint] = [0, 1, 2, 3]
//                
//                for i in 0..<4 {
//                    err = clSetKernelArg(mpKernel, indices[i], sizes[i], values[i])
//                    
//                    if err != CL_SUCCESS {
//                        return err
//                    }
//                }
                err = clSetKernelArg(mpKernel, 0, kSizeCLMem, &mpDevicePosition[mnWriteIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel, 1, kSizeCLMem, &mpDeviceVelocity[mnWriteIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel, 2, kSizeCLMem, &mpDevicePosition[mnReadIndex])
                if err != CL_SUCCESS {return err}
                err = clSetKernelArg(mpKernel, 3, kSizeCLMem, &mpDeviceVelocity[mnReadIndex])
                if err != CL_SUCCESS {return err}
                
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
                let urdp = NBody.Simulation.Data.URDP(m_Properties)
                
                if urdp.setTo(mpHostPosition, mpHostVelocity) {
                    let size: size_t = 4 * GLM.Size.kFloat * m_Properties.mnParticles
                    
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
        
        public init(
            _ Properties: NBody.Simulation.Properties,
            _ index: Int)
        {
            super.init(Properties)
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
        
        open override func initialize(_ options: String) {
            if !mbTerminated {
                mnReadIndex  = 0
                mnWriteIndex = 1
                
                mpHostPosition = UnsafeMutablePointer<GLfloat>.allocate(capacity: mnLength)
                mpHostVelocity = UnsafeMutablePointer<GLfloat>.allocate(capacity: mnLength)
                
                let err = setup(options)
                
                let mbAcquired = err == CL_SUCCESS
                
                if !mbAcquired {
                    print(">> N-body Simulation[\(err)]: Failed setting up gpu compute device!")
                } else {
                    signalAcquisition()
                }
            }
        }
        
        open override func reset() -> GLint {
            let err = restart()
            
            if err != CL_SUCCESS {
                print(">> N-body Simulation[\(err)]: Failed resetting devices!")
            }
            
            return err
        }
        
        open override func step() {
            if !isPaused || !isStopped {
                let err = execute()
                
                if err != CL_SUCCESS {
                    print(">> N-body Simulation[\(err)]: Failed executing gpu bound kernel!")
                }
                
                if mbIsUpdated {
                    for i in 0..<mnDeviceCount.l {
                        readBuffer(mpQueue[i],
                            mpHostPosition!,
                            mpDevicePosition[mnWriteIndex],
                            mnSize,
                            0)
                        
                        setData(mpHostPosition)
                    }
                }
                
                swap(&mnReadIndex, &mnWriteIndex)
            }
        }
        
        open override func terminate() {
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
                    mpHostPosition?.deallocate()
                    
                    mpHostPosition = nil
                }
                
                if mpHostVelocity != nil {
                    mpHostVelocity?.deallocate()
                    
                    mpHostVelocity = nil
                }
                
                mbTerminated = true
            }
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        open override func positionInRange(_ pDst: UnsafeMutablePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                let data_offset_in_floats = mnMinIndex * 4
                let data_offset_bytes: size_t     = data_offset_in_floats * mnSamples
                let data_size_in_floats   = (mnMaxIndex - mnMinIndex) * 4
                let data_size_bytes       = data_size_in_floats * mnSamples
                
                let host_data = pDst?.advanced(by: data_offset_in_floats)
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        host_data!,
                        mpDevicePosition[mnReadIndex],
                        data_size_bytes,
                        data_offset_bytes)
                    if err != CL_SUCCESS {
                        return err
                    }
                }
            }
            
            return err
        }
        
        open override func position(_ pDst: UnsafeMutablePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        pDst!,
                        mpDevicePosition[mnReadIndex],
                        mnSize,
                        0)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err
        }
        
        open override func setPosition(_ pSrc: UnsafePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pSrc != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = writeBuffer(mpQueue[i],
                        pSrc!,
                        mpDevicePosition[mnReadIndex],
                        mnSize)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err
        }
        
        open override func velocity(_ pDst: UnsafeMutablePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = readBuffer(mpQueue[i],
                        pDst!,
                        mpDeviceVelocity[mnReadIndex],
                        mnSize,
                        0)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err
        }
        
        open override func setVelocity(_ pSrc: UnsafePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pSrc != nil {
                
                for i in 0..<mnDeviceCount.l {
                    err = writeBuffer(mpQueue[i],
                        pSrc!,
                        mpDeviceVelocity[mnReadIndex],
                        mnSize)
                    
                    if err != CL_SUCCESS {
                        break
                    }
                }
            }
            
            return err
        }
    }
}
