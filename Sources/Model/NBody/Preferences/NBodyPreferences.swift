//
//  NBodyPreferences.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/7/5.
//
//
/*
<codex>
<abstract>
Utility class for managing application's preferences and settings.
</abstract>
</codex>
 */

import Cocoa

//MARK: -

// Keys for the preferences dictionary                 // For values
let kNBodyPrefDemos         = "demos"          // Signed integer 64 -> Int
let kNBodyPrefDemoType      = "demoType"       // Unsigned Integer 32 -> Int
let kNBodyPrefParticles        = "particles"         // Unsigned Integer 32 -> Int
let kNBodyPrefConfig        = "config"         // Unsigned Integer 32 -> Int
let kNBodyPrefMaxUpdates    = "maxUpdates"     // Unsigned Long -> Int
let kNBodyPrefMaxFrameRate  = "maxFramerate"   // Unsigned Long -> Int
let kNBodyPrefMaxPerf       = "maxPerf"        // Unsigned Long -> Int
let kNBodyPrefMaxCPU        = "maxCPU"         // Unsigned Long -> Int
let kNBodyPrefRotateX       = "rotateX"
let kNBodyPrefRotateY       = "rotateY"
let kNBodyPrefSizeWidth     = "width"
let kNBodyPrefSizeHeight    = "height"
let kNBodyPrefClearColor    = "clearColor"
let kNBodyPrefStarScale     = "starScale"
let kNBodyPrefViewDistance  = "viewDistance"
let kNBodyPrefTimeStep      = "timeStep"
let kNBodyPrefClusterScale  = "clusterScale"
let kNBodyPrefVelocityScale = "velocityScale"
let kNBodyPrefSoftening     = "softening"
let kNBodyPrefDamping       = "damping"
let kNBodyPrefPointSize     = "pointSize"
let kNBodyPrefFullScreen    = "fullscreen"
let kNBodyPrefIsGPUOnly     = "isGPUOnly"
let kNBodyPrefShowUpdates   = "showUpdates"
let kNBodyPrefShowFrameRate = "showFramerate"
let kNBodyPrefShowPerf      = "showPerf"
let kNBodyPrefShowDock      = "showDock"
let kNBodyPrefShowCPU       = "showCPU"

@objc(NBodyPreferences)
class NBodyPreferences: NSObject {
    private var _demos: Int = 0
    
    private var _demoType: Int = 0
    private var _config: NBody.Config = .random
    private var _particles: Int = 0
    
    private var _maxUpdates: Int = 0
    private var _maxFramerate: Int = 0
    private var _maxPerf: Int = 0
    private var _maxCPU: Int = 0
    
    private var _rotate: NSPoint = NSPoint()
    private var _size: NSSize = NSSize()
    
    private var _timeStep: Float = 0.0
    private var _clusterScale: Float = 0.0
    private var _velocityScale: Float = 0.0
    private var _softening: Float = 0.0
    private var _damping: Float = 0.0
    private var _pointSize: Float = 0.0
    private var _starScale: Float = 0.0
    private var _viewDistance: Float = 0.0
    private var _clearColor: Float = 0.0
    
    private var _isGPUOnly: Bool = false
    private var _fullscreen: Bool = false
    private var _showUpdates: Bool = false
    private var _showFramerate: Bool = false
    private var _showPerf: Bool = false
    private var _showDock: Bool = false
    private var _showCPU: Bool = false
    
    private var _identifier: String?
    
    private var mpPreferences: [String: Any] = [:]
    
    private var mpFile: NSFile?
    
    //- (void) _setLongLongValue:(int64_t &)value
    //                      with:(NSNumber *)pNumber
    //{
    //    if(pNumber)
    //    {
    //        value = pNumber.longLongValue;
    //    } // if
    //} // _setLongLongValue
    //
    //- (void) _setUnsignedIntValue:(uint32_t &)value
    //                         with:(NSNumber *)pNumber
    //{
    //    if(pNumber)
    //    {
    //        value = pNumber.unsignedIntValue;
    //    } // if
    //} // _setUnsignedIntValue
    
    private func _setConfigValue(_ value: inout NBody.Config, with pNumber: Any?) {
        if let
            integerValue = pNumber as? Int,
            let configValue = NBody.Config(rawValue: integerValue)
        {
            value = configValue
        }
    }
    
    private func _setIntegerValue(_ value: inout Int, with pNumber: Any?) {
        if let integerValue = pNumber as? Int {
            value = integerValue
        }
    }
    
