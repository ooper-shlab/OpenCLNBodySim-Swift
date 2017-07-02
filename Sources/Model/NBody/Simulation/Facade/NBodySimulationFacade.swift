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
        case cpuSingle = 0
        case cpuMulti
        case gpuPrimary
        case gpuSecondary
        public static let Max = gpuSecondary.rawValue + 1
    }
    
    open class Facade {
        
        deinit {destruct()}
        
        fileprivate var mbIsGPU: Bool = false
        fileprivate var m_Label: String = ""
        fileprivate var mpSimulator: Base!
        fileprivate var mnType: Types = Types.cpuSingle
    }
}

//MARK: -
//MARK: Private - Headers

extension NBody.Simulation.Facade {
    //MARK: -
    //MARK: Private - Accessors
    
    // Acquire a label for the gpu bound simulator
    private func setLabel(_ nDevIndex: Int,
        _ nDevices: Int,
        _ rDevice: String)
    {
        let hw = CF.Query.Hardware.instance
        
        let model = hw.model
        let found = model.range(of: "MacPro")
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
    
    private func create(_ nDevIndex: Int,
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
    
    private func create(_ bIsThreaded: Bool,
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
        case .cpuSingle:
            mpSimulator = create(false, "Vector Single Core CPU", rProperties)
            
        case .cpuMulti:
            mpSimulator = create(true, "Vector Multi Core CPU", rProperties)
            
        case .gpuSecondary:
            mpSimulator = create(1, rProperties)
            
        case .gpuPrimary:
            fallthrough
        default:
            mpSimulator = create(0, rProperties)
        }
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    fileprivate func destruct() {
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
    
    public func resetProperties(_ rProperties: NBody.Simulation.Properties) {
        mpSimulator.resetProperties(rProperties)
    }
    
    public func invalidate(_ doInvalidate: Bool) {
        mpSimulator.invalidate(doInvalidate)
    }
    
    public func data() -> UnsafeMutablePointer<GLfloat>? {
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
        return mnType == .cpuSingle
    }
    
    // Is multi-core cpu simulator active?
    public var isCPUMultiCore: Bool {
        return mnType == .cpuMulti
    }
    
    // Is primary gpu simulator active?
    public var isGPUPrimary: Bool {
        return mnType == .gpuPrimary
    }
    
    // Is secondary (or offline) gpu simulator active?
    public var isGPUSecondary: Bool {
        return mnType == .gpuSecondary
    }
    
    //MARK: -
    //MARK: Public - Accessors - Getters
    
    public func positionInRange(_ pDst: UnsafeMutablePointer<GLfloat>) {
        mpSimulator.positionInRange(pDst)
    }
    
    public func position(_ pDst: UnsafeMutablePointer<GLfloat>) {
        mpSimulator.position(pDst)
    }
    
    public func velocity(_ pDst: UnsafeMutablePointer<GLfloat>) {
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
    
    public func setRange(_ min: Int, _ max: Int) {
        mpSimulator.setRange(min, max)
    }
    
    public func setProperties(_ rProperties: NBody.Simulation.Properties) {
        mpSimulator.setProperties(rProperties)
    }
    
    public func setData(_ pData: UnsafePointer<GLfloat>) {
        mpSimulator.setData(pData)
    }
    
    public func setPosition(_ pSrc: UnsafePointer<GLfloat>) {
        mpSimulator.setPosition(pSrc)
    }
    
    public func setVelocity(_ pSrc: UnsafePointer<GLfloat>) {
        mpSimulator.setVelocity(pSrc)
    }
}
