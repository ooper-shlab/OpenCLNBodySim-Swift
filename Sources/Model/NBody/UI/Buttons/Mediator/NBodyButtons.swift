//
//  NBodyButtons.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
/*
 <codex>
 <abstract>
 Mediator object for managing buttons associated with N-Body simulator types.
 </abstract>
 </codex>
 */

import Cocoa
import OpenGL.GL

@objc(NBodyButtons)
class NBodyButtons: NSObject {
    
    private var _index: Int
    private var _count: Int
    private var mpButtons: [NBodyButton] = []
    private var mpButton: NBodyButton!
    
    init(count: Int) {
        assert(count > 0)
        
        _index = 0
        _count = count
        
        mpButtons.reserveCapacity(_count)
        
        for _ in 0..<_count {
            mpButtons.append(NBodyButton())
        }
        
        mpButton = mpButtons[_index]
        
    }
    
    var index: Int {
        get {return _index}
        set {
            _index = (0 <= newValue && newValue < _count) ? newValue : 0
            
            mpButton = mpButtons[_index]
        }
    }
    
    var label: String {
        get {return mpButton.label}
        set {
            mpButton.label = newValue
        }
    }
    
    var italic: Bool {
        get {return mpButton.italic}
        set {
            mpButton.italic = newValue
        }
    }
    
    var selected: Bool {
        get {return mpButton.selected}
        set {
            mpButton.selected = newValue
        }
    }
    
    var visible: Bool {
        get {return mpButton.visible}
        set {
            mpButton.visible = newValue
        }
    }
    
    var fontSize: CGFloat {
        get {return mpButton.fontSize}
        set {
            mpButton.fontSize = newValue
        }
    }
    
    var speed: GLfloat {
        get {return mpButton.speed}
        set {
            mpButton.speed = newValue
        }
    }
    
    var origin: CGPoint {
        get {return mpButton.origin}
        set {
            mpButton.origin = newValue
        }
    }
    
    var size: CGSize {
        get {return mpButton.size}
        set {
            mpButton.size = newValue
        }
    }
    
    func acquire() -> Bool {
        return mpButton.acquire()
    }
    
    func toggle() {
        mpButton.toggle()
    }
    
    func draw() {
        mpButton.draw()
    }
    
}