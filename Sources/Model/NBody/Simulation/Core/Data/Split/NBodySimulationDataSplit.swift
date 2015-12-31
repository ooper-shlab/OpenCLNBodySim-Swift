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
        case X = 0
        case Y
        case Z
    }
    
    public class Split {
        
        private var mnParticles: Int = 0
        //private var mnSamples: Int = 0
        //private var mnSize: Int = 0
        private var mnFlags: cl_mem_flags = 0
        private var mpSplit: Split3D = Split3D()
    }
}

//MARK: -
//MARK: Private - Constants

private let kNBodySimDevMemPosErr = -200
private let kNBodySimDevMemVelErr = -201

private let kNBodySimSplitDataMemSize = size_t(strideof(cl_mem))

//MARK: -
//MARK: Private - Data Structures

extension NBody.Simulation {
    private struct SplitData {
        var mpHost: UnsafeMutablePointer<GLfloat> = nil
        var mpDevice: cl_mem = nil
    }
}

extension NBody.Simulation.Data {
    private class Split3D {
        var m_Mass = NBody.Simulation.SplitData()
        var m_Position: [NBody.Simulation.SplitData] = Array(count: 3, repeatedValue: NBody.Simulation.SplitData())
        var m_Velocity: [NBody.Simulation.SplitData] = Array(count: 3, repeatedValue: NBody.Simulation.SplitData())
        
        private var mnCount: Int = 0
        func alloc(nCount: Int) {
            mnCount = nCount
            
            m_Mass.mpHost = UnsafeMutablePointer.alloc(nCount)
         
            for i in 0..<3 {
                m_Position[i].mpHost = UnsafeMutablePointer.alloc(nCount)
            
                m_Velocity[i].mpHost = UnsafeMutablePointer.alloc(nCount)
            }
        }
        func createBuffer(nIndex: Int,
            _ pContext: cl_context,
            _ nFlags: cl_mem_flags) -> cl_int
        {
            let mnSamples = strideof(GLfloat)
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
        func createBuffer(pContext: cl_context,
            _ nFlags: cl_mem_flags) -> cl_int
        {
            let mnSamples = strideof(GLfloat)
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
                    m_Position[i].mpHost.dealloc(mnCount)
                }
                
                // Host Velocity
                if m_Velocity[i].mpHost != nil {
                    m_Velocity[i].mpHost.dealloc(mnCount)
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
                m_Mass.mpHost.dealloc(mnCount)
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
    
    private func create(nCount: Int) {
        
        mpSplit.alloc(nCount)
    }
    
    private func acquire(nIndex: Int,
        _ pContext: cl_context) -> cl_int
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
        return mpSplit.m_Mass.mpHost
    }
    
    public func position(nCoord: NBody.Simulation.Data.Axis) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Position[nCoord.rawValue].mpHost
    }
    
    public func velocity(nCoord: NBody.Simulation.Data.Axis) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Velocity[nCoord.rawValue].mpHost
    }
    
    public func acquire(pContext: cl_context) -> cl_int {
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
    
    public func bind(nStartIndex: Int,
        _ pKernel: cl_kernel) -> cl_int
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            
            var pValues: [UnsafeMutablePointer<Void>] = Array(count: 7, repeatedValue: nil)
            
            pValues[0]  =&! &mpSplit.m_Position[0].mpDevice;
            pValues[1]  =&! &mpSplit.m_Position[1].mpDevice;
            pValues[2]  =&! &mpSplit.m_Position[2].mpDevice;
            pValues[3]  =&! &mpSplit.m_Velocity[0].mpDevice;
            pValues[4]  =&! &mpSplit.m_Velocity[1].mpDevice;
            pValues[5]  =&! &mpSplit.m_Velocity[2].mpDevice;
            pValues[6]  =&! &mpSplit.m_Mass.mpDevice;
            
            let sizes: [size_t] = [
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
            ]
            
            for i in 0..<7 {
                err = clSetKernelArg(pKernel,
                    cl_uint(nStartIndex + i),
                    sizes[i],
                    pValues[i])
                
                if err != CL_SUCCESS {
                    return err
                }
            }
        }
        
        return err
    }
}
