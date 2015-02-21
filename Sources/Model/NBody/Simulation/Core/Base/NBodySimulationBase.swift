//
//  NBodySimulationBase.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodySimulationBase.h
     File: NBodySimulationBase.mm
 Abstract:
 Utility base class defining interface for the derived classes, as well as,
 performing thread and mutex mangement, and managment of meter arrays.

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

import Foundation
import OpenGL
import OpenCL

func empty_struct<T>() -> T {
    var ptr = UnsafeMutablePointer<T>.alloc(1)
    bzero(UnsafeMutablePointer(ptr), size_t(sizeof(T)))
    let result = ptr.memory
    ptr.dealloc(1)
    return result
}

extension NBody.Simulation {
    private static var queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    public class Base {
        
        deinit {destruct()}
        
        public func initialize(options: String) {}
        
        public func reset() -> Int {return 0}
        public func step() {}
        public func terminate() {}
        
        public func positionInRange(UnsafeMutablePointer<GLfloat>) -> Int {return 0}
        
        public func position(UnsafeMutablePointer<GLfloat>) -> Int {return 0}
        public func velocity(UnsafeMutablePointer<GLfloat>) -> Int {return 0}
        
        public func setPosition(UnsafePointer<GLfloat>) -> Int {return 0}
        public func setVelocity(UnsafePointer<GLfloat>) -> Int {return 0}
        
        internal var mbAcquired: Bool = false
        internal var mbIsUpdated: Bool = false
        internal var mnDeviceCount: cl_uint = 0
        internal var mnDevices: cl_uint = 0
        internal var mnLength: Int = 0
        internal var mnSamples: Int = 0
        internal var mnSize: Int = 0
        internal var mnBodyCount: Int = 0
        internal var mnMinIndex: Int = 0
        internal var mnMaxIndex: Int = 0
        internal var m_DeviceName: String = ""
        internal var m_ActiveParams: Params = Params()
        
        private var mbStop: Bool = false
        private var mbReload: Bool = false
        private var mbPaused: Bool = false
        private var mbKeepAlive: Bool = false
        
        private var m_Options: String = ""
        
        private var mpData: UnsafeMutablePointer<GLfloat> = nil
        
        private var m_RunLock: pthread_mutex_t = empty_struct()
        private var m_RunAttrib: pthread_mutexattr_t = empty_struct()
        private var m_ClockLock: pthread_mutex_t = empty_struct()
        private var m_ClockAttrib: pthread_mutexattr_t = empty_struct()
        
        private var m_Pref: HUD.Meter.Timer = HUD.Meter.Timer(size: 20, doAscend: false)
        private var mnPref: GLdouble = 0
        
        private var m_Updates: HUD.Meter.Timer = HUD.Meter.Timer(size: 20, doAscend: false)
        private var mnUpdates: GLdouble = 0
        
        private var mnYear: GLdouble = 0
        private var mnFreq: GLdouble = 0
        private var mnDelta: GLdouble = 0
        private var mnCardinality: Int = 0
        
        //MARK: -
        //MARK: GCD adaption
        private var m_TerminationSemaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        internal var m_AcquisitionSemaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        //MARK: -
        //MARK: Private - Constants
        
        private let kOptions = "-cl-fast-relaxed-math -cl-mad-enable"
        
        private let kScaleYear: GLdouble = 1.8e7
        
        //MARK: -
        //MARK: Public - Utilities
        
        internal class func simulate(pBase: Base) {
            
            pBase.run()
            
            dispatch_semaphore_signal(pBase.m_TerminationSemaphore)
        }
        
        internal init(nbodies: Int,
            params: NBody.Simulation.Params) {
                if nbodies != 0 {
                    m_Options = kOptions
                    
                    m_ActiveParams = params
                    
                    mnBodyCount   = nbodies
                    mnCardinality = mnBodyCount * mnBodyCount
                    mnMaxIndex    = mnBodyCount
                    mnLength      = 4 * mnBodyCount
                    mnSamples     = strideof(GLfloat)
                    mnSize        = mnLength * mnSamples
                    
                    mbAcquired  = false
                    mbIsUpdated = true
                    mbKeepAlive = true
                    mbStop      = false
                    mbReload    = false
                    mbPaused    = false
                    
                    mpData = nil
                    
                    m_DeviceName = ""
                    
                    mnMinIndex    = 0
                    mnDeviceCount = 0
                    mnDevices     = 0
                    
                    mnPref    = 0.0
                    mnUpdates = 0.0
                    
                    let hw = CF.Query.Hardware.instance
                    
                    // This number is used to measure relative performance.
                    // The baseline is that of multi-core CPU performance
                    // and all performance numbers are measured relative
                    // to this number. And as such this is not the traditional
                    // giga (or tera) flops performance numbers.
                    mnDelta = GLdouble(mnCardinality) * hw.scale
                    
                    pthread_mutexattr_init(&m_ClockAttrib)
                    pthread_mutexattr_settype(&m_ClockAttrib, PTHREAD_MUTEX_RECURSIVE)
                    
                    pthread_mutex_init(&m_ClockLock, &m_ClockAttrib)
                    
                    pthread_mutexattr_init(&m_RunAttrib)
                    pthread_mutexattr_settype(&m_RunAttrib, PTHREAD_MUTEX_RECURSIVE)
                    
                    pthread_mutex_init(&m_RunLock, &m_RunAttrib)
                }
        }
        
        private func destruct() {
            pthread_mutexattr_destroy(&m_ClockAttrib)
            pthread_mutex_destroy(&m_ClockLock)
            
            pthread_mutexattr_destroy(&m_RunAttrib)
            pthread_mutex_destroy(&m_RunLock)
            
            if mpData != nil {
                mpData.dealloc(mnLength)
                
            }
        }
        
        internal func signalAcquisition() {
            dispatch_semaphore_signal(m_AcquisitionSemaphore)
        }
        public func waitAcquisition() {
            dispatch_semaphore_wait(m_AcquisitionSemaphore, DISPATCH_TIME_FOREVER)
        }
        
        public var isPaused: Bool {
            return mbPaused
        }
        
        public var isStopped: Bool {
            return mbStop
        }
        
        public func start(paused: Bool = true) {
            pause()
            
            let queue = NBody.Simulation.queue
            dispatch_async(queue) {
                NBody.Simulation.Base.simulate(self)
            }
            
            if !paused {
                unpause()
            }
        }
        
        public func stop() {
            pause()
            mbStop = true
            unpause()
            
            dispatch_semaphore_wait(m_TerminationSemaphore, DISPATCH_TIME_FOREVER)
            
            mbAcquired = false
        }
        
        public func pause() {
            if !mbPaused {
                if mbKeepAlive {
                    pthread_mutex_lock(&m_RunLock)
                }
                
                mbPaused = true
            }
        }
        
        public func unpause() {
            if mbPaused {
                mbPaused = false
                
                pthread_mutex_unlock(&m_RunLock)
            }
        }
        
        public func exit() {
            mbKeepAlive = false
        }
        
        public func resetParams(params: NBody.Simulation.Params) {
            pause()
            mnMinIndex     = 0
            mnMaxIndex     = mnBodyCount
            m_ActiveParams = params
            
            m_Pref.erase()
            
            mnPref = 0
            
            m_Updates.erase()
            
            mnUpdates = 0
            mbReload  = true
            mnYear    = 2.755e9
            unpause()
        }
        
        public func setParams(params: NBody.Simulation.Params) {
            m_ActiveParams = params
            mbReload = true
        }
        
        public func setRange(min: Int, max: Int) {
            mnMinIndex = min
            mnMaxIndex = max
        }
        
        public func invalidate(v: Bool) {
            mbIsUpdated = v
        }
        
        public func setData(pData: UnsafePointer<GLfloat>) {
            if pData != nil {
                let pDataDst = UnsafeMutablePointer<GLfloat>.alloc(mnLength)
                
                if pDataDst != nil {
                    pDataDst.assignFrom(UnsafeMutablePointer(pData), count: mnLength)
                    
                    let pDataSrc = mpData
                    
                    mpData = pDataDst
                    
                    pDataSrc.dealloc(mnLength)
                    
                }
            }
        }
        
        public func data() -> UnsafeMutablePointer<GLfloat> {
            let pDataSrc = mpData
            mpData = nil
            
            return pDataSrc
        }
        public var dataLength: Int {
            return mnLength
        }
        
        private func run() {
            pthread_mutex_lock(&m_ClockLock)
            initialize(m_Options)
            pthread_mutex_unlock(&m_ClockLock)
            
            while mbKeepAlive {
                pthread_mutex_lock(&m_RunLock)
                if mbStop {
                    pthread_mutex_unlock(&m_ClockLock)
                    pthread_mutex_unlock(&m_RunLock)
                    
                    return
                }
                
                if mbReload {
                    pthread_mutex_lock(&m_ClockLock)
                    reset()
                    pthread_mutex_unlock(&m_ClockLock)
                    
                    mbReload = false
                }
                
                pthread_mutex_lock(&m_ClockLock)
                m_Pref.start()
                step()
                m_Pref.stop()
                pthread_mutex_unlock(&m_ClockLock)
                pthread_mutex_unlock(&m_RunLock)
                
                m_Pref.update(dx: mnDelta)
                
                mnPref = m_Pref.persecond
                
                m_Updates.setStart(m_Pref.getStart())
                m_Updates.setStop(m_Pref.getStop())
                m_Updates.update()
                
                mnUpdates = ceil(m_Updates.persecond)
                
                // normalize for NBody::Scale::kTime at 0.4
                mnYear += kScaleYear * m_ActiveParams.mnTimeStamp.d
            }
            
            pthread_mutex_lock(&m_ClockLock)
            terminate()
            pthread_mutex_unlock(&m_ClockLock)
        }
        
        public var performance: GLdouble {
            return mnPref
        }
        
        public var updates: GLdouble {
            return mnUpdates
        }
        
        public var year: GLdouble {
            return mnYear
        }
        
        public var size: Int {
            return mnSize
        }
        
        public var name: String {
            return m_DeviceName
        }
        
        public var minimum: Int {
            return mnMinIndex
        }
        
        public var maximum: Int {
            return mnMaxIndex
        }
        
        public var devices: Int {
            return mnDevices.l
        }
    }
}