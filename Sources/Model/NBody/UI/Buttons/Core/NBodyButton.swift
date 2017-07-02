//
//  NBodyButton.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// Utility  class for managing a button associated with N-Body simulator.
// </abstract>
// </codex>
// */

//MARK: -
//MARK: Private - Headers

import Cocoa
import OpenGL.GL

@objc(NBodyButton)
class NBodyButton: NSObject {
    
    private(set) var bounds: CGRect
    private(set) var position: CGPoint
    
    var selected: Bool
    var italic: Bool
    var fontSize: CGFloat
    var origin: CGPoint
    var speed: GLfloat
    
    private var _visible: Bool
    private var _size: CGSize
    private var _label: String
    
    var mpButton: HUD.Button.Image?
    
    override init() {
        
        mpButton    = nil
        _label      = ""
        _visible  = true
        selected = false
        italic   = false
        fontSize   = 24.0
        bounds     = NSMakeRect(0.0, 0.0, 0.0, 0.0)
        _size       = NSMakeSize(0.0, 0.0)
        position   = NSMakePoint(0.0, 0.0)
        origin     = CGPoint(x: 0.0, y: (_visible ? GLM.kHalfPi.g : 0.0))
        speed      = NBody.Defaults.kSpeed.f
        
        super.init()
    }
    
    //+ (instancetype) button
    //{
    //    return [[[NBodyButton allocWithZone:[self zone]] init] autorelease];
    //} // button
    
    var visible: Bool {
        get {return _visible}
        set {
            _visible = newValue
            origin.y  = _visible ? GLM.kHalfPi.g : 0.0
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
    
    var size: CGSize {
        get {return _size}
        set {
            _size = newValue
            bounds = CGRect(x: 0.75 * _size.width - 0.5 * NBody.Button.kWidth.g,
                y: NBody.Button.kSpacing.g,
                width: NBody.Button.kWidth.g,
                height: NBody.Button.kHeight.g)
        }
    }
    
    @discardableResult
    func acquire() -> Bool {
        if mpButton == nil {
            mpButton = HUD.Button.Image(bounds,
                fontSize,
                italic,
                _label)
        }
        
        return mpButton != nil
    }
    
    func toggle() {
        _visible = !_visible
    }
    
    func draw() {
        guard let mpButton = mpButton else {return}
        if _visible {
            if origin.y <= (GLM.kHalfPi.g - speed.g) {
                origin.y += speed.g
            }
        } else if origin.y > 0.0 {
            origin.y -= speed.g
        }
        
        let x = -NBody.Button.kWidth.g * sin(origin.x)
        let y = 100.0 * (sin(origin.y) - 1.0)
        
        position = CGPoint(x: x, y: y)
        
        mpButton.draw(selected, position, bounds)
    }
    
}
