//
//  HUDMeterTimer.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility class for manging a high-resolution timer for a hud meter.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension HUD.Meter {
    
    public typealias Vector = [GLdouble]
    
    public typealias Time = UInt64
    public typealias Duration = GLdouble
    
    public class Timer {
        
        private var mbAscend: Bool = false
        private var mnSize: Int = 0
        private var mnCount: Int = 0
        private var mnIndex: Int = 0
        private var mnAspect: GLdouble = 0
        private var mnRes: GLdouble = 0
        private var mnScale: GLdouble = 0
        private var mnStart: Time = 0
        private var mnStop: Time = 0
        private var mnDuration: Duration = 0
        private var m_Vector: Vector = []
    }
    
    //MARK: -
    //MARK: Private - Constants
    
    public enum TimeScale {
        static let kSeconds = 1.0e-9
        static let kMilliSeconds = 1.0e-6
        static let kMicroSeconds = 1.0e-3
        static let kNanoSeconds = 1.0
    }
}

extension HUD.Meter.Timer {
    //MARK: -
    //MARK: Public - Meter - Timer
    
    public convenience init(_ size: Int,
        doAscend: Bool = true,
        scale: GLdouble = HUD.Meter.TimeScale.kSeconds)
    {
        self.init()
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        
        let result = mach_timebase_info(&timebase)
        
        if result == KERN_SUCCESS {
            mnAspect = Double(timebase.numer) / Double(timebase.denom)
            mnScale  = scale
            mnRes    = mnAspect * mnScale
        }
        
        mnSize     = (size > 20) ? size : 20
        mbAscend   = doAscend
        mnIndex    = 0
        mnCount    = 0
        mnStart    = 0
        mnStop     = 0
        mnDuration = 0.0
        
        m_Vector = Array(count: mnSize, repeatedValue: 0.0)
    }
    
    public convenience init(timer: HUD.Meter.Timer) {
        self.init()
        mnAspect   = timer.mnAspect
        mnScale    = timer.mnScale
        mnRes      = timer.mnRes
        mnDuration = timer.mnDuration
        m_Vector   = timer.m_Vector
        mnSize     = timer.mnSize
        mnStart    = timer.mnStart
        mnStop     = timer.mnStop
        mnCount    = timer.mnCount
        mnIndex    = timer.mnIndex
        mbAscend   = timer.mbAscend
    }
    
    public func resize(size: Int) -> Bool {
        let bSuccess = (size != mnSize) && (size > 20)
        
        if bSuccess {
            mnSize = size
            
            m_Vector = Array(count: mnSize, repeatedValue: 0)
        }
        
        return bSuccess
    }
    
    public func setScale(scale: GLdouble) {
        if scale > 0 {
            mnScale = scale
            mnRes = mnAspect * mnScale
        }
    }
    
    public func setStart(time: HUD.Meter.Time) {
        mnStart = time
    }
    
    public func setStop(time: HUD.Meter.Time) {
        mnStop = time
    }
    
    public func getStart() -> HUD.Meter.Time {
        return mnStart
    }
    
    public func getStop() -> HUD.Meter.Time {
        return mnStop
    }
    
    public var duration: HUD.Meter.Duration {
        return mnDuration
    }
    
    public func erase() {
        m_Vector = Array(count: mnSize, repeatedValue: 0)
        mnCount = 0
    }
    
    public func update(dx: GLdouble = 1.0) {
        let dt = mnRes * GLdouble(mnStop - mnStart)
        
        ++mnCount
        
        m_Vector[mnIndex] = dx / dt
        
        mnIndex = (mnIndex + 1) % mnSize
    }
    
    public var persecond: GLdouble {
        let nSize   = GLdouble(mnSize)
        let nMin    = GLdouble(min(mnCount, mnSize))
        let nMetric = mbAscend ? nSize : nMin
        let nSum    = m_Vector.reduce(0, combine: +)
        
        return nSum / nMetric
    }
    
    public func start() {
        mnStart = mach_absolute_time()
    }
    
    public func stop() {
        mnStop = mach_absolute_time()
    }
    
    public func reset() {
        mnStart = mnStop
    }
    
}