    //- (void) _setUnsignedLongValue:(size_t &)value
    //                          with:(NSNumber *)pNumber
    //{
    //    if(pNumber)
    //    {
    //        value = pNumber.unsignedLongValue;
    //    } // if
    //} // _setUnsignedLongValue
    
    private func _setCGFloatValue(_ value: inout CGFloat, with pNumber: Any?) {
        if let cgFloatValue = pNumber as? CGFloat {
            value = cgFloatValue
        }
    }
    
    private func _setDoubleValue(_ value: inout Double, with pNumber: Any?) {
        if let doubleValue = pNumber as? Double {
            value = doubleValue
        }
    }
    
    private func _setFloatValue(_ value: inout Float, with pNumber: Any?) {
        if let floatValue = pNumber as? Float {
            value = floatValue
        }
    }
    
    private func _setBoolValue(_ value: inout Bool, with pNumber: Any?) {
        if let boolValue = pNumber as? Bool {
            value = boolValue
        }
    }
    
    @discardableResult
    private func _setPreferences(_ pPrefs: [String: Any]) -> Bool {
        let success = !pPrefs.isEmpty
        
        if success {
            _setIntegerValue(&_demos, with: pPrefs[kNBodyPrefDemos])
            _setIntegerValue(&_demoType, with: pPrefs[kNBodyPrefDemoType])
            _setIntegerValue(&_particles, with: pPrefs[kNBodyPrefParticles])
            _setConfigValue(&_config, with: pPrefs[kNBodyPrefConfig])
            _setIntegerValue(&_maxUpdates, with: pPrefs[kNBodyPrefMaxUpdates])
            _setIntegerValue(&_maxFramerate, with: pPrefs[kNBodyPrefMaxFrameRate])
            _setIntegerValue(&_maxPerf, with: pPrefs[kNBodyPrefMaxPerf])
            _setIntegerValue(&_maxCPU, with: pPrefs[kNBodyPrefMaxCPU])
            _setCGFloatValue(&_rotate.x, with: pPrefs[kNBodyPrefRotateX])
            _setCGFloatValue(&_rotate.y, with: pPrefs[kNBodyPrefRotateY])
            _setCGFloatValue(&_size.width, with: pPrefs[kNBodyPrefSizeWidth])
            _setCGFloatValue(&_size.height, with: pPrefs[kNBodyPrefSizeHeight])
            _setFloatValue(&_clearColor, with: pPrefs[kNBodyPrefClearColor])
            _setFloatValue(&_starScale, with: pPrefs[kNBodyPrefStarScale])
            _setFloatValue(&_viewDistance, with: pPrefs[kNBodyPrefViewDistance])
            _setFloatValue(&_timeStep, with: pPrefs[kNBodyPrefTimeStep])
            _setFloatValue(&_clusterScale, with: pPrefs[kNBodyPrefClusterScale])
            _setFloatValue(&_velocityScale, with: pPrefs[kNBodyPrefVelocityScale])
            _setFloatValue(&_softening, with: pPrefs[kNBodyPrefSoftening])
            _setFloatValue(&_damping, with: pPrefs[kNBodyPrefDamping])
            _setFloatValue(&_pointSize, with: pPrefs[kNBodyPrefPointSize])
            _setBoolValue(&_fullscreen, with: pPrefs[kNBodyPrefFullScreen])
            _setBoolValue(&_isGPUOnly, with: pPrefs[kNBodyPrefIsGPUOnly])
            _setBoolValue(&_showUpdates, with: pPrefs[kNBodyPrefShowUpdates])
            _setBoolValue(&_showFramerate, with: pPrefs[kNBodyPrefShowFrameRate])
            _setBoolValue(&_showCPU, with: pPrefs[kNBodyPrefShowCPU])
            _setBoolValue(&_showPerf, with: pPrefs[kNBodyPrefShowPerf])
            _setBoolValue(&_showDock, with: pPrefs[kNBodyPrefShowDock])
        }
        
        return success
    }
    
