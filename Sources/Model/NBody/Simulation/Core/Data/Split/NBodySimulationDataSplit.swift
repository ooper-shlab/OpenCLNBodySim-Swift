//
//  NBodySimulationDataSplit.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
     File: NBodySimulationDataSplit.h
     File: NBodySimulationDataSplit.mm
 Abstract:
 Utility class for managing cpu bound device and host split position and velocity data.

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

func arrayPointer(ptr: UnsafeMutablePointer<GLfloat>) -> UnsafeMutablePointer<GLfloat> {
    return ptr
}
extension NBody.Simulation.Data {
    public enum Coordinates: Int {
        case X = 0
        case Y
        case Z
    }
    
    public class Split {
        
        deinit {destruct()}
        
        private var mnBodies: Int = 0
        private var mnSamples: Int = 0
        private var mnSize: Int = 0
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
    private struct Split3D {
        var m_Position: [NBody.Simulation.SplitData] = [NBody.Simulation.SplitData(), NBody.Simulation.SplitData(), NBody.Simulation.SplitData()]
        var m_Velocity: [NBody.Simulation.SplitData] = [NBody.Simulation.SplitData(), NBody.Simulation.SplitData(), NBody.Simulation.SplitData()]
    }
}

extension NBody.Simulation.Data.Split {
    //MARK: -
    //MARK: Private - Utilities - Constructors
    
    private func create(nCount: Int) {
        
        mpSplit.m_Position[0].mpHost = UnsafeMutablePointer.alloc(nCount)
        mpSplit.m_Position[1].mpHost = UnsafeMutablePointer.alloc(nCount)
        mpSplit.m_Position[2].mpHost = UnsafeMutablePointer.alloc(nCount)
        
        mpSplit.m_Velocity[0].mpHost = UnsafeMutablePointer.alloc(nCount)
        mpSplit.m_Velocity[1].mpHost = UnsafeMutablePointer.alloc(nCount)
        mpSplit.m_Velocity[2].mpHost = UnsafeMutablePointer.alloc(nCount)
        
    }
    
    private func acquire(nIndex: Int,
        _ pContext: cl_context) -> Int
    {
        var err: cl_int = CL_INVALID_CONTEXT
        
        if pContext != nil {
            mpSplit.m_Position[nIndex].mpDevice = clCreateBuffer(pContext,
                mnFlags,
                mnSize,
                mpSplit.m_Position[nIndex].mpHost,
                &err)
            
            if err != CL_SUCCESS {
                return kNBodySimDevMemPosErr
            }
            
            mpSplit.m_Velocity[nIndex].mpDevice = clCreateBuffer(pContext,
                mnFlags,
                mnSize,
                mpSplit.m_Velocity[nIndex].mpHost,
                &err)
            
            if err != CL_SUCCESS {
                return kNBodySimDevMemVelErr
            }
        }
        
        return Int(err)
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(nbodies nBodies: Int) {
        self.init()
        mnBodies = nBodies
        mnSamples = strideof(GLfloat)
        mnSize = mnSamples * mnBodies
        mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR)
        create(mnBodies)
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    private func destruct() {
        
        for i in 0..<3 {
            // Host Position
            if mpSplit.m_Position[i].mpHost != nil {
                mpSplit.m_Position[i].mpHost.dealloc(mnBodies)
                
                mpSplit.m_Position[i].mpHost = nil
            }
            
            // Host Velocity
            if mpSplit.m_Velocity[i].mpHost != nil {
                mpSplit.m_Velocity[i].mpHost.dealloc(mnBodies)
                
                mpSplit.m_Velocity[i].mpHost = nil
            }
            
            // Device Position
            if mpSplit.m_Position[i].mpDevice != nil {
                clReleaseMemObject(mpSplit.m_Position[i].mpDevice)
                
                mpSplit.m_Position[i].mpDevice = nil
            }
            
            // Device Velocity
            if mpSplit.m_Velocity[i].mpDevice != nil {
                clReleaseMemObject(mpSplit.m_Velocity[i].mpDevice)
                
                mpSplit.m_Velocity[i].mpDevice = nil
            }
        }
        
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public func position(nCoord: NBody.Simulation.Data.Coordinates) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Position[nCoord.rawValue].mpHost
    }
    
    public func velocity(nCoord: NBody.Simulation.Data.Coordinates) -> UnsafeMutablePointer<GLfloat> {
        return mpSplit.m_Velocity[nCoord.rawValue].mpHost
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public func acquire(pContext: cl_context) -> Int {
        var err = CL_INVALID_CONTEXT
        
        if pContext != nil {
            
            for i in 0..<3 {
                err = cl_int(acquire(i, pContext))
                
                if err != CL_SUCCESS {
                    println(">> ERROR: Failed in acquring device memory at index [\(i)]!")
                    
                    break
                }
            }
        }
        
        return Int(err)
    }
    
    public func bind(nStartIndex: Int,
        kernel pKernel: cl_kernel) -> Int
    {
        var err = CL_INVALID_KERNEL
        
        if pKernel != nil {
            
            let pValues: [UnsafeMutablePointer<Void>] = [
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Position[0].mpDevice) {$0}),
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Position[1].mpDevice) {$0}),
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Position[2].mpDevice) {$0}),
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Velocity[0].mpDevice) {$0}),
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Velocity[1].mpDevice) {$0}),
                UnsafeMutablePointer(withUnsafeMutablePointer(&mpSplit.m_Velocity[2].mpDevice) {$0}),
            ]
            
            let sizes: [size_t] = [
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
                kNBodySimSplitDataMemSize,
            ]
            
            for i in 0..<6 {
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
}