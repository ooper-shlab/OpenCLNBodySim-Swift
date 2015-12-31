//
//  NBodySimulationCPU.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility class for managing cpu bound computes for n-body simulation.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation {
    
    public class CPU: Base {
        private override init(_ properties: NBody.Simulation.Properties) {
            super.init(properties)
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
            var err = mpData.bind(mpKernel)
            
            if err == CL_SUCCESS {
                
                var nWorkGroupCount: size_t = (mnMaxIndex - mnMinIndex) / mnUnits
                var nTimeStamp: GLfloat      = m_Properties.mnTimeStep
                
                
                var values: [UnsafePointer<Void>] = Array(count: 6, repeatedValue: nil)
                    values[0] =&! &nTimeStamp
                    values[1] =&! &m_Properties.mnDamping
                    values[2] =&! &m_Properties.mnSoftening
                    values[3] =&! &m_Properties.mnParticles
                    values[4] =&! &nWorkGroupCount
                    values[5] =&! &mnMinIndex
                
                var sizes: [size_t] = [
                    mnSamples,
                    mnSamples,
                    mnSamples,
                    GLM.Size.kInt,   //### sending lower 4 byte?
                    GLM.Size.kInt,   //### sending lower 4 byte?
                    GLM.Size.kInt,   //### sending lower 4 byte?
                ]
                
                var indices: [cl_uint] = Array(14...19)
                
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
            
            let file = CF.File("nbody_cpu", "ocl")
            
            let nLength = file.length
            
            if nLength == 0 {
                return CL_INVALID_VALUE
            }
            
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
            
            let source = file.string!
            err = source.withCString {pSource in
                var pBuffer = pSource
                var err: Int32 = 0
                
                mpProgram = clCreateProgramWithSource(mpContext,
                    1,
                    &pBuffer,
                    nil,
                    &err)
                
                return err
            }
            if err != CL_SUCCESS {
                return err
            }
            
            err = options.withCString {pOptions in
                let ptrOptions = options.isEmpty ? nil : pOptions
                return clBuildProgram(mpProgram,
                    mnDeviceCount,
                    &mpDevice,
                    ptrOptions,
                    nil,
                    nil)
            }
            
                if err != CL_SUCCESS {
                    var length: size_t = 0
                    
                    var info_log: [CChar] = Array(count: 2000, repeatedValue: 0)
                    
                    clGetProgramBuildInfo(mpProgram,
                        mpDevice,
                        CL_PROGRAM_BUILD_LOG.ui,
                        2000,
                        &info_log,
                        &length)
                    
                    NSLog(">> N-body Simulation:\n%@", GLstring.fromCString(info_log)!)
                    
                    return err
                }
                
                let kernelName = vectorized ? "IntegrateSystemVectorized" : "IntegrateSystemNonVectorized"
                mpKernel = clCreateKernel(mpProgram,
                    kernelName,
                    &err)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                err = mpData.acquire(mpContext)
                
                if err != CL_SUCCESS {
                    return err
                }
                
                return bind()
        }
        
        private func execute() -> cl_int {
            var err = CL_INVALID_KERNEL
            
            if mpKernel != nil {
                mpData.update(mpKernel)
                
                var nWorkGroupCount: size_t = (mnMaxIndex - mnMinIndex) / mnUnits
                
                var values: [UnsafeMutablePointer<Void>] = [nil, nil]
                values[0] =&! &nWorkGroupCount
                values[1] =&! &mnMinIndex
                
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
                    
                    let local_dim: [size_t] = [1, 1]
                    
                    let global_dim: [size_t] = [mnUnits, 1]
                    
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
            mpData.reset(m_Properties)
            
            return bind()
        }
        
        //MARK: -
        //MARK: Public - Constructor
        
        public convenience init(_ properties: NBody.Simulation.Properties,
            _ vectorized: Bool,
            _ threaded: Bool = true)
        {
            self.init(properties)
            mbVectorized = vectorized
            mbThreaded   = threaded
            mbTerminated = false
            mnUnits      = 0
            mpDevice     = nil
            mpQueue      = nil
            mpContext    = nil
            mpProgram    = nil
            mpKernel     = nil
            mpData       = NBody.Simulation.Data.Mediator(properties)
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
                
                let mbAcquired = err == CL_SUCCESS
                
                if !mbAcquired {
                    NSLog(">> N-body Simulation[\(err)]: Failed setting up cpu compute device!")
                } else {
                    signalAcquisition()
                }
            }
        }
        
        public override func reset() -> GLint {
            let err = restart()
            
            if err != 0 {
                NSLog(">> N-body Simulation[%d]: Failed resetting devices!", err)
            }
            
            return err
        }
        
        public override func step() {
            if !isPaused || !isStopped {
                let err = execute()
                
                if err != 0 && !mbTerminated {
                    NSLog(">> N-body Simulation[%d]: Failed executing vectorized & threaded kernel!", err)
                }
                if mbIsUpdated {
                    setData(mpData.data)
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
        
        public override func positionInRange(pDst: UnsafeMutablePointer<GLfloat>) -> GLint {
            return mpData.positionInRange(mnMinIndex, mnMaxIndex, pDst)
        }
        
        public override func position(pDst: UnsafeMutablePointer<GLfloat>) -> GLint {
            return mpData.position(mnMaxIndex, pDst)
        }
        
        public override func setPosition(pSrc: UnsafePointer<GLfloat>) -> GLint {
            return mpData.setPosition(pSrc)
        }
        
        public override func velocity(pDst: UnsafeMutablePointer<GLfloat>) -> GLint {
            return mpData.velocity(pDst)
        }
        
        public override func setVelocity(pSrc: UnsafePointer<GLfloat>) -> GLint {
            return mpData.setVelocity(pSrc)
        }
    }
}