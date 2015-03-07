//
//  NBodySimulationDataPacked.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
     File: NBodySimulationDataPacked.h
     File: NBodySimulationDataPacked.mm
 Abstract:
 Utility class for managing cpu bound device and host packed mass and position data.

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

extension NBody.Simulation.Data {
    public class Packed {
        
        deinit {destruct()}
        
        private var mnBodies: Int = 0
        private var mnSamples: Int = 0
        private var mnLength: Int = 0
        private var mnSize: Int = 0
        private var mnFlags: cl_mem_flags = 0
        private var mpPacked: Packed3D = Packed3D()
    }
}

//MARK: -
//MARK: Private - Constants

private let kNBodySimPackedDataMemSize = size_t(strideof(cl_mem))

//MARK: -
//MARK: Private - Data Structures

extension NBody.Simulation {
    private struct PackedData {
        var mpHost: UnsafeMutablePointer<GLfloat> = nil
        var mpDevice: cl_mem = nil
    }
}

extension NBody.Simulation.Data {
    private struct Packed3D {
        var m_Position: NBody.Simulation.PackedData = NBody.Simulation.PackedData()
        var m_Mass: NBody.Simulation.PackedData = NBody.Simulation.PackedData()
    }
}

//MARK: -
//MARK: Public - Constructor

extension NBody.Simulation.Data.Packed {
    public convenience init(nbodies: Int) {
        self.init()
        mnBodies  = nbodies
        mnLength  = 4 * mnBodies
        mnSamples = strideof(GLfloat)
        mnSize    = mnLength * mnSamples
        mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR)
        
        mpPacked.m_Position.mpHost = UnsafeMutablePointer.alloc(mnLength)
        mpPacked.m_Mass.mpHost     = UnsafeMutablePointer.alloc(mnBodies)
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    private func destruct() {
        if mpPacked.m_Mass.mpHost != nil {
            mpPacked.m_Mass.mpHost.dealloc(mnBodies)
            
            mpPacked.m_Mass.mpHost = nil
        }
        
        if mpPacked.m_Position.mpHost != nil {
            mpPacked.m_Position.mpHost.dealloc(mnLength)
            
            mpPacked.m_Position.mpHost = nil
        }
        
        if mpPacked.m_Mass.mpDevice != nil {
            clReleaseMemObject(mpPacked.m_Mass.mpDevice)
            
            mpPacked.m_Mass.mpDevice = nil
        }
        
        if mpPacked.m_Position.mpDevice != nil {
            clReleaseMemObject(mpPacked.m_Position.mpDevice)
            
            mpPacked.m_Position.mpDevice = nil
        }
        
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public var mass: UnsafeMutablePointer<GLfloat> {
        return mpPacked.m_Mass.mpHost
    }
    
    public var position: UnsafeMutablePointer<GLfloat> {
        return mpPacked.m_Position.mpHost
    }
    
    public func acquire(pContext: cl_context) -> Int {
        var err = CL_INVALID_CONTEXT
        
        if pContext != nil {
            mpPacked.m_Mass.mpDevice = clCreateBuffer(pContext,
                mnFlags,
                mnSize,
                mpPacked.m_Mass.mpHost,
                &err)
            
            if err != CL_SUCCESS {
                return -300
            }
            
            mpPacked.m_Position.mpDevice = clCreateBuffer(pContext,
                mnFlags,
                mnSize,
                mpPacked.m_Position.mpHost,
                &err)
            
            if err != CL_SUCCESS {
                return -301
            }
        }
        
        return Int(err)
    }
    
    public func bind(nStartIndex: Int,
        kernel pKernel: cl_kernel) -> Int
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            var sizes: [size_t] = [0, 0]
            var pValues: [UnsafeMutablePointer<Void>] = [nil, nil]
            
            pValues[0] = UnsafeMutablePointer(withUnsafeMutablePointer(&mpPacked.m_Position.mpDevice) {$0})
            pValues[1] = UnsafeMutablePointer(withUnsafeMutablePointer(&mpPacked.m_Mass.mpDevice) {$0})
            
            sizes[0] = kNBodySimPackedDataMemSize
            sizes[1] = kNBodySimPackedDataMemSize
            
            for i in 0..<2 {
                err = clSetKernelArg(pKernel,
                    cl_uint(nStartIndex + i),
                    sizes[i],
                    pValues[i])
                
                if err != CL_SUCCESS {
                    return Int(err)
                }
            }
        }
        
        return Int(err)
    }
    
    public func update(nIndex: Int, kernel pKernel: cl_kernel) -> Int {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            let nSize  = kNBodySimPackedDataMemSize
            let pValue = withUnsafeMutablePointer(&mpPacked.m_Position.mpDevice) {$0}
            
            err = clSetKernelArg(pKernel, cl_uint(nIndex), nSize, pValue)
            
            if err != CL_SUCCESS {
                return Int(err)
            }
        }
        
        return Int(err)
    }
}