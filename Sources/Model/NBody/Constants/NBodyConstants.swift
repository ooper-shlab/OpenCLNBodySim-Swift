//
//  NBodyConstants.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Common constant for NBody simulation.
</abstract>
</codex>
 */

import OpenGL

extension NBody {
    public struct Mouse {
        public struct Button {
            public static let kLeft: Int = 0
            public static let kDown: Int = 1
            public static let kUp: Int = 0
        }
        
        public struct Wheel {
            public static let kDown: Int = -1
            public static let kUp: Int = 1
        }
    }
    
    public struct Button {
        public static let kWidth = 1000.0
        public static let kHeight = 48.0
        public static let kSpacing = 32.0
    }
    
    public struct Scale {
        public static let kTime = 0.4
        public static let kSoftening = 1.0
    }
    
    public struct Window {
        public static let kWidth = 800.0
        public static let kHeight = 500.0
    }
    
    public struct Particles {
        public static let kCountMax: Int = 32768
        public static let kCountMin: Int = kCountMax / 4
        public static let kCount: Int = kCountMax
    }
    
    public struct Star {
        public static let kSize = 4.0
        public static let kScale = 1.0
    }
    
    public struct Defaults {
        public static let kSpeed = 0.06
        public static let kRotationDelta = 0.06
        public static let kScrollZoomSpeed = 0.5
        public static let kViewDistance = 30.0
        public static let kMeterSize: Int = 300
    }
}

extension NBody {
    public enum Config: Int {
        case Random = 0
        case Shell
        case Expand
        case MWM31
        
        static let Count = MWM31.rawValue + 1
    }
    
    public enum MeterType: Int {
        case Perf = 0
        case Updates
        case Frames
        case CPU
        
        static let Meters = CPU.rawValue + 1
        static let Max = Meters + 1
    }
    
    public enum RandIntervalLenIs {
        public static let One = 0
        public static let Two = 1
    }
}
