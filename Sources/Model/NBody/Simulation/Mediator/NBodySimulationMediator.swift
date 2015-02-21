//
//  NBodySimulationMediator.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodySimulationMediator.h
     File: NBodySimulationMediator.mm
 Abstract:
 A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.

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
    public class Mediator {
        
        private var mbCPUs: Bool = false
        private var mnBodies: Int = 0
        private var mnSize: Int = 0
        private var mnCount: Int = 0
        private var mnGPUs: Int = 0
        private var mpPosition: UnsafeMutablePointer<GLfloat> = nil
        private var mnActive: Types = Types.CPUMulti
        private var m_Params: Params = Params()
        private var mpSimulators: [NBody.Simulation.Types: Facade] = [:]
        private var mpActive: Facade!
    }
}

private let kNBodyMaxDeviceCount = 128

extension NBody {
    // Get the number of coumpute device counts
    private static func getComputeDeviceCount(type: cl_device_type) -> Int {
        var ids: [cl_device_id] = [cl_device_id](count: kNBodyMaxDeviceCount, repeatedValue: nil)
        
        var count: cl_uint = 0
        
        let err = clGetDeviceIDs(nil, type, cl_uint(kNBodyMaxDeviceCount), &ids, &count)
        
        if err != CL_SUCCESS {
            println(">> ERROR: NBody Simulation Mediator - Failed acquiring maximum device count!")
        }
        
        return count.l
    }
}

extension NBody.Simulation.Mediator {
    // Set the current active n-body parameters
    public func setParams(rParams: NBody.Simulation.Params) {
        
        m_Params = rParams
    }
    
    // Set the defaults for simulator compute
    public func setCompute(bGPUOnly: Bool) {
        mnGPUs = NBody.getComputeDeviceCount(CL_DEVICE_TYPE_GPU.ull)
        
        if !bGPUOnly {
            mbCPUs = NBody.getComputeDeviceCount(CL_DEVICE_TYPE_CPU.ull) > 0
        }
        
        mnActive = (mbCPUs)
            ? NBody.Simulation.Types.CPUSingle
            : NBody.Simulation.Types.GPUPrimary
    }
    
    // Initialize all instance variables to their default values
    public func setDefaults(nBodies: Int) {
        
        mnBodies = nBodies
        mnSize   = 4 * mnBodies * GLM.Size.kFloat
        
        mnCount    = 0
        mnGPUs     = 0
        mbCPUs     = false
        mpActive   = nil
        mpPosition = nil
        
        mpSimulators = [:]
    }
    
    // Acquire all simulators
    public func acquire(rParams: NBody.Simulation.Params) {
        setParams(rParams)
        
        if mnGPUs > 0 {
            mpSimulators[.GPUPrimary]
                = NBody.Simulation.Facade(type: .GPUPrimary, count: mnBodies, params: m_Params)
            
            if mpSimulators[.GPUPrimary] != nil {
                mnCount++
            }
        }
        
        if mnGPUs > 1 {
            mpSimulators[.GPUSecondary]
                = NBody.Simulation.Facade(type: .GPUSecondary, count: mnBodies, params: m_Params);
            
            if mpSimulators[.GPUSecondary] != nil {
                mnCount++
            }
        }
        
        if mbCPUs {
            mpSimulators[.CPUSingle]
                = NBody.Simulation.Facade(type: .CPUSingle, count: mnBodies, params: m_Params)
            
            if mpSimulators[.CPUSingle] != nil {
                mnCount++
            }
            
            mpSimulators[.CPUMulti]
                = NBody.Simulation.Facade(type: .CPUMulti, count: mnBodies, params: m_Params)
            
            if mpSimulators[.CPUMulti] != nil {
                mnCount++
            }
        }
        
        mnActive = (mbCPUs) ? .CPUSingle : .GPUPrimary
        mpActive = mpSimulators[mnActive]
    }
    
    // Construct a mediator object for GPUs, or CPU and CPUs
    public convenience init(params rParams: NBody.Simulation.Params,
        GPUOnly bGPUOnly: Bool,
        count nCount: Int)
    {
        self.init()
        setDefaults(nCount)
        setCompute(bGPUOnly)
        
        acquire(rParams)
    }
    
