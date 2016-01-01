//
//  NBodySimulationFacade.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
A facade for managing cpu or gpu bound simulators, along with their labeled-button.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension NBody.Simulation {
    public enum Types: Int {
        case CPUSingle = 0
        case CPUMulti
        case GPUPrimary
        case GPUSecondary
        public static let Max = GPUSecondary.rawValue + 1
    }
    
    public class Facade {
        
        deinit {destruct()}
        
        private var mbIsGPU: Bool = false
        private var m_Label: String = ""
        private var mpSimulator: Base!
        private var mnType: Types = Types.CPUSingle
    }
}

//MARK: -
//MARK: Private - Headers

extension NBody.Simulation.Facade {
    //MARK: -
    //MARK: Private - Accessors
    
    // Acquire a label for the gpu bound simulator
    private func setLabel(nDevIndex: Int,
        _ nDevices: Int,
        _ rDevice: String)
    {
        let hw = CF.Query.Hardware.instance
        
        let model = hw.model
        let found = model.rangeOfString("MacPro")
        var label = nDevIndex != 0 ? "Secondary" : "Primary"
        
        let isMacPro = found != nil
        let isDualGPU = nDevices == 2
        
        if isMacPro && isDualGPU && nDevIndex != 0 {
            label = "Primary + \(label)"
        }
        
        m_Label = "SIM: \(label) \(rDevice)"
    }
    
    //MARK: -
    //MARK: Private - Constructors
    
    private func create(nDevIndex: Int,
        _ rProperties: NBody.Simulation.Properties) -> NBody.Simulation.Base
    {
        let pSimulator = NBody.Simulation.GPU(rProperties, nDevIndex)
        
        pSimulator.start()
        
        pSimulator.waitAcquisition()
        
        mbIsGPU = true
        
        setLabel(nDevIndex,
            pSimulator.devices,
            pSimulator.name)
        
        return pSimulator
    }
    
    private func create(bIsThreaded: Bool,
        _ rLabel: String,
        _ rProperties: NBody.Simulation.Properties) -> NBody.Simulation.Base
    {
        
        let pSimulator = NBody.Simulation.CPU(rProperties, true, bIsThreaded)
        
        pSimulator.start()
        
        mbIsGPU = false
        m_Label = "SIM: \(rLabel)"
        
        return pSimulator
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(_ nType: NBody.Simulation.Types,
        _ rProperties: NBody.Simulation.Properties)
    {
        self.init()
        mnType = nType
        m_Label = ""
        
        switch mnType {
        case .CPUSingle:
            mpSimulator = create(false, "Vector Single Core CPU", rProperties)
            
        case .CPUMulti:
            mpSimulator = create(true, "Vector Multi Core CPU", rProperties)
            
        case .GPUSecondary:
            mpSimulator = create(1, rProperties)
            
        case .GPUPrimary:
            fallthrough
        default:
            mpSimulator = create(0, rProperties)
        }
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    private func destruct() {
        if mpSimulator != nil {
            mpSimulator.exit()
            
            mpSimulator = nil
        }
        
    }
    
    //MARK: -
    //MARK: Public - Utilities - Simulator
    
    public func pause() {
        mpSimulator.pause()
    }
    
    public func unpause() {
        mpSimulator.unpause()
    }
    
    public func resetProperties(rProperties: NBody.Simulation.Properties) {
        mpSimulator.resetProperties(rProperties)
    }
    
    public func invalidate(doInvalidate: Bool) {
        mpSimulator.invalidate(doInvalidate)
    }
    
    public func data() -> UnsafeMutablePointer<GLfloat> {
        return mpSimulator.data()
    }
    public var dataLength: Int {    //### needed for dealloc
        return mpSimulator.dataLength
    }
    
    public var simulator: NBody.Simulation.Base {
        return mpSimulator
    }
    
    //MARK: -
    //MARK: Public - Accessors - Quaries
    
    public var isActive: Bool {
        return mpSimulator != nil
    }
    
    public var isPaused: Bool {
        return mpSimulator.isPaused
    }
    
    public var isStopped: Bool {
        return mpSimulator.isStopped
    }
    
    // Is single core cpu simulator active?
    public var isCPUSingleCore: Bool {
        return mnType == .CPUSingle
    }
    
    // Is multi-core cpu simulator active?
    public var isCPUMultiCore: Bool {
        return mnType == .CPUMulti
    }
    
    // Is primary gpu simulator active?
    public var isGPUPrimary: Bool {
        return mnType == .GPUPrimary
    }
    
    // Is secondary (or offline) gpu simulator active?
    public var isGPUSecondary: Bool {
        return mnType == .GPUSecondary
    }
    
    //MARK: -
    //MARK: Public - Accessors - Getters
    
    public func positionInRange(pDst: UnsafeMutablePointer<GLfloat>) {
        mpSimulator.positionInRange(pDst)
    }
    
    public func position(pDst: UnsafeMutablePointer<GLfloat>) {
        mpSimulator.position(pDst)
    }
    
    public func velocity(pDst: UnsafeMutablePointer<GLfloat>) {
        mpSimulator.velocity(pDst)
    }
    
    public var performance: GLdouble {
        return mpSimulator.performance
    }
    
    public var updates: GLdouble {
        return mpSimulator.updates
    }
    
    public var year: GLdouble {
        return mpSimulator.year
    }
    
    public var size: Int {
        return mpSimulator.size
    }
    
    public var label: String {
        return m_Label
    }
    
    public var type: NBody.Simulation.Types {
        return mnType
    }
    
    //MARK: -
    //MARK: Public - Accessors - Setters
    
    public func setRange(min: Int, _ max: Int) {
        mpSimulator.setRange(min, max)
    }
    
    public func setProperties(rProperties: NBody.Simulation.Properties) {
        mpSimulator.setProperties(rProperties)
    }
    
    public func setData(pData: UnsafePointer<GLfloat>) {
        mpSimulator.setData(pData)
    }
    
    public func setPosition(pSrc: UnsafePointer<GLfloat>) {
        mpSimulator.setPosition(pSrc)
    }
    
    public func setVelocity(pSrc: UnsafePointer<GLfloat>) {
        mpSimulator.setVelocity(pSrc)
    }
}
