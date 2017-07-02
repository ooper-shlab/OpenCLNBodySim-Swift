//
//  NBodySimulationMediator.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation {
    open class Mediator {
        
        fileprivate var mbCPUs: Bool = false
        fileprivate var mnParticles: Int = 0
        fileprivate var mnSize: Int = 0
        fileprivate var mnCount: Int = 0
        fileprivate var mnGPUs: Int = 0
        fileprivate var mpPosition: UnsafeMutablePointer<GLfloat>? = nil
        fileprivate var mnActive: Types = Types.cpuMulti
        fileprivate var m_Properties: Properties = Properties()
        fileprivate var mpSimulators: [NBody.Simulation.Types: Facade] = [:]
        fileprivate var mpActive: Facade!
    }
}

private let kNBodyMaxDeviceCount = 128

extension NBody {
    // Get the number of coumpute device counts
    fileprivate static func getComputeDeviceCount(_ type: cl_device_type) -> Int {
        var ids: [cl_device_id?] = Array(repeating: nil, count: kNBodyMaxDeviceCount)
        
        var count: cl_uint = 0
        
        let err = clGetDeviceIDs(nil, type, cl_uint(kNBodyMaxDeviceCount), &ids, &count)
        
        if err != CL_SUCCESS {
            print(">> ERROR: NBody Simulation Mediator - Failed acquiring maximum device count!")
        }
        
        return count.l
    }
}

extension NBody.Simulation.Mediator {
    // Set the defaults for simulator compute
    public func setCompute(_ rProperties: NBody.Simulation.Properties) {
        mnGPUs = NBody.getComputeDeviceCount(CL_DEVICE_TYPE_GPU.ull)
        
        if !rProperties.mbIsGPUOnly {
            mbCPUs = NBody.getComputeDeviceCount(CL_DEVICE_TYPE_CPU.ull) > 0
        }
        
        mnActive = (mbCPUs)
            ? NBody.Simulation.Types.cpuSingle
            : NBody.Simulation.Types.gpuPrimary
    }
    
    // Initialize all instance variables to their default values
    public func setDefaults(_ rProperties: NBody.Simulation.Properties) {
        
        mnParticles = rProperties.mnParticles
        mnSize   = 4 * mnParticles * GLM.Size.kFloat
        
        mnCount    = 0
        mnGPUs     = 0
        mbCPUs     = false
        mpActive   = nil
        mpPosition = nil
        
        mpSimulators = [:]
    }
    
    // Acquire all simulators
    public func acquire(_ rProperties: NBody.Simulation.Properties) {
        m_Properties = rProperties;
        
        if mnGPUs > 0 {
            mpSimulators[.gpuPrimary]
                = NBody.Simulation.Facade(.gpuPrimary, rProperties)
            
            if mpSimulators[.gpuPrimary] != nil {
                mnCount += 1
            }
        }
        
        if mnGPUs > 1 {
            mpSimulators[.gpuSecondary]
                = NBody.Simulation.Facade(.gpuSecondary, rProperties)
            
            if mpSimulators[.gpuSecondary] != nil {
                mnCount += 1
            }
        }
        
        if mbCPUs {
            mpSimulators[.cpuSingle]
                = NBody.Simulation.Facade(.cpuSingle, rProperties)
            
            if mpSimulators[.cpuSingle] != nil {
                mnCount += 1
            }
            
            mpSimulators[.cpuMulti]
                = NBody.Simulation.Facade(.cpuMulti, rProperties)
            
            if mpSimulators[.cpuMulti] != nil {
                mnCount += 1
            }
        }
        
        mnActive = (mbCPUs) ? .cpuSingle : .gpuPrimary
        mpActive = mpSimulators[mnActive]
    }
    
    // Construct a mediator object for GPUs, or CPU and CPUs
    public convenience init(_ rProperties: NBody.Simulation.Properties)
    {
        self.init()
        setDefaults(rProperties)
        setCompute(rProperties)
        
        acquire(rProperties)
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
    
    // Label for a type of simulator
    public func label(_ nType: NBody.Simulation.Types) -> String? {
        return mpSimulators[nType]?.label
    }
    
    // Active simulator type
    public var type: NBody.Simulation.Types {
        return mpActive.type
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
    
    // Select the current simulator to use
    public func select(_ type: NBody.Simulation.Types) {
        if mpSimulators[type] != nil {
            mnActive = type
            mpActive = mpSimulators[mnActive]
            
            print(">> N-body Simulation: Using \"\(mpActive.label)\" simulator with [\(mnParticles)] bodies.")
        } else {
            print(">> ERROR: N-body Simulation: Requested simulator is nil!")
        }
    }
    
    // Select the current simulator to use
    public func select(_ index: Int) {
        var type: NBody.Simulation.Types
        
        if mbCPUs {
            switch index {
            case 0:
                type = .cpuSingle
                
            case 1:
                type = .cpuMulti
                
            case 3:
                type = .gpuSecondary
                
            case 2:
                fallthrough
            default:
                type = .gpuPrimary
            }
        } else {
            switch index {
            case 1:
                type = .gpuSecondary
                
            case 0:
                fallthrough
            default:
                type = .gpuPrimary
            }
        }
        
        select(type)
    }
    
    // Get position data
    public var position: UnsafeMutablePointer<GLfloat> {
        return mpPosition!
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
                mpPosition?.deallocate(capacity: length)
            }
            
            mpPosition = pPosition
        }
    }
    
    // Reset all the gpu bound simulators
    public func reset() {
        if mpActive != nil {
            if mpPosition != nil {
                let length = mpActive.dataLength
                mpPosition?.deallocate(capacity: length)
                
                mpPosition = nil
                
                mpActive.data()?.deallocate(capacity: length)
            }
            
            mpActive.resetProperties(m_Properties)
            
            if    mnActive == .gpuPrimary
                &&  mpSimulators[.gpuSecondary] != nil {
                    mpSimulators[.gpuPrimary]!.invalidate(true)
                    mpSimulators[.gpuSecondary]!.invalidate(false)
            } else if    mnActive == .gpuSecondary
                &&  mpSimulators[.gpuPrimary] != nil {
                    mpSimulators[.gpuPrimary]!.invalidate(false)
                    mpSimulators[.gpuSecondary]!.invalidate(true)
            } else if mnActive == .gpuPrimary {
                mpSimulators[.gpuPrimary]!.invalidate(true)
            }
            
            mpActive.unpause()
        }
    }
}