    // Active simulator query
    
    // Is single core cpu simulator active?
    public var isCPUSingleCore: Bool {
        return mpActive.isCPUSingleCore
    }
    
    // Is multi-core cpu simulator active?
    public var isCPUMultiCore: Bool {
        return mpActive.isCPUMultiCore
    }
    
    // Is primary gpu simulator active?
    public var isGPUPrimary: Bool {
        return mpActive.isGPUPrimary
    }
    
    // Is secondary (or offline) gpu simulator active?
    public var isGPUSecondary: Bool {
        return mpActive.isGPUSecondary
    }
    
    // Check to see if position was acquired
    public var hasPosition: Bool {
        return mpPosition != nil
    }
    
    // Get the total number of simulators
    public var count: Int {
        return mnCount
    }
    
    // Accessor Methods for the active simulator
    
    // Get the relative performance number
    public var performance: GLdouble {
        return mpActive?.performance ?? 0.0
    }
    
    // Get the updates performance number
    public var updates: GLdouble {
        return mpActive?.updates ?? 0.0
    }
    
    // Pause the current active simulator
    public func pause() {
        if mpActive != nil {
            mpActive!.pause()
        }
    }
    
    // unpause the current active simulator
    public func unpause() {
        if mpActive != nil {
            mpActive.unpause()
        }
    }
    
    // Set the button for the current simulator object
    public func button(selected: Bool,
        position: CGPoint,
        bounds: CGRect) {
            mpActive.button(selected, position: position, bounds: bounds)
    }
    
    // Select the current simulator to use
    public func select(type: NBody.Simulation.Types) {
        if mpSimulators[type] != nil {
            mnActive = type
            mpActive = mpSimulators[mnActive]
            
            println(">> N-body Simulation: Using \"\(mpActive.label)\" simulator with [\(mnBodies)] bodies.")
        } else {
            println(">> ERROR: N-body Simulation: Requested simulator is nil!")
        }
    }
    
    // Select the current simulator to use
    public func select(index: Int) {
        var type: NBody.Simulation.Types
        
        if mbCPUs {
            switch index {
            case 0:
                type = .CPUSingle
                
            case 1:
                type = .CPUMulti
                
            case 3:
                type = .GPUSecondary
                
            case 2:
                fallthrough
            default:
                type = .GPUPrimary
            }
        } else {
            switch index {
            case 1:
                type = .GPUSecondary
                
            case 0:
                fallthrough
            default:
                type = .GPUPrimary
            }
        }
        
        select(type)
    }
    
    // Get position data
    public var position: UnsafeMutablePointer<GLfloat> {
        return mpPosition
    }
    
    // Get the current simulator
    public var simulator: NBody.Simulation.Facade {
        return mpActive
    }
    
    // void update position data
    public func update() {
        let pPosition = mpActive.data()
        
        if pPosition != nil {
            if mpPosition != nil {
                let length = mpActive.dataLength
                mpPosition.dealloc(length)
            }
            
            mpPosition = pPosition
        }
    }
    
    // Reset all the gpu bound simulators
    public func reset() {
        if mpActive != nil {
            if mpPosition != nil {
                let length = mpActive.dataLength
                mpPosition.dealloc(length)
                
                mpPosition = nil
                
                mpActive.data().dealloc(length)
            }
            
            mpActive.resetParams(m_Params)
            
            if    mnActive == .GPUPrimary
                &&  mpSimulators[.GPUSecondary] != nil {
                    mpSimulators[.GPUPrimary]!.invalidate(true)
                    mpSimulators[.GPUSecondary]!.invalidate(false)
            } else if    mnActive == .GPUSecondary
                &&  mpSimulators[.GPUPrimary] != nil {
                    mpSimulators[.GPUPrimary]!.invalidate(false)
                    mpSimulators[.GPUSecondary]!.invalidate(true)
            } else if mnActive == .GPUPrimary {
                mpSimulators[.GPUPrimary]!.invalidate(true)
            }
            
            mpActive.unpause()
        }
    }
}
