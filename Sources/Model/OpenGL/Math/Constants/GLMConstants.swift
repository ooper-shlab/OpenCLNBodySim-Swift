//
//  GLMConstants.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
OpenGL numeric constants.
</abstract>
</codex>
 */

import OpenGL

extension GLM {
    public static let kRadians  = kPi / 180.0
    
    public static let kPi       = M_PI
    public static let kTwoPi    = 2.0 * kPi
    public static let kHalfPi   = 0.5 * kPi
    public static let kPiDiv4   = 0.25 * kPi
    public static let kPiDiv6   = kPi / 6.0
    public static let k3PiDiv4  = (3.0 * kPi) / 4.0
    public static let k4PiDiv3  = (4.0 * kPi) / 3.0
    public static let k180DivPi = 180.0 / kPi
    public static let kPiDiv180 = kPi / 180.0
    public static let k360DivPi = 360.0 / kPi
    public static let kPiDiv360 = kPi / 360.0
}