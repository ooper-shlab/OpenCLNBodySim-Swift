//
//  NBodySimulationFacade.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodySimulationFacade.h
     File: NBodySimulationFacade.mm
 Abstract:
 A facade for managing cpu or gpu bound simulators, along with their labeled-button.

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

extension NBody.Simulation {
    public class Facade {
        
        deinit {destruct()}
        
        private var mbIsGPU: Bool = false
        private var m_Label: String = ""
        private var mpSimulator: Base!
        private var mpButton: Button!
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
        _ nCount: Int,
        _ rParams: NBody.Simulation.Params) -> NBody.Simulation.Base
    {
        let pSimulator = NBody.Simulation.GPU(nbodies: nCount, params: rParams, index: nDevIndex)
        
        var spin = 0
        
        pSimulator.start()
        
        pSimulator.waitAcquisition()
        
        mbIsGPU = true
        
        setLabel(nDevIndex,
            pSimulator.devices,
            pSimulator.name)
        
        return pSimulator
    }
    
    private func create(bIsThreaded: Bool,
        _ nCount: Int,
        _ rLabel: String,
        _ rParams: NBody.Simulation.Params) -> NBody.Simulation.Base
    {
        
        let pSimulator = NBody.Simulation.CPU(nbodies: nCount, params: rParams, vectorized: true, threaded: bIsThreaded)
        
        pSimulator.start()
        
        mbIsGPU = false
        m_Label = "SIM: \(rLabel)"
        
        return pSimulator
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(type nType: NBody.Simulation.Types,
        count nCount: Int,
        params rParams: NBody.Simulation.Params)
    {
        self.init()
        mnType = nType
        m_Label = ""
        mpButton = nil
        
        switch mnType {
        case .CPUSingle:
            mpSimulator = create(false, nCount, "Vector Single Core CPU", rParams)
            
        case .CPUMulti:
            mpSimulator = create(true, nCount, "Vector Multi Core CPU", rParams)
            
        case .GPUSecondary:
            mpSimulator = create(1, nCount, rParams)
            
        case .GPUPrimary:
            fallthrough
        default:
            mpSimulator = create(0, nCount, rParams)
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
    //MARK: Public - Utilities - Button
    public func button(selected: Bool,
        position: CGPoint,
        bounds: CGRect)
    {
        if mpButton == nil {
            mpButton = HUD.Button.Image(bounds: bounds, size: 24.0, italic: false, label: m_Label)
        }
        
        mpButton.draw(selected, position: position, bounds: bounds)
    }
    
    //MARK: -
    //MARK: Public - Utilities - Simulator
    
    public func pause() {
        mpSimulator.pause()
    }
    
    public func unpause() {
        mpSimulator.unpause()
    }
    
    public func resetParams(params: NBody.Simulation.Params) {
        mpSimulator.resetParams(params)
    }
    
    public func invalidate(doInvalidate: Bool) {
        mpSimulator.invalidate(doInvalidate)
    }
    
    public func data() -> UnsafeMutablePointer<GLfloat> {
        return mpSimulator.data()
    }
    public var dataLength: Int {
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
    
    //MARK: -
    //MARK: Public - Accessors - Setters
    
    public func setRange(min: Int, max: Int) {
        mpSimulator.setRange(min, max: max)
    }
    
    public func setParams(params: NBody.Simulation.Params) {
        mpSimulator.setParams(params)
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