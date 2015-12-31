//
//  HUD.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//

import Cocoa
import OpenGL
import OpenGL.GL

public enum HUD {
    //MARK: -
    //MARK: Private - Constants
    //see. HUDMeterImage.mm, HUDButton.mm
    
    static let BitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue
    
    static let Ticks           = 8
    static let SubTicks        = 4
    static let NeedleThickness = 12
    static let Offscreen       = 5000
    
    static let BitsPerComponent = 8
    static let SamplesPerPixel  = 4
    
    static let CenterX: GLfloat = 0.5
    static let CenterY: GLfloat = 0.5
    static let LegendWidth: GLfloat  = 256.0
    static let LegendHeight: GLfloat = 64.0
    static let ValueWidth: GLfloat   = 128.0
    static let ValueHeight: GLfloat  = 64.0
}