    private func _newPreferences() -> [String: Any] {
        return [kNBodyPrefDemos: 7 as AnyObject,
            kNBodyPrefDemoType: 1 as AnyObject,
            kNBodyPrefParticles: NBody.Particles.kCount,
            kNBodyPrefConfig: NBody.Config.shell.rawValue,
            kNBodyPrefMaxUpdates: 120,
            kNBodyPrefMaxFrameRate: 120,
            kNBodyPrefMaxCPU: 100,
            kNBodyPrefMaxPerf: 1400,
            kNBodyPrefRotateX: 0.0,
            kNBodyPrefRotateY: 0.0,
            kNBodyPrefSizeWidth: NBody.Window.kWidth,
            kNBodyPrefSizeHeight: NBody.Window.kHeight,
            kNBodyPrefClearColor: 1.0,
            kNBodyPrefStarScale: 1.0,
            kNBodyPrefViewDistance: 30.0,
            kNBodyPrefTimeStep: NBody.Scale.kTime * 0.016,
            kNBodyPrefClusterScale: 1.54,
            kNBodyPrefVelocityScale: 8.0,
            kNBodyPrefSoftening: NBody.Scale.kSoftening * 0.1,
            kNBodyPrefDamping: 1.0,
            kNBodyPrefPointSize: 1.0,
            kNBodyPrefFullScreen: false,
            kNBodyPrefIsGPUOnly: false,
            kNBodyPrefShowUpdates: false,
            kNBodyPrefShowFrameRate: false,
            kNBodyPrefShowCPU: false,
            kNBodyPrefShowPerf: true,
            kNBodyPrefShowDock: true]
    }
    
    override init() {
        super.init()
        
        var pPrefsDst = self._newPreferences()
        
        _identifier = Bundle.main.bundleIdentifier
        
        if let _identifier = _identifier {
            mpFile = NSFile(domain: .userDomainMask,
                search: .libraryDirectory,
                directory: "Preferences",
                file: _identifier,
                ofExtension: "plist")
            
            if let mpFile = mpFile {
                if let pPrefsSrc = mpFile.plist as? [String: AnyObject] {
                    
                    self._setPreferences(pPrefsSrc)
                    
                    pPrefsDst.addEntriesFromDictionary(pPrefsSrc)
                    
                }
                
                mpFile.replace(pPrefsDst)
                
                mpFile.write()
            }
        }
        
        mpPreferences = pPrefsDst
        
        mpFile?.replace(mpPreferences)
        
        mpFile?.write()
        
    }
    
    //+ (instancetype) preferences
    //{
    //    return([[[NBodyPreferences allocWithZone:[self zone]] init] autorelease]);
    //} // preferences
    
    @discardableResult
    func addEntries(_ preferences: NBodyPreferences?) -> Bool {
        
        guard let preferences = preferences else {return false}
        let pPreferences = preferences.preferences
        
        guard self._setPreferences(pPreferences) else {return false}
        
        mpPreferences.addEntriesFromDictionary(pPreferences)
        
        mpFile?.replace(mpPreferences)
        
        mpFile?.write()
        
        return true
    }
    
    var preferences: [String: Any] {
        return mpPreferences
    }
    
    @discardableResult
    func write() -> Bool {
        mpFile?.replace(mpPreferences)
        
        return mpFile?.write() ?? false
    }
    
    var demos: Int {
        get {return _demos}
        set {
            _demos = newValue
            
            mpPreferences[kNBodyPrefDemos] = _demos as AnyObject
        }
    }
    
    var particles: Int {
        get {return _particles}
        set {
            _particles = (newValue != 0) ? newValue : NBody.Particles.kCount
            
            mpPreferences[kNBodyPrefParticles] = _particles as AnyObject
        }
    }
    
    var demoType: Int {
        get {return _demoType}
        set {
            _demoType = (newValue > 6 || newValue < 0) ? 1 : newValue
            
            mpPreferences[kNBodyPrefDemoType] = _demoType as AnyObject
        }
    }
    
    var config: NBody.Config {
        get {return _config}
        set {
            _config = newValue
            
            mpPreferences[kNBodyPrefConfig] = _config.rawValue as AnyObject
        }
    }
    
    var maxFramerate: Int {
        get {return _maxFramerate}
        set {
            _maxFramerate = newValue
            
            mpPreferences[kNBodyPrefMaxFrameRate] = _maxFramerate as AnyObject
        }
    }
    
    var maxCPU: Int {
        get {return _maxCPU}
        set {
            _maxCPU = newValue
            
            mpPreferences[kNBodyPrefMaxCPU] = _maxCPU as AnyObject
        }
    }
    
    var maxPerf: Int {
        get {return _maxPerf}
        set {
            _maxPerf = newValue
            
            mpPreferences[kNBodyPrefMaxPerf] = _maxPerf as AnyObject
        }
    }
    
