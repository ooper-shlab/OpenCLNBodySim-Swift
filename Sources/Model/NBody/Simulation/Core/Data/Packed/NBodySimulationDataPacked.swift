//
//  NBodySimulationDataPacked.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
<codex>
<abstract>
Utility class for managing cpu bound device and host packed mass and position data.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation.Data {
    public class Packed {
        
        private var mnParticles: Int = 0
        //private var mnSamples: Int = 0
        private var mnLength: Int = 0
        //private var mnSize: Int = 0
        private var mnFlags: cl_mem_flags = 0
        private var mpPacked: Packed3D = Packed3D()
    }
}

//MARK: -
//MARK: Private - Constants

private let kNBodySimPackedDataMemSize = size_t(strideof(cl_mem))

//MARK: -
//MARK: Private - Data Structures

//extension NBody.Simulation {
//    private struct PackedData {
//        var mpHost: UnsafeMutablePointer<GLfloat> = nil
//        var mpDevice: cl_mem = nil
//    }
//}

extension NBody.Simulation.Data {
    private class Packed3D {
        var mpHost: UnsafeMutablePointer<GLfloat> = nil
        var mpDevice: cl_mem = nil
        
        private var mnLength: Int = 0
        func alloc(length: Int) {
            if mpHost != nil {
                mpHost.dealloc(mnLength)
            }
            mnLength = length
            mpHost = UnsafeMutablePointer.alloc(length)
        }
        func createBuffer(pContext: cl_context,
            _ mnFlags: cl_mem_flags) -> cl_int
        {
            if mpHost == nil {
                return CL_INVALID_VALUE
            }
            var err: cl_int = 0
            let mnSamples = strideof(GLfloat)
            let mnSize    = mnLength * mnSamples
            mpDevice = clCreateBuffer(pContext,
                mnFlags,
                mnSize,
                mpHost,
                &err)
            return err
        }
        
        deinit {
            if mpHost != nil {
                mpHost.dealloc(mnLength)
            }
            if mpDevice != nil {
                clReleaseMemObject(mpDevice)
            }
        }
    }
}

//MARK: -
//MARK: Public - Constructor

extension NBody.Simulation.Data.Packed {
    public convenience init(_ rProperties: NBody.Simulation.Properties) {
        self.init()
        mnParticles  = rProperties.mnParticles
        mnLength  = 4 * mnParticles
        //mnSamples = strideof(GLfloat)
        //mnSize    = mnLength * mnSamples
        mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR)
        
        mpPacked.alloc(mnLength)
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public var data: UnsafeMutablePointer<GLfloat> {
        return mpPacked.mpHost
    }
    
    public func acquire(pContext: cl_context) -> GLint {
        var err = CL_INVALID_CONTEXT
        
        if pContext != nil {
            err = mpPacked.createBuffer(pContext,
                mnFlags)
            
            if err != CL_SUCCESS {
                return -301
            }
        }
        
        return err
    }
    
    public func bind(nIndex: cl_uint,
        _ pKernel: cl_kernel) -> GLint
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            err = withUnsafePointer(&mpPacked.mpDevice) {pValue in
                let nSize  = kNBodySimPackedDataMemSize
                
                return clSetKernelArg(pKernel,
                    nIndex,
                    nSize,
                    pValue)
            }
        }
        
        return err
    }
    
    public func update(nIndex: cl_uint,
        _ pKernel: cl_kernel) -> GLint {
            var err = CL_INVALID_KERNEL
            
            if pKernel != nil {
                let nSize  = kNBodySimPackedDataMemSize
                err = withUnsafePointer(&mpPacked.mpDevice) {pValue in
                    
                    return clSetKernelArg(pKernel, nIndex, nSize, pValue)
                    
                }
            }
            
            return err
    }
}
