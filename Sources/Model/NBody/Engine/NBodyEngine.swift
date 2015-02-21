//
//  NBodyEngine.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodyEngine.h
     File: NBodyEngine.mm
 Abstract:
 These methods performs an NBody simulation which calculates a gravity field
 and corresponding velocity and acceleration contributions accumulated
 by each body in the system from every other body.  This example
 also shows how to mitigate computation between all available devices
 including CPU and GPU devices, as well as a hybrid combination of both,
 using separate threads for each simulator.

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

extension NBody {
    public class Engine {
        private init() {}
        
        private var mbWaitingForData: Bool = false
        private var mbShowHUD: Bool = false
        private var mbShowDock: Bool = false
        private var mbIsRotating: Bool = false
        private var mbReduce: Bool = false
        private var mbIsGPUOnly: Bool = false
        
        private var mpMeters: Meters!
        
        private var mpMediator: Simulation.Mediator!
        private var mpVisualizer: Simulation.Visualizer!
        private var m_ActiveParams: Simulation.Params = Simulation.Params()
        
        private var mnSimulatorIndex: Int = 0
        private var mnSimulatorCount: Int = 0
        private var mnBodies: Int = 0
        private var mnActiveDemo: Int = 0
        private var mnViewDistance: GLdouble = 0
        private var mnHudPosition: GLfloat = 0
        private var mnClearColor: GLfloat = 0
        private var mnStarScale: GLfloat = 0
        private var mnDockSpeed: GLfloat = 0
        private var mnWidowWidth: GLsizei = 0
        private var mnWidowHeight: GLsizei = 0
        
        private var m_FrameSz: CGSize = CGSize()
        private var m_MousePt: CGPoint = CGPoint()
        private var m_DockPt: CGPoint = CGPoint()
        private var m_RotationPt: CGPoint = CGPoint()
        private var m_ButtonRt: CGRect = CGRect()
    }
}

//MARK: -
//MARK: Private - Utilities - Reset/Restart

extension NBody.Engine {
    private func reset(index: Int) {
        mpVisualizer.stopRotation()
        mpVisualizer.setRotationSpeed(0.0)
        
        mpMediator.reset()
        mpVisualizer.reset(index)
    }
    
    private func restart() {
        mpVisualizer.setViewRotation(m_RotationPt)
        mpVisualizer.setViewZoom(GLfloat(mnViewDistance))
        mpVisualizer.setViewTime(0.0)
        mpVisualizer.setIsResetting(true)
        mpVisualizer.stopRotation()
    }
    
    //MARK: -
    //MARK: Private - Utilities - Renderers
    
    private func renderMeters() {
        mpMeters.update()
        
        mpMeters.set(NBody.MeterPerf, value: mpMediator.performance)
        mpMeters.set(NBody.MeterUpdates, value: mpMediator.updates)
        
        mpMeters.setPosition(mnHudPosition)
        
        mpMeters.draw()
    }
    
    private func renderDock() {
        if mbShowDock {
            if m_DockPt.y <= GLM.kHalfPi.g - mnDockSpeed.g {
                m_DockPt.y += mnDockSpeed.g
            }
        } else if m_DockPt.y > 0.0 {
            m_DockPt.y -= mnDockSpeed.g
        }
        
        let x = -NBody.Button.kWidth * sinf(m_DockPt.x.f)
        let y = 100.0 * (sinf(m_DockPt.y.f) - 1.0)
        
        let position = CGPointMake(x.g, y.g)
        
        mpMediator.button(true, position: position, bounds: m_ButtonRt)
    }
    
    private func renderStars() {
        let pPosition = mpMediator.position
        
        mpVisualizer.draw(pPosition)
    }
    
    private func renderHUD() {
        glBlendFunc(GL_ONE.ui, GL_ONE_MINUS_SRC_ALPHA.ui)
        glEnable(GL_BLEND.ui)
        
        renderMeters()
        renderDock()
        
        glDisable(GL_BLEND.ui)
    }
    
    private func render() {
        mpMediator?.update()
        
        glClearColor(mnClearColor, mnClearColor, mnClearColor, 1.0)
        
        if mnClearColor > 0.0 {
            mnClearColor -= 0.05
        }
        
        glClear(GL_COLOR_BUFFER_BIT.ui)
        
        if !(mpMediator?.hasPosition ?? false) {
            if mbWaitingForData {
                CGLFlushDrawable(CGLGetCurrentContext())
            }
        } else {
            mbWaitingForData = false
            
            glClear(GL_COLOR_BUFFER_BIT.ui)
            
            renderStars()
            renderHUD()
            
            CGLFlushDrawable(CGLGetCurrentContext())
        }
        glFinish()
    }
    
    //MARK: -
    //MARK: Private - Utilities - Selection
    
    private func nextSimulator() {
        mbWaitingForData = true
        
        mnSimulatorIndex++
        
        if mnSimulatorIndex >= mnSimulatorCount {
            mnSimulatorIndex = 0
        }
        
        mpMediator.pause()
        mpMediator.select(mnSimulatorIndex)
        mpMediator.reset()
    }
    
    private func nextDemo() {
        mnActiveDemo = (mnActiveDemo + 1) % NBody.Simulation.Demo.kParams.count
        
        reset(mnActiveDemo)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Swapping
    
    private func swapVisualizer() {
        render()
        
        mbWaitingForData = true
        
        mpVisualizer.reset(mnActiveDemo)
    }
    
    private func swapSimulators() {
        render()
        
        nextSimulator()
        
        mpVisualizer.reset(mnActiveDemo)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Intervals
    
    private func sync(doSync: Bool) {
        let pContext = CGLGetCurrentContext()
        
        var sync: GLint = doSync ? 1 : 0
        
        CGLSetParameter(pContext, kCGLCPSwapInterval, &sync)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Acquires
    
    private func simulators(nBodies: Int) -> Bool {
        mnBodies = mbReduce ? NBody.Bodies.kCount : nBodies
        
        mpMediator = NBody.Simulation.Mediator(params: m_ActiveParams, GPUOnly: mbIsGPUOnly, count: mnBodies)
        
        mnSimulatorIndex = 0
        mnSimulatorCount = mpMediator.count
        
        mpMediator.reset()
        mpVisualizer.reset(mnActiveDemo)
        
        return mnSimulatorCount != 0
    }
    
    private func hud(nLength: Int) -> Bool {
        mpMeters = NBody.Meters(length: nLength)
        
        mpMeters.set(NBody.MeterFrames, size: 120)
        mpMeters.set(NBody.MeterUpdates, size: 120)
        mpMeters.set(NBody.MeterPerf, size: 120/*1400*/)
        
        mpMeters.set(NBody.MeterFrames, label: "Frames/sec")
        mpMeters.set(NBody.MeterUpdates, label: "Updates/sec")
        mpMeters.set(NBody.MeterPerf, label: "Relative Perf")
        
        mpMeters.setFrame(m_FrameSz)
        
        return mpMeters.finalize()
    }
    
    //MARK: -
    //MARK: Privale - Utilitie - Demo Selection
    
    private func setDemo(nCommand: GLubyte) {
        let demo = Int(nCommand - GLubyte("0"))
        
        if demo < NBody.Simulation.Demo.kParams.count {
            mnActiveDemo = demo
            
            reset(mnActiveDemo)
        }
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(starScale nStarScale: GLfloat,
        activeDemo nActiveDemo: Int)
    {
        self.init()
        
        mbReduce          = false
        mbShowHUD         = true
        mbShowDock        = true
        mbIsGPUOnly       = false
        mbWaitingForData  = true
        mbIsRotating      = true
        mnSimulatorIndex  = 0
        mnSimulatorCount  = 0
        mnActiveDemo      = nActiveDemo
        m_ActiveParams    = NBody.Simulation.Demo.kParams[mnActiveDemo]
        mnHudPosition     = mbShowHUD ? GLM.kHalfPi.f : 0.0
        mnStarScale       = nStarScale
        mnDockSpeed       = NBody.Defaults.kSpeed
        mnViewDistance    = 30.0
        mnClearColor      = 1.0
        mnWidowWidth      = GLsizei(NBody.Window.kWidth)
        mnWidowHeight     = GLsizei(NBody.Window.kHeight)
        m_FrameSz         = CGSizeMake(NBody.Window.kWidth.g, NBody.Window.kHeight.g)
        m_DockPt          = CGPointMake(0.0, (mbShowDock ? GLM.kHalfPi.g : 0.0))
        m_MousePt         = CGPointMake(0.0, 0.0)
        m_RotationPt      = CGPointMake(0.0, 0.0)
        m_ButtonRt        = CGRectMake(0.0, 0.0, 0.0, 0.0)
    }
    
    //MARK: -
    //MARK: Public - Destructor
    //
    //NBody::Engine::~Engine()
    //{
    //    if(mpMeters != nullptr)
    //    {
    //        delete mpMeters;
    //
    //        mpMeters = nullptr;
    //    } // if
    //
    //    if(mpVisualizer != nullptr)
    //    {
    //        delete mpVisualizer;
    //
    //        mpVisualizer = nullptr;
    //    } // if
    //
    //    if(mpMediator != nullptr)
    //    {
    //        delete mpMediator;
    //
    //        mpMediator = nullptr;
    //    } // if
    //
    //    mnSimulatorCount = 0;
    //    mnSimulatorIndex = 0;
    //} // Destructor
    
    //MARK: -
    //MARK: Public - Utilities - Finalize
    
    public func finalize(nBodies: Int = NBody.Bodies.kCount) -> Bool {
        var bSuccess = nBodies != 0
        
        if bSuccess {
            sync(true)
            
            mpVisualizer = NBody.Simulation.Visualizer(bodies: nBodies)
            
            bSuccess = mpVisualizer.isValid
            
            if bSuccess {
                mpVisualizer.setFrame(m_FrameSz)
                mpVisualizer.setStarScale(mnStarScale)
                mpVisualizer.setStarSize(NBody.Star.kSize)
                mpVisualizer.setRotationChange(NBody.Defaults.kRotationDelta)
                
                bSuccess = simulators(nBodies)
                    && hud(NBody.Defaults.kMeterSize)
            }
        }
        
        return bSuccess
    }
    
    //MARK: -
    //MARK: Public - Utilities - Draw
    
    public func draw() {
        render()
    }
    
    //MARK: -
    //MARK: Public - Utilities - Events
    
    public func resize(rFrame: CGRect) {
        if rFrame.size.width >= CGFloat(NBody.Window.kWidth) && rFrame.size.height >= CGFloat(NBody.Window.kHeight) {
            mnWidowWidth  = GLint(rFrame.size.width + 0.5)
            mnWidowHeight = GLint(rFrame.size.height + 0.5)
            
            m_FrameSz = rFrame.size
            
            m_ButtonRt = CGRectMake(0.75 * m_FrameSz.width - 0.5 * NBody.Button.kWidth.g,
                NBody.Button.kSpacing.g,
                NBody.Button.kWidth.g,
                NBody.Button.kHeight.g)
            
            if mpVisualizer != nil {
                mpVisualizer.setFrame(m_FrameSz)
            }
            
            if mpMeters != nil {
                mpMeters.setFrame(m_FrameSz)
            }
        }
    }
    
    public func run(nCommand: GLubyte) {
        switch UnicodeScalar(nCommand) {
        case "e":
            mpVisualizer.toggleEarthView()
            
        case "r":
            mpVisualizer.toggleRotation()
            
        case "R":
            restart()
            
        case "n":
            nextDemo()
            
        case "0"..."9":
            setDemo(nCommand)
            
        case "h":
            mpMeters.toggle()
            
        case "d":
            mbShowDock = !mbShowDock
            
        case "u":
            mpMeters.toggle(type: NBody.MeterUpdates)
            
        case "f":
            mpMeters.toggle(type: NBody.MeterFrames)
            
        case "s":
            swapSimulators()
            
        case "g":
            swapVisualizer()
            
        default:
            break
        }
    }
    
    public func move(point: CGPoint) {
        if mbIsRotating {
            m_RotationPt.x += (point.x - m_MousePt.x) * 0.2
            m_RotationPt.y += (point.y - m_MousePt.y) * 0.2
            
            mpVisualizer.setRotation(m_RotationPt)
            
            m_MousePt = point
        }
    }
    
    public func click(nState: Int, point: CGPoint) {
        let pos = CGPointMake(point.x, m_FrameSz.height - point.y)
        let wmax = 0.75 * m_FrameSz.width
        let wmin = 0.5 * NBody.Button.kWidth.g
        
        if nState == NBody.Mouse.Button.kDown
            && pos.y <= (2.0 * NBody.Button.kHeight).g
            && pos.x >= (wmax - wmin)
            && pos.x <= (wmax + wmin) {
                swapSimulators()
        }
    }
    
    public func scroll(nDelta: GLfloat) {
        mpVisualizer.setViewDistance(nDelta)
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public func setActiveDemo(nActiveDemo: Int) {
        mnActiveDemo = nActiveDemo
        m_ActiveParams = NBody.Simulation.Demo.kParams[mnActiveDemo]
    }
    
    public func setFrame(rFrame: CGRect) {
        if rFrame.size.width >= NBody.Window.kWidth.g && rFrame.size.height >= NBody.Window.kHeight.g {
            mnWidowWidth  = GLint(rFrame.size.width + 0.5)
            mnWidowHeight = GLint(rFrame.size.height + 0.5)
            
            m_FrameSz = rFrame.size
            
            m_ButtonRt = CGRectMake(0.75 * m_FrameSz.width - 0.5 * NBody.Button.kWidth.g,
                NBody.Button.kSpacing.g,
                NBody.Button.kWidth.g,
                NBody.Button.kHeight.g)
        }
    }
    
    public func setToReduce(bReduce: Bool) {
        mbReduce = bReduce
    }
    
    public func setUserGPU(bIsGPUOnly: Bool) {
        mbIsGPUOnly = bIsGPUOnly
    }
    
    public func setShowHUD(bShow: Bool) {
        mbShowHUD = bShow
        mnHudPosition = mbShowHUD ? GLM.kHalfPi.f : 0.0
    }
    
    public func setShowDock(bShow: Bool) {
        mbShowDock = bShow
        m_DockPt.y = mbShowDock ? GLM.kHalfPi.g : 0.0
    }
    
    public func setClearColor(nColor: GLfloat) {
        mnClearColor = nColor
    }
    
    public func setDockSpeed(nSpeed: GLfloat) {
        mnDockSpeed = nSpeed
    }
    
    public func setViewDistance(nDistance: GLdouble) {
        mnViewDistance = nDistance
    }
}