    var maxUpdates: Int {
        get {return _maxUpdates}
        set {
            _maxUpdates = newValue
            
            mpPreferences[kNBodyPrefMaxUpdates] = _maxUpdates as AnyObject
        }
    }
    
    var clearColor: Float {
        get {return _clearColor}
        set {
            _clearColor = newValue
            
            mpPreferences[kNBodyPrefClearColor] = _clearColor as AnyObject
        }
    }
    
    var starScale: Float {
        get {return _starScale}
        set {
            _starScale = (newValue >= 0.125) ? newValue : 1.0
            
            mpPreferences[kNBodyPrefStarScale] = _starScale as AnyObject
        }
    }
    
    var rotate: NSPoint {
        get {return _rotate}
        set {
            _rotate = newValue
            
            mpPreferences[kNBodyPrefRotateX] = _rotate.x as AnyObject
            mpPreferences[kNBodyPrefRotateY] = _rotate.y as AnyObject
        }
    }
    
    var size: NSSize {
        get {return _size}
        set {
            _size.width  = (newValue.width  > 256.0) ? newValue.width  : NBody.Window.kWidth.g
            _size.height = (newValue.height > 256.0) ? newValue.height : NBody.Window.kHeight.g
            
            mpPreferences[kNBodyPrefSizeWidth]  = _size.width as AnyObject
            mpPreferences[kNBodyPrefSizeHeight] = _size.height as AnyObject
        }
    }
    
    var viewDistance: Float {
        get {return _viewDistance}
        set {
            _viewDistance = newValue
            
            mpPreferences[kNBodyPrefViewDistance] = _viewDistance as AnyObject
        }
    }
    
    var timeStep: Float {
        get {return _timeStep}
        set {
            _timeStep = newValue
            
            mpPreferences[kNBodyPrefTimeStep] = _timeStep as AnyObject
        }
    }
    
    var clusterScale: Float {
        get {return _clusterScale}
        set {
            _clusterScale = newValue
            
            mpPreferences[kNBodyPrefClusterScale] = _clusterScale as AnyObject
        }
    }
    
    var velocityScale: Float {
        get {return _velocityScale}
        set {
            _velocityScale = newValue
            
            mpPreferences[kNBodyPrefVelocityScale] = _velocityScale as AnyObject
        }
    }
    
    var softening: Float {
        get {return _softening}
        set {
            _softening = newValue
            
            mpPreferences[kNBodyPrefSoftening] = _softening as AnyObject
        }
    }
    
    var damping: Float {
        get {return _damping}
        set {
            _damping = newValue
            
            mpPreferences[kNBodyPrefDamping] = _damping as AnyObject
        }
    }
    
    var pointSize: Float {
        get {return _pointSize}
        set {
            _pointSize = newValue
            
            mpPreferences[kNBodyPrefPointSize] = _pointSize as AnyObject
        }
    }
    
    var fullscreen: Bool {
        get {return _fullscreen}
        set {
            _fullscreen = newValue
            
            mpPreferences[kNBodyPrefFullScreen] = _fullscreen as AnyObject
        }
    }
    
    var GPUOnly: Bool {
        get {return _isGPUOnly}
        set {
            _isGPUOnly = newValue
            
            mpPreferences[kNBodyPrefIsGPUOnly] = _isGPUOnly as AnyObject
        }
    }
    
    var showUpdates: Bool {
        get {return _showUpdates}
        set {
            _showUpdates = newValue
            
            mpPreferences[kNBodyPrefShowUpdates] = _showUpdates as AnyObject
        }
    }
    
    var showFramerate: Bool {
        get {return _showFramerate}
        set {
            _showFramerate = newValue
            
            mpPreferences[kNBodyPrefShowFrameRate] = _showFramerate as AnyObject
        }
    }
    
    var showPerf: Bool {
        get {return _showPerf}
        set {
            _showPerf = newValue
            
            mpPreferences[kNBodyPrefShowPerf] = _showPerf as AnyObject
        }
    }
    
    var showDock: Bool {
        get {return _showDock}
        set {
            _showDock = newValue
            
            mpPreferences[kNBodyPrefShowDock] = _showDock as AnyObject
        }
    }
    
    var showCPU: Bool {
        get {return _showCPU}
        set {
            _showCPU = newValue
            
            mpPreferences[kNBodyPrefShowCPU] = _showCPU as AnyObject
        }
    }
    
}
