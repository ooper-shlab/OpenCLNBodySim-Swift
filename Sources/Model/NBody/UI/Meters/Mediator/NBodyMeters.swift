//
//  NBodyMeters.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
/*
 <codex>
 <abstract>
 Mediator object for managing multiple hud objects for n-body simulators.
 </abstract>
 </codex>
 */

import Cocoa
import OpenGL.GL

@objc(NBodyMeters)
class NBodyMeters: NSObject {
    
    //MARK: -
    
    private var _index: NBody.MeterType
    private var _count: Int
    private var mpMeters: [NBodyMeter] = []
    private var mpMeter: NBodyMeter!
    
    init(count: Int) {
        assert(count > 0)
        
        _index = NBody.MeterType(rawValue: 0)!
        _count = count
        super.init()
        
        mpMeters.reserveCapacity(_count)
        
        for _ in 0..<_count {
            mpMeters.append(NBodyMeter())
        }
        
        mpMeter = mpMeters[_index.rawValue]
        
    }
    
    func reset() {
        for pMeter in mpMeters {
            pMeter.value = 0.0
            
            pMeter.reset()
        }
    }
    
    func resize(size: NSSize) {
        for pMeter in mpMeters {
            pMeter.frame = size
        }
    }
    
    func show(doShow: Bool) {
        for pMeter in mpMeters {
            pMeter.visible = doShow
        }
    }
    
    func acquire() -> Bool {
        return mpMeter.acquire()
    }
    
    func toggle() {
        mpMeter.toggle()
    }
    
    func update() {
        mpMeter.update()
    }
    
    func draw() {
        mpMeter.draw()
    }
    
    func draw(positions: [NSPoint]) {
        
        for (i, position) in positions.enumerate() {
            let pMeter = mpMeters[i]
            
            pMeter.point = position
            
            pMeter.update()
            pMeter.draw()
            
        }
    }
    
    var bound: Int {
        get {return mpMeter.bound}
        set {
            mpMeter.bound = newValue
        }
    }
    
    var frame: CGSize {
        get {return mpMeter.frame}
        set {
            mpMeter.frame = newValue
        }
    }
    
    var useTimer: Bool {
        get {return mpMeter.useTimer}
        set {
            mpMeter.useTimer = newValue
        }
    }
    
    var useHostInfo: Bool {
        get {return mpMeter.useHostInfo}
        set {
            mpMeter.useHostInfo = newValue
        }
    }
    
    var index: NBody.MeterType {
        get {return _index}
        set {
            _index = (newValue.rawValue < _count) ? newValue : NBody.MeterType(rawValue: 0)!
            
            mpMeter = mpMeters[_index.rawValue]
        }
    }
    
    var visible: Bool {
        get {return mpMeter.visible}
        set {
            mpMeter.visible = newValue
        }
    }
    
    var label: String {
        get {return mpMeter.label}
        set {
            mpMeter.label = newValue
        }
    }
    
    var max: Int {
        get {return mpMeter.max}
        set {
            mpMeter.max = newValue
        }
    }
    
    var point: CGPoint {
        get {return mpMeter.point}
        set {
            mpMeter.point = newValue
        }
    }
    
    var speed: GLfloat {
        get {return mpMeter.speed}
        set {
            mpMeter.speed = newValue
        }
    }
    
    var value: GLdouble {
        get {return mpMeter.value}
        set {
            mpMeter.value = newValue
        }
    }
    
}