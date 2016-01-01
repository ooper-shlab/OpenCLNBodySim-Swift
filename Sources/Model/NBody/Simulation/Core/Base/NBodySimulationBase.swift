//
//  NBodySimulationBase.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility base class defining interface for the derived classes, as well as,
performing thread and mutex mangement, and managment of meter arrays.
</abstract>
</codex>
 */

import Foundation
import OpenGL
import OpenCL

extension NBody.Simulation {
    private static var queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    
    public class Base {
        
        deinit {destruct()}
        
        public func initialize(options: String) {}
        
        public func reset() -> GLint {return 0}
        public func step() {}
        public func terminate() {}
        
        public func positionInRange(_: UnsafeMutablePointer<GLfloat>) -> GLint {return 0}
        
        public func position(_: UnsafeMutablePointer<GLfloat>) -> GLint {return 0}
        public func velocity(_: UnsafeMutablePointer<GLfloat>) -> GLint {return 0}
        
        public func setPosition(_: UnsafePointer<GLfloat>) -> GLint {return 0}
        public func setVelocity(_: UnsafePointer<GLfloat>) -> GLint {return 0}
        
        //var mbAcquired: Bool = false
        var mbIsUpdated: Bool = false
        
        var mnDeviceCount: cl_uint = 0
        var mnDevices: cl_uint = 0
        
        var mnLength: Int = 0
        var mnSamples: Int = 0
        var mnSize: Int = 0
        var mnMinIndex: Int = 0
        var mnMaxIndex: Int = 0
        
        var m_DeviceName: String = ""
        
        var m_Properties: Properties
        
        private var mbStop: Bool = false
        private var mbReload: Bool = false
        private var mbPaused: Bool = false
        private var mbKeepAlive: Bool = false
        
        private var m_Options: String = ""
        
        private var mpData: UnsafeMutablePointer<GLfloat> = nil
        
        //private var m_Thread: pthread_t = pthread_t()
        private var m_RunLock: pthread_mutex_t = pthread_mutex_t()
        private var m_RunAttrib: pthread_mutexattr_t = pthread_mutexattr_t()
        private var m_ClockLock: pthread_mutex_t = pthread_mutex_t()
        private var m_ClockAttrib: pthread_mutexattr_t = pthread_mutexattr_t()
        
        private var m_Timer: HUD.Meter.Timer = HUD.Meter.Timer(20, doAscend: false)
        private var mnTime: GLdouble = 0
        
        private var m_Updates: HUD.Meter.Timer = HUD.Meter.Timer(20, doAscend: false)
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
        
        class func simulate(pBase: Base) {
            
            pBase.run()
            
            dispatch_semaphore_signal(pBase.m_TerminationSemaphore)
        }
        
        init(_ properties: NBody.Simulation.Properties) {
            m_Properties = properties
            if properties.mnParticles != 0 {
                m_Options = kOptions
                
                //m_Properties = properties
                
                mnCardinality = properties.mnParticles * properties.mnParticles
                mnMaxIndex    = properties.mnParticles
                mnLength      = 4 * properties.mnParticles
                mnSamples     = strideof(GLfloat)
                mnSize        = mnLength * mnSamples
                
                //mbAcquired  = false
                mbIsUpdated = true
                mbKeepAlive = true
                mbStop      = false
                mbReload    = false
                mbPaused    = false
                
                mpData = nil
                //m_Thread = nil
                
                m_DeviceName = ""
                
                mnMinIndex    = 0
                mnDeviceCount = 0
                mnDevices     = 0
                
                mnTime    = 0.0
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
            do {
                mbStop = true
            }
            unpause()
            
            dispatch_semaphore_wait(m_TerminationSemaphore, DISPATCH_TIME_FOREVER)
            
            //mbAcquired = false
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
        
        public func resetProperties(Properties: NBody.Simulation.Properties) {
            pause()
            do {
                mnMinIndex     = 0
                mnMaxIndex     = Properties.mnParticles
                m_Properties = Properties
                
                m_Timer.erase()
                
                mnTime = 0
                
                m_Updates.erase()
                
                mnUpdates = 0
                mbReload  = true
                mnYear    = 2.755e9
            }
            unpause()
        }
        
        public func setProperties(Properties: NBody.Simulation.Properties) {
            m_Properties = Properties
            
            mbReload = true
        }
        
        public func setRange(min: Int, _ max: Int) {
            mnMinIndex = min
            mnMaxIndex = max
        }
        
        public func invalidate(v: Bool) {
            mbIsUpdated = v
        }
        
        public func setData(pData: UnsafePointer<GLfloat>) {
            if pData != nil {
                let pDataDst = UnsafeMutablePointer<GLfloat>.alloc(mnLength)
                
                do {
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
            do {
                initialize(m_Options)
            }
            pthread_mutex_unlock(&m_ClockLock)
            
            while mbKeepAlive {
                pthread_mutex_lock(&m_RunLock)
                do {
                    if mbStop {
                        pthread_mutex_unlock(&m_ClockLock)
                        pthread_mutex_unlock(&m_RunLock)
                        
                        return
                    }
                    
                    if mbReload {
                        pthread_mutex_lock(&m_ClockLock)
                        do {
                            reset()
                        }
                        pthread_mutex_unlock(&m_ClockLock)
                        
                        mbReload = false
                    }
                    
                    pthread_mutex_lock(&m_ClockLock)
                    do {
                        m_Timer.start()
                        do {
                            step()
                        }
                        m_Timer.stop()
                    }
                    pthread_mutex_unlock(&m_ClockLock)
                }
                pthread_mutex_unlock(&m_RunLock)
                
                m_Timer.update(mnDelta)
                
                mnTime = m_Timer.persecond
                
                m_Updates.setStart(m_Timer.getStart())
                m_Updates.setStop(m_Timer.getStop())
                m_Updates.update()
                
                mnUpdates = ceil(m_Updates.persecond)
                
                // normalize for NBody::Scale::kTime at 0.4
                mnYear += kScaleYear * m_Properties.mnTimeStep.d
            }
            
            pthread_mutex_lock(&m_ClockLock)
            do {
                terminate()
            }
            pthread_mutex_unlock(&m_ClockLock)
        }
        
        public var performance: GLdouble {
            return mnTime
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