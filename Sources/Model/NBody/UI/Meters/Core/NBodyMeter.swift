//
//  NBodyMeter.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
/*
 <codex>
 <abstract>
 A base utility class for managing performance meters.
 </abstract>
 </codex>
 */

import Cocoa
import OpenGL.GL

private let kDefaultSpeed: GLfloat = 0.06

@objc(NBodyMeter)
class NBodyMeter: NSObject {
    
    private var _visible: Bool = true
    var useTimer: Bool = false
    var useHostInfo: Bool = false
    private var _label: String = ""
    var max: Int = 0
    var bound: Int = 0
    var speed: GLfloat = kDefaultSpeed
    private var _value: GLdouble = 0.0
    private var _frame: CGSize = NSMakeSize(0.0, 0.0)
    var point: CGPoint = NSMakePoint(0.0, 0.0)
    
    private var mbStart: Bool = false
    
    private var mnPosition: GLfloat = 0.0
    
    private var mpMeter: HUD.Meter.Image?
    private var mpTimer: HUD.Meter.Timer?
    
    private var mpLoad: CF.CPU.Load?
    
    override init() {
        
        _visible   = true
        useTimer    = false
        useHostInfo = false
        
        speed = kDefaultSpeed
        bound = 0
        max   = 0
        _frame = NSMakeSize(0.0, 0.0)
        point = NSMakePoint(0.0, 0.0)
        _label = ""
        
        mbStart    = false
        mnPosition = 0.0
        
        mpMeter = nil
        mpTimer = nil
        mpLoad  = nil
        
        super.init()
    }
    
    //+ (instancetype) meter
    //{
    //    return [[[NBodyMeter allocWithZone:[self zone]] init] autorelease];
    //} // meterWithBound
    
    var frame: CGSize {
        get {return _frame}
        set {
            if (newValue.width > 0.0) && (newValue.height > 0.0) {
                _frame = newValue
            }
        }
    }
    
    var visible: Bool {
        get {return _visible}
        set {
            _visible = newValue
        }
    }
    
    var label: String {
        get {return _label}
        set {
            if !newValue.isEmpty {
                _label = newValue
            }
        }
    }
    
    var value: GLdouble {
        set {
            mpMeter?.target = newValue
        }
        
        get {
            return mpMeter?.target ?? 0.0
        }
    }
    
    func toggle() {
        _visible = !_visible
    }
    
    func acquire() -> Bool {
        if useHostInfo {
            mpLoad = CF.CPU.Load()
            
        }
        
        if useTimer {
            mpTimer = HUD.Meter.Timer(20, doAscend: false)
            
        }
        
        mpMeter = HUD.Meter.Image(width: bound.i, height: bound.i, max: max, legend: _label)
        
        return true
    }
    
    func reset() {
        if useTimer {
            mpTimer?.reset()
        }
    }
    
    func update() {
        if useTimer {
            if !mbStart {
                mpTimer?.start()
                
                mbStart = true
            } else {
                mpTimer?.stop()
                mpTimer?.update()
                
                mpMeter?.target = mpTimer?.persecond ?? 0.0
                
                mpTimer?.reset()
            }
        }
        
        if useHostInfo {
            let nPercentage = mpLoad?.percentage ?? 0.0
            
            let nTargetSrc = mpMeter?.target ?? 0.0
            let nTargetDst = 0.01 * nPercentage + 0.99 * nTargetSrc
            
            mpMeter?.target = nTargetDst
        }
        
        mpMeter?.update()
    }
    
    func draw() {
        glMatrixMode(GL_PROJECTION.ui)
        
        GLM.load(true, GLM.ortho(0.0, _frame.width.f, 0.0, _frame.height.f, -1.0, 1.0))
        
        GLM.identity(GL_MODELVIEW.ui)
        
        if _visible {
            if mnPosition <= GLM.kHalfPi.f - speed {
                mnPosition += speed
            }
        } else if mnPosition > 0.0 {
            mnPosition -= speed
        }
        
        let y = 416.0 * (1.0 - sin(mnPosition))
        
        GLM.load(true, GLM.translate(0.0, y, 0.0))
        
        if mnPosition > 0.0 {
            mpMeter?.draw(point.x.f, _frame.height.f - point.y.f)
        }
        
        GLM.identity(GL_MODELVIEW.ui)
    }
    
}
