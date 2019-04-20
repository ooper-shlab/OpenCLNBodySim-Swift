//
//  NBodySimulationDataSplit.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
<codex>
<abstract>
Utility class for managing cpu bound device and host split position and velocity data.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation.Data {
    public enum Axis: Int {
        case x = 0
        case y
        case z
    }
    
    open class Split {
        
        fileprivate var mnParticles: Int = 0
        //private var mnSamples: Int = 0
        //private var mnSize: Int = 0
        fileprivate var mnFlags: cl_mem_flags = 0
        fileprivate var mpSplit: Split3D = Split3D()
    }
}

//MARK: -
//MARK: Private - Constants

private let kNBodySimDevMemPosErr = -200
private let kNBodySimDevMemVelErr = -201

private let kNBodySimSplitDataMemSize = size_t(MemoryLayout<cl_mem>.stride)

//MARK: -
//MARK: Private - Data Structures

extension NBody.Simulation {
    fileprivate struct SplitData {
        var mpHost: UnsafeMutablePointer<GLfloat>? = nil
        var mpDevice: cl_mem? = nil
    }
}

extension NBody.Simulation.Data {
    fileprivate class Split3D {
        var m_Mass = NBody.Simulation.SplitData()
        var m_Position: [NBody.Simulation.SplitData] = Array(repeating: NBody.Simulation.SplitData(), count: 3)
        var m_Velocity: [NBody.Simulation.SplitData] = Array(repeating: NBody.Simulation.SplitData(), count: 3)
        
        private var mnCount: Int = 0
        func alloc(_ nCount: Int) {
            mnCount = nCount
            
            m_Mass.mpHost = UnsafeMutablePointer.allocate(capacity: nCount)
            
            for i in 0..<3 {
                m_Position[i].mpHost = UnsafeMutablePointer.allocate(capacity: nCount)
                
                m_Velocity[i].mpHost = UnsafeMutablePointer.allocate(capacity: nCount)
            }
        }
        func createBuffer(_ nIndex: Int,
            _ pContext: cl_context?,
            _ nFlags: cl_mem_flags) -> cl_int
        {
            let mnSamples = MemoryLayout<GLfloat>.stride
            let mnSize = mnSamples * mnCount
            var err: cl_int = CL_SUCCESS
            if pContext != nil {
                m_Position[nIndex].mpDevice = clCreateBuffer(pContext,
                    nFlags,
                    mnSize,
                    m_Position[nIndex].mpHost,
                    &err)
                
                if err != CL_SUCCESS {
                    return kNBodySimDevMemPosErr.i
                }
                
                m_Velocity[nIndex].mpDevice = clCreateBuffer(pContext,
                    nFlags,
                    mnSize,
                    m_Velocity[nIndex].mpHost,
                    &err)
                
                if err != CL_SUCCESS {
                    return kNBodySimDevMemVelErr.i
                }
            }
            return err
        }
        func createBuffer(_ pContext: cl_context?,
            _ nFlags: cl_mem_flags) -> cl_int
        {
            let mnSamples = MemoryLayout<GLfloat>.stride
            let mnSize = mnSamples * mnCount
            var err: cl_int = CL_SUCCESS
            if pContext != nil {
                m_Mass.mpDevice = clCreateBuffer(pContext,
                    nFlags,
                    mnSize,
                    m_Mass.mpHost,
                    &err)
            }
            return err
        }
        deinit {
            for i in 0..<3 {
                // Host Position
                if m_Position[i].mpHost != nil {
                    m_Position[i].mpHost?.deallocate()
                }
                
                // Host Velocity
                if m_Velocity[i].mpHost != nil {
                    m_Velocity[i].mpHost?.deallocate()
                }
                
                // Device Position
                if m_Position[i].mpDevice != nil {
                    clReleaseMemObject(m_Position[i].mpDevice)
                }
                
                // Device Velocity
                if m_Velocity[i].mpDevice != nil {
                    clReleaseMemObject(m_Velocity[i].mpDevice)
                }
            }
            if m_Mass.mpHost != nil {
                m_Mass.mpHost?.deallocate()
            }
            if m_Mass.mpDevice != nil {
                clReleaseMemObject(m_Mass.mpDevice)
            }
        }
    }
}

extension NBody.Simulation.Data.Split {
    //MARK: -
    //MARK: Private - Utilities - Constructors
    
    private func create(_ nCount: Int) {
        
        mpSplit.alloc(nCount)
    }
    
    private func acquire(_ nIndex: Int,
        _ pContext: cl_context?) -> cl_int
    {
        var err: cl_int = CL_INVALID_CONTEXT
        
        if pContext != nil {
            err = mpSplit.createBuffer(nIndex, pContext, mnFlags)
        }
        
        return err
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(_ rProperties: NBody.Simulation.Properties) {
        self.init()
        mnParticles = rProperties.mnParticles
        //mnSamples = strideof(GLfloat)
        //mnSize = mnSamples * mnParticles
        mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR)
        create(mnParticles)
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public func mass() -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Mass.mpHost!
    }
    
    public func position(_ nCoord: NBody.Simulation.Data.Axis) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Position[nCoord.rawValue].mpHost!
    }
    
    public func velocity(_ nCoord: NBody.Simulation.Data.Axis) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Velocity[nCoord.rawValue].mpHost!
    }
    
    public func acquire(_ pContext: cl_context?) -> cl_int {
        var err = CL_INVALID_CONTEXT
        
        if pContext != nil {
            err = mpSplit.createBuffer(pContext,
                mnFlags)
            
            if(err != CL_SUCCESS)
            {
                print(">> ERROR: Failed acquring device memory!")
                
                return kNBodySimDevMemPosErr.i
            } // if
            
            for i in 0..<3 {
                err = acquire(i, pContext)
                
                if err != CL_SUCCESS {
                    print(">> ERROR: Failed in acquring device memory at index [\(i)]!")
                    
                    break
                }
            }
        }
        
        return err
    }
    
    public func bind(_ nStartIndex: Int,
        _ pKernel: cl_kernel?) -> cl_int
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            
//            var pValues: [UnsafeMutableRawPointer] = Array(repeating: nil, count: 7)
//            
//            pValues[0]  =&! &mpSplit.m_Position[0].mpDevice;
//            pValues[1]  =&! &mpSplit.m_Position[1].mpDevice;
//            pValues[2]  =&! &mpSplit.m_Position[2].mpDevice;
//            pValues[3]  =&! &mpSplit.m_Velocity[0].mpDevice;
//            pValues[4]  =&! &mpSplit.m_Velocity[1].mpDevice;
//            pValues[5]  =&! &mpSplit.m_Velocity[2].mpDevice;
//            pValues[6]  =&! &mpSplit.m_Mass.mpDevice;
//            
//            let sizes: [size_t] = [
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//                kNBodySimSplitDataMemSize,
//            ]
//            
//            for i in 0..<7 {
//                err = clSetKernelArg(pKernel,
//                    cl_uint(nStartIndex + i),
//                    sizes[i],
//                    pValues[i])
//                
//                if err != CL_SUCCESS {
//                    return err
//                }
//            }
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 0),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Position[0].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 1),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Position[1].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 2),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Position[2].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 3),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Velocity[0].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 4),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Velocity[1].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 5),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Velocity[2].mpDevice)
            if err != CL_SUCCESS {return err}
            err = clSetKernelArg(pKernel,
                                 cl_uint(nStartIndex + 6),
                                 kNBodySimSplitDataMemSize,
                                 &mpSplit.m_Mass.mpDevice)
            if err != CL_SUCCESS {return err}
        }
        
        return err
    }
}
