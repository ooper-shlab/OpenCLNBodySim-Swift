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
    open class Packed {
        
        fileprivate var mnParticles: Int = 0
        //private var mnSamples: Int = 0
        fileprivate var mnLength: Int = 0
        //private var mnSize: Int = 0
        fileprivate var mnFlags: cl_mem_flags = 0
        fileprivate var mpPacked: Packed3D = Packed3D()
    }
}

//MARK: -
//MARK: Private - Constants

private let kNBodySimPackedDataMemSize = size_t(MemoryLayout<cl_mem>.stride)

//MARK: -
//MARK: Private - Data Structures

//extension NBody.Simulation {
//    private struct PackedData {
//        var mpHost: UnsafeMutablePointer<GLfloat> = nil
//        var mpDevice: cl_mem = nil
//    }
//}

extension NBody.Simulation.Data {
    fileprivate class Packed3D {
        var mpHost: UnsafeMutablePointer<GLfloat>? = nil
        var mpDevice: cl_mem? = nil
        
        private var mnLength: Int = 0
        func alloc(_ length: Int) {
            if mpHost != nil {
                mpHost?.deallocate()
            }
            mnLength = length
            mpHost = UnsafeMutablePointer.allocate(capacity: length)
        }
        func createBuffer(_ pContext: cl_context,
            _ mnFlags: cl_mem_flags) -> cl_int
        {
            if mpHost == nil {
                return CL_INVALID_VALUE
            }
            var err: cl_int = 0
            let mnSamples = MemoryLayout<GLfloat>.stride
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
                mpHost?.deallocate()
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
        return mpPacked.mpHost!
    }
    
    public func acquire(_ pContext: cl_context?) -> GLint {
        var err = CL_INVALID_CONTEXT
        
        if pContext != nil {
            err = mpPacked.createBuffer(pContext!,
                mnFlags)
            
            if err != CL_SUCCESS {
                return -301
            }
        }
        
        return err
    }
    
    public func bind(_ nIndex: cl_uint,
        _ pKernel: cl_kernel?) -> GLint
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            let nSize  = kNBodySimPackedDataMemSize
            
            err = clSetKernelArg(pKernel,
                                  nIndex,
                                  nSize,
                                  &mpPacked.mpDevice)
        }
        
        return err
    }
    
    public func update(_ nIndex: cl_uint,
        _ pKernel: cl_kernel?) -> GLint {
            var err = CL_INVALID_KERNEL
            
            if pKernel != nil {
                let nSize  = kNBodySimPackedDataMemSize
                err = withUnsafePointer(to: &mpPacked.mpDevice) {pValue in
                    
                    return clSetKernelArg(pKernel, nIndex, nSize, pValue)
                    
                }
            }
            
            return err
    }
}
