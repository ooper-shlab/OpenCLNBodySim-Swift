//
//  HUDMeterTimer.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: HUDMeterTimer.h
     File: HUDMeterTimer.mm
 Abstract:
 Utility class for manging a high-resolution timer for a hud meter.

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
}

//MARK: -
//MARK: Private - Constants

private struct Scale {
    static let kSeconds = 1.0e-9
    static let kMilliSeconds = 1.0e-6
    static let kMicroSeconds = 1.0e-3
    static let kNanoSeconds = 1.0
}

extension HUD.Meter.Timer {
    //MARK: -
    //MARK: Public - Meter - Timer
    
    public convenience init(size: Int,
        doAscend: Bool = true,
        scale: GLdouble = Scale.kSeconds)
    {
        self.init()
        var timebase: mach_timebase_info_data_t = empty_struct()
        
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
        var bSuccess = (size != mnSize) && (size > 20)
        
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
        let nSum    = m_Vector.reduce(0, +)
        
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
