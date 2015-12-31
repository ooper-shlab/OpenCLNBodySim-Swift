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
//
//#import <Cocoa/Cocoa.h>
import Cocoa
//
//// Keys for the preferences dictionary     // For values
//extern NSString* kNBodyPrefDemos;          // Signed integer 64
//extern NSString* kNBodyPrefDemoType;       // Unsigned Integer 32
//extern NSString* kNBodyPrefParticles;         // Unsigned Integer 32
//extern NSString* kNBodyPrefConfig;         // Unsigned Integer 32
//extern NSString* kNBodyPrefMaxUpdates;     // Unsigned Long
//extern NSString* kNBodyPrefMaxFrameRate;   // Unsigned Long
//extern NSString* kNBodyPrefMaxPerf;        // Unsigned Long
//extern NSString* kNBodyPrefMaxCPU;         // Unsigned Long
//extern NSString* kNBodyPrefRotateX;        // Double
//extern NSString* kNBodyPrefRotateY;        // Double
//extern NSString* kNBodyPrefSizeWidth;      // Double
//extern NSString* kNBodyPrefSizeHeight;     // Double
//extern NSString* kNBodyPrefClearColor;     // Float
//extern NSString* kNBodyPrefStarScale;      // Float
//extern NSString* kNBodyPrefViewDistance;   // Float
//extern NSString* kNBodyPrefTimeStep;       // Float
//extern NSString* kNBodyPrefClusterScale;   // Float
//extern NSString* kNBodyPrefVelocityScale;  // Float
//extern NSString* kNBodyPrefSoftening;      // Float
//extern NSString* kNBodyPrefDamping;        // Float
//extern NSString* kNBodyPrefPointSize;      // Float
//extern NSString* kNBodyPrefFullScreen;     // BOOL
//extern NSString* kNBodyPrefIsGPUOnly;      // BOOL
//extern NSString* kNBodyPrefShowUpdates;    // BOOL
//extern NSString* kNBodyPrefShowFrameRate;  // BOOL
//extern NSString* kNBodyPrefShowPerf;       // BOOL
//extern NSString* kNBodyPrefShowDock;       // BOOL
//extern NSString* kNBodyPrefShowCPU;        // BOOL
//
//@interface NBodyPreferences : NSObject
//
//@property (nonatomic, readonly) NSString*     identifier;
//@property (nonatomic, readonly) NSDictionary* preferences;
//
//@property (nonatomic) int64_t demos;
//
//@property (nonatomic) uint32_t demoType;
//@property (nonatomic) uint32_t config;
//@property (nonatomic) uint32_t bodies;
//
//@property (nonatomic) size_t maxUpdates;
//@property (nonatomic) size_t maxFramerate;
//@property (nonatomic) size_t maxPerf;
//@property (nonatomic) size_t maxCPU;
//
//@property (nonatomic) NSPoint rotate;
//@property (nonatomic) NSSize  size;
//
//@property (nonatomic) float  timeStep;
//@property (nonatomic) float  clusterScale;
//@property (nonatomic) float  velocityScale;
//@property (nonatomic) float  softening;
//@property (nonatomic) float  damping;
//@property (nonatomic) float  pointSize;
//@property (nonatomic) float  starScale;
//@property (nonatomic) float  viewDistance;
//@property (nonatomic) float  clearColor;
//
//@property (nonatomic) BOOL  isGPUOnly;
//@property (nonatomic) BOOL  fullscreen;
//@property (nonatomic) BOOL  showUpdates;
//@property (nonatomic) BOOL  showFramerate;
//@property (nonatomic) BOOL  showCPU;
//@property (nonatomic) BOOL  showPerf;
//@property (nonatomic) BOOL  showDock;
//
//+ (instancetype) preferences;
//
//- (BOOL) addEntries:(NBodyPreferences *)preferences;
//
//- (BOOL) write;
//
//@end
//
//#import "NSFile.h"
//
//#import "NBodyConstants.h"
//#import "NBodyPreferences.h"
//
//#pragma mark -
//
//// Keys for the preferences dictionary                 // For values
//NSString* kNBodyPrefDemos         = @"demos";          // Signed integer 64
let kNBodyPrefDemos         = "demos"          // Signed integer 64 -> Int
//NSString* kNBodyPrefDemoType      = @"demoType";       // Unsigned Integer 32
let kNBodyPrefDemoType      = "demoType"       // Unsigned Integer 32 -> Int
//NSString* kNBodyPrefParticles        = @"particles";         // Unsigned Integer 32
let kNBodyPrefParticles        = "particles"         // Unsigned Integer 32 -> Int
//NSString* kNBodyPrefConfig        = @"config";         // Unsigned Integer 32
let kNBodyPrefConfig        = "config"         // Unsigned Integer 32 -> Int
//NSString* kNBodyPrefMaxUpdates    = @"maxUpdates";     // Unsigned Long
let kNBodyPrefMaxUpdates    = "maxUpdates"     // Unsigned Long -> Int
//NSString* kNBodyPrefMaxFrameRate  = @"maxFramerate";   // Unsigned Long
let kNBodyPrefMaxFrameRate  = "maxFramerate"   // Unsigned Long -> Int
//NSString* kNBodyPrefMaxPerf       = @"maxPerf";        // Unsigned Long
let kNBodyPrefMaxPerf       = "maxPerf"        // Unsigned Long -> Int
//NSString* kNBodyPrefMaxCPU        = @"maxCPU";         // Unsigned Long
let kNBodyPrefMaxCPU        = "maxCPU"         // Unsigned Long -> Int
//NSString* kNBodyPrefRotateX       = @"rotateX";        // Double
let kNBodyPrefRotateX       = "rotateX"
//NSString* kNBodyPrefRotateY       = @"rotateY";        // Double
let kNBodyPrefRotateY       = "rotateY"
//NSString* kNBodyPrefSizeWidth     = @"width";          // Double
let kNBodyPrefSizeWidth     = "width"
//NSString* kNBodyPrefSizeHeight    = @"height";         // Double
let kNBodyPrefSizeHeight    = "height"
//NSString* kNBodyPrefClearColor    = @"clearColor";     // Float
let kNBodyPrefClearColor    = "clearColor"
//NSString* kNBodyPrefStarScale     = @"starScale";      // Float
let kNBodyPrefStarScale     = "starScale"
//NSString* kNBodyPrefViewDistance  = @"viewDistance";   // Float
let kNBodyPrefViewDistance  = "viewDistance"
//NSString* kNBodyPrefTimeStep      = @"timeStep";       // Float
let kNBodyPrefTimeStep      = "timeStep"
//NSString* kNBodyPrefClusterScale  = @"clusterScale";   // Float
let kNBodyPrefClusterScale  = "clusterScale"
//NSString* kNBodyPrefVelocityScale = @"velocityScale";  // Float
let kNBodyPrefVelocityScale = "velocityScale"
//NSString* kNBodyPrefSoftening     = @"softening";      // Float
let kNBodyPrefSoftening     = "softening"
//NSString* kNBodyPrefDamping       = @"damping";        // Float
let kNBodyPrefDamping       = "damping"
//NSString* kNBodyPrefPointSize     = @"pointSize";      // Float
let kNBodyPrefPointSize     = "pointSize"
//NSString* kNBodyPrefFullScreen    = @"fullscreen";     // BOOL
let kNBodyPrefFullScreen    = "fullscreen"
//NSString* kNBodyPrefIsGPUOnly     = @"isGPUOnly";      // BOOL
let kNBodyPrefIsGPUOnly     = "isGPUOnly"
//NSString* kNBodyPrefShowUpdates   = @"showUpdates";    // BOOL
let kNBodyPrefShowUpdates   = "showUpdates"
//NSString* kNBodyPrefShowFrameRate = @"showFramerate";  // BOOL
let kNBodyPrefShowFrameRate = "showFramerate"
//NSString* kNBodyPrefShowPerf      = @"showPerf";       // BOOL
let kNBodyPrefShowPerf      = "showPerf"
//NSString* kNBodyPrefShowDock      = @"showDock";       // BOOL
let kNBodyPrefShowDock      = "showDock"
//NSString* kNBodyPrefShowCPU       = @"showCPU";        // BOOL
let kNBodyPrefShowCPU       = "showCPU"
//
//@implementation NBodyPreferences
//{
@objc(NBodyPreferences)
class NBodyPreferences: NSObject {
//@private
//    int64_t _demos;
    private var _demos: Int = 0
//
//    uint32_t _demoType;
    private var _demoType: Int = 0
//    uint32_t _config;
    private var _config: NBody.Config = .Random
//    uint32_t _bodies;
    private var _particles: Int = 0
//
//    size_t _maxUpdates;
    private var _maxUpdates: Int = 0
//    size_t _maxFramerate;
    private var _maxFramerate: Int = 0
//    size_t _maxPerf;
    private var _maxPerf: Int = 0
//    size_t _maxCPU;
    private var _maxCPU: Int = 0
//
//    NSPoint _rotate;
    private var _rotate: NSPoint = NSPoint()
//    NSSize  _size;
    private var _size: NSSize = NSSize()
//
//    float  _timeStep;
    private var _timeStep: Float = 0.0
//    float  _clusterScale;
    private var _clusterScale: Float = 0.0
//    float  _velocityScale;
    private var _velocityScale: Float = 0.0
//    float  _softening;
    private var _softening: Float = 0.0
//    float  _damping;
    private var _damping: Float = 0.0
//    float  _pointSize;
    private var _pointSize: Float = 0.0
//    float  _starScale;
    private var _starScale: Float = 0.0
//    float  _viewDistance;
    private var _viewDistance: Float = 0.0
//    float  _clearColor;
    private var _clearColor: Float = 0.0
//
//    BOOL  _isGPUOnly;
    private var _isGPUOnly: Bool = false
//    BOOL  _fullscreen;
    private var _fullscreen: Bool = false
//    BOOL  _showUpdates;
    private var _showUpdates: Bool = false
//    BOOL  _showFramerate;
    private var _showFramerate: Bool = false
//    BOOL  _showPerf;
    private var _showPerf: Bool = false
//    BOOL  _showDock;
    private var _showDock: Bool = false
//    BOOL  _showCPU;
    private var _showCPU: Bool = false
//
//    NSString* _identifier;
    private var _identifier: String?
//
//    NSMutableDictionary* mpPreferences;
    private var mpPreferences: [String: AnyObject] = [:]
//
//    NSFile* mpFile;
    private var mpFile: NSFile?
//}
//
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
//
    private func _setConfigValue(inout value: NBody.Config, with pNumber: AnyObject?) {
        if let
            integerValue = pNumber as? Int,
            configValue = NBody.Config(rawValue: integerValue)
        {
            value = configValue
        }
    }
    private func _setIntegerValue(inout value: Int, with pNumber: AnyObject?) {
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
//
    private func _setCGFloatValue(inout value: CGFloat, with pNumber: AnyObject?) {
        if let cgFloatValue = pNumber as? CGFloat {
            value = cgFloatValue
        }
    }
    private func _setDoubleValue(inout value: Double, with pNumber: AnyObject?) {
        if let doubleValue = pNumber as? Double {
            value = doubleValue
        }
    }
//- (void) _setDoubleValue:(double &)value
//                    with:(NSNumber *)pNumber
//{
//    if(pNumber)
//    {
//        value = pNumber.doubleValue;
//    } // if
//} // _setDoubleValue
//
    private func _setFloatValue(inout value: Float, with pNumber: AnyObject?) {
        if let floatValue = pNumber as? Float {
            value = floatValue
        }
    }
//- (void) _setFloatValue:(float &)value
//                   with:(NSNumber *)pNumber
//{
//    if(pNumber)
//    {
//        value = pNumber.floatValue;
//    } // if
//} // _setFloatValue
//
    private func _setBoolValue(inout value: Bool, with pNumber: AnyObject?) {
        if let boolValue = pNumber as? Bool {
            value = boolValue
        }
    }
//- (void) _setBoolValue:(BOOL &)value
//                  with:(NSNumber *)pNumber
//{
//    if(pNumber)
//    {
//        value = pNumber.floatValue;
//    } // if
//} // _setBoolValue
//
//- (BOOL) _setPreferences:(NSDictionary *)pPrefs
//{
    private func _setPreferences(pPrefs: [String: AnyObject]) -> Bool {
//    BOOL success = pPrefs.count > 0;
        let success = !pPrefs.isEmpty
//
//    if(success)
//    {
        if success {
//        [self _setLongLongValue:_demos            with:pPrefs[kNBodyPrefDemos]];
            _setIntegerValue(&_demos, with: pPrefs[kNBodyPrefDemos])
//        [self _setUnsignedIntValue:_demoType      with:pPrefs[kNBodyPrefDemoType]];
            _setIntegerValue(&_demoType, with: pPrefs[kNBodyPrefDemoType])
//        [self _setUnsignedIntValue:_bodies        with:pPrefs[kNBodyPrefBodies]];
            _setIntegerValue(&_particles, with: pPrefs[kNBodyPrefParticles])
//        [self _setUnsignedIntValue:_config        with:pPrefs[kNBodyPrefConfig]];
            _setConfigValue(&_config, with: pPrefs[kNBodyPrefConfig])
//        [self _setUnsignedLongValue:_maxUpdates   with:pPrefs[kNBodyPrefMaxUpdates]];
            _setIntegerValue(&_maxUpdates, with: pPrefs[kNBodyPrefMaxUpdates])
//        [self _setUnsignedLongValue:_maxFramerate with:pPrefs[kNBodyPrefMaxFrameRate]];
            _setIntegerValue(&_maxFramerate, with: pPrefs[kNBodyPrefMaxFrameRate])
//        [self _setUnsignedLongValue:_maxPerf      with:pPrefs[kNBodyPrefMaxPerf]];
            _setIntegerValue(&_maxPerf, with: pPrefs[kNBodyPrefMaxPerf])
//        [self _setUnsignedLongValue:_maxCPU       with:pPrefs[kNBodyPrefMaxCPU]];
            _setIntegerValue(&_maxCPU, with: pPrefs[kNBodyPrefMaxCPU])
//        [self _setDoubleValue:_rotate.x           with:pPrefs[kNBodyPrefRotateX]];
            _setCGFloatValue(&_rotate.x, with: pPrefs[kNBodyPrefRotateX])
//        [self _setDoubleValue:_rotate.y           with:pPrefs[kNBodyPrefRotateY]];
            _setCGFloatValue(&_rotate.y, with: pPrefs[kNBodyPrefRotateY])
//        [self _setDoubleValue:_size.width         with:pPrefs[kNBodyPrefSizeWidth]];
            _setCGFloatValue(&_size.width, with: pPrefs[kNBodyPrefSizeWidth])
//        [self _setDoubleValue:_size.height        with:pPrefs[kNBodyPrefSizeHeight]];
            _setCGFloatValue(&_size.height, with: pPrefs[kNBodyPrefSizeHeight])
//        [self _setFloatValue:_clearColor          with:pPrefs[kNBodyPrefClearColor]];
            _setFloatValue(&_clearColor, with: pPrefs[kNBodyPrefClearColor])
//        [self _setFloatValue:_starScale           with:pPrefs[kNBodyPrefStarScale]];
            _setFloatValue(&_starScale, with: pPrefs[kNBodyPrefStarScale])
//        [self _setFloatValue:_viewDistance        with:pPrefs[kNBodyPrefViewDistance]];
            _setFloatValue(&_viewDistance, with: pPrefs[kNBodyPrefViewDistance])
//        [self _setFloatValue:_timeStep            with:pPrefs[kNBodyPrefTimeStep]];
            _setFloatValue(&_timeStep, with: pPrefs[kNBodyPrefTimeStep])
//        [self _setFloatValue:_clusterScale        with:pPrefs[kNBodyPrefClusterScale]];
            _setFloatValue(&_clusterScale, with: pPrefs[kNBodyPrefClusterScale])
//        [self _setFloatValue:_velocityScale       with:pPrefs[kNBodyPrefVelocityScale]];
            _setFloatValue(&_velocityScale, with: pPrefs[kNBodyPrefVelocityScale])
//        [self _setFloatValue:_softening           with:pPrefs[kNBodyPrefSoftening]];
            _setFloatValue(&_softening, with: pPrefs[kNBodyPrefSoftening])
//        [self _setFloatValue:_damping             with:pPrefs[kNBodyPrefDamping]];
            _setFloatValue(&_damping, with: pPrefs[kNBodyPrefDamping])
//        [self _setFloatValue:_pointSize           with:pPrefs[kNBodyPrefPointSize]];
            _setFloatValue(&_pointSize, with: pPrefs[kNBodyPrefPointSize])
//        [self _setBoolValue:_fullscreen           with:pPrefs[kNBodyPrefFullScreen]];
            _setBoolValue(&_fullscreen, with: pPrefs[kNBodyPrefFullScreen])
//        [self _setBoolValue:_isGPUOnly            with:pPrefs[kNBodyPrefIsGPUOnly]];
            _setBoolValue(&_isGPUOnly, with: pPrefs[kNBodyPrefIsGPUOnly])
//        [self _setBoolValue:_showUpdates          with:pPrefs[kNBodyPrefShowUpdates]];
            _setBoolValue(&_showUpdates, with: pPrefs[kNBodyPrefShowUpdates])
//        [self _setBoolValue:_showFramerate        with:pPrefs[kNBodyPrefShowFrameRate]];
            _setBoolValue(&_showFramerate, with: pPrefs[kNBodyPrefShowFrameRate])
//        [self _setBoolValue:_showCPU              with:pPrefs[kNBodyPrefShowCPU]];
            _setBoolValue(&_showCPU, with: pPrefs[kNBodyPrefShowCPU])
//        [self _setBoolValue:_showPerf             with:pPrefs[kNBodyPrefShowPerf]];
            _setBoolValue(&_showPerf, with: pPrefs[kNBodyPrefShowPerf])
//        [self _setBoolValue:_showDock             with:pPrefs[kNBodyPrefShowDock]];
            _setBoolValue(&_showDock, with: pPrefs[kNBodyPrefShowDock])
//    } // if
        }
//
//    return success;
        return success
//} // _setPreferences
    }
//
//- (NSMutableDictionary *) _newPreferences
//{
    private func _newPreferences() -> [String: AnyObject] {
        return [kNBodyPrefDemos: 7,
            kNBodyPrefDemoType: 1,
            kNBodyPrefParticles: NBody.Particles.kCount,
            kNBodyPrefConfig: NBody.Config.Shell.rawValue,
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
//    _demos         = 7;
//    _demoType      = 1;
//    _bodies        = NBody::Bodies::kCount;
//    _config        = NBody::Config::eConfigShell;
//    _maxFramerate  = 120;
//    _maxUpdates    = 120;
//    _maxCPU        = 100;
//    _maxPerf       = 1400;
//    _rotate.x      = 0.0f;
//    _rotate.y      = 0.0f;
//    _size.width    = NBody::Window::kWidth;
//    _size.height   = NBody::Window::kHeight;
//    _clearColor    = 1.0f;
//    _starScale     = 1.0f;
//    _viewDistance  = 30.0f;
//    _timeStep      = NBody::Scale::kTime * 0.016f;
//    _clusterScale  = 1.54f;
//    _velocityScale = 8.0f;
//    _softening     = NBody::Scale::kSoftening * 0.1f;
//    _damping       = 1.0f;
//    _pointSize     = 1.0f;
//    _fullscreen    = NO;
//    _isGPUOnly     = NO;
//    _showUpdates   = NO;
//    _showFramerate = NO;
//    _showCPU       = NO;
//    _showPerf      = YES;
//    _showDock      = YES;
//
//    NSArray* pKeys = @[kNBodyPrefDemos,
//                       kNBodyPrefDemoType,
//                       kNBodyPrefBodies,
//                       kNBodyPrefConfig,
//                       kNBodyPrefMaxUpdates,
//                       kNBodyPrefMaxFrameRate,
//                       kNBodyPrefMaxCPU,
//                       kNBodyPrefMaxPerf,
//                       kNBodyPrefRotateX,
//                       kNBodyPrefRotateY,
//                       kNBodyPrefSizeWidth,
//                       kNBodyPrefSizeHeight,
//                       kNBodyPrefClearColor,
//                       kNBodyPrefStarScale,
//                       kNBodyPrefViewDistance,
//                       kNBodyPrefTimeStep,
//                       kNBodyPrefClusterScale,
//                       kNBodyPrefVelocityScale,
//                       kNBodyPrefSoftening,
//                       kNBodyPrefDamping,
//                       kNBodyPrefPointSize,
//                       kNBodyPrefFullScreen,
//                       kNBodyPrefIsGPUOnly,
//                       kNBodyPrefShowUpdates,
//                       kNBodyPrefShowFrameRate,
//                       kNBodyPrefShowCPU,
//                       kNBodyPrefShowPerf,
//                       kNBodyPrefShowDock];
//
//    NSArray* pObjects = @[@(_demos),
//                          @(_demoType),
//                          @(_bodies),
//                          @(_config),
//                          @(_maxUpdates),
//                          @(_maxFramerate),
//                          @(_maxCPU),
//                          @(_maxPerf),
//                          @(_rotate.x),
//                          @(_rotate.y),
//                          @(_size.width),
//                          @(_size.height),
//                          @(_clearColor),
//                          @(_starScale),
//                          @(_viewDistance),
//                          @(_timeStep),
//                          @(_clusterScale),
//                          @(_velocityScale),
//                          @(_softening),
//                          @(_damping),
//                          @(_pointSize),
//                          @(_fullscreen),
//                          @(_isGPUOnly),
//                          @(_showUpdates),
//                          @(_showFramerate),
//                          @(_showCPU),
//                          @(_showPerf),
//                          @(_showDock)];
//
//    return [[NSMutableDictionary alloc] initWithObjects:pObjects
//                                                forKeys:pKeys];
//} // _newPreferences
    }
//
//- (instancetype) init
//{
    override init() {
//    self = [super init];
        super.init()
//
//    if(self)
//    {
//        NSMutableDictionary* pPrefsDst = [self _newPreferences];
        var pPrefsDst = self._newPreferences()
//
//        if(pPrefsDst)
//        {
//            _identifier = [[[NSBundle mainBundle] bundleIdentifier] retain];
        _identifier = NSBundle.mainBundle().bundleIdentifier
//
//            if(_identifier)
//            {
        if let _identifier = _identifier {
//                mpFile = [[NSFile alloc] initWithDomain:NSUserDomainMask
            mpFile = NSFile(domain: .UserDomainMask,
                search: .LibraryDirectory,
                directory: "Preferences",
                file: _identifier,
                ofExtension: "plist")
//                                                 search:NSLibraryDirectory
//                                              directory:@"Preferences"
//                                                   file:_identifier
//                                              extension:@"plist"];
//
//                if(mpFile)
//                {
            if let mpFile = mpFile {
//                    NSMutableDictionary* pPrefsSrc = [[NSMutableDictionary alloc] initWithDictionary:mpFile.plist];
                if let pPrefsSrc = mpFile.plist as? [String: AnyObject] {
//
//                    if(pPrefsSrc)
//                    {
//                        [self _setPreferences:pPrefsSrc];
                    self._setPreferences(pPrefsSrc)
//
//                        [pPrefsDst addEntriesFromDictionary:pPrefsSrc];
                    pPrefsDst.addEntriesFromDictionary(pPrefsSrc)
//
//                        [pPrefsSrc release];
//                    } // if
                }
                
                mpFile.replace(pPrefsDst)
                
                mpFile.write()
//                } // if
            }
//            } // if
        }
//
//            mpPreferences = pPrefsDst;
        mpPreferences = pPrefsDst
//
//            [mpFile replace:mpPreferences];
//
//            [mpFile write];
//        } // if
//    } // if
//
//    return self;
//} // if
    }
//
//+ (instancetype) preferences
//{
//    return([[[NBodyPreferences allocWithZone:[self zone]] init] autorelease]);
//} // preferences
//
//- (void) dealloc
//{
//    if(mpFile)
//    {
//        [mpFile release];
//
//        mpFile = nil;
//    } // if
//
//    if(_identifier)
//    {
//        [_identifier release];
//
//        _identifier = nil;
//    } // if
//
//    if(mpPreferences)
//    {
//        [mpPreferences release];
//
//        mpPreferences = nil;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
//- (BOOL) addEntries:(NBodyPreferences *)preferences;
//{
    func addEntries(preferences: NBodyPreferences?) -> Bool {
//    BOOL success = NO;
//
//    if(preferences)
//    {
        guard let preferences = preferences else {return false}
//        NSDictionary* pPreferences = preferences.preferences;
        let pPreferences = preferences.preferences
//
//        if(pPreferences)
//        {
//            success = [self _setPreferences:pPreferences];
        guard self._setPreferences(pPreferences) else {return false}
//
//            if(success)
//            {
//                [mpPreferences addEntriesFromDictionary:pPreferences];
            mpPreferences.addEntriesFromDictionary(pPreferences)
//
//                [mpFile replace:mpPreferences];
            mpFile?.replace(mpPreferences)
//
//                [mpFile write];
            mpFile?.write()
//            } // if
//        } // if
//    } // if
//
//    return success;
        return true
//} // update
    }
//
//- (NSDictionary *) preferences
//{
    var preferences: [String: AnyObject] {
//    return mpPreferences;
        return mpPreferences
//} // if
    }
//
//- (BOOL) write
//{
    func write() -> Bool {
//    [mpFile replace:mpPreferences];
        mpFile?.replace(mpPreferences)
//
//    return [mpFile write];
        return mpFile?.write() ?? false
//} // write
    }
//
    var demos: Int {
        get {return _demos}
//- (void) setDemos:(int64_t)demos
//{
        set {
//    _demos = demos;
            _demos = newValue
//
//    mpPreferences[kNBodyPrefDemos] = @(_demos);
            mpPreferences[kNBodyPrefDemos] = _demos
//} // setConfigs
        }
    }
//
    var particles: Int {
        get {return _particles}
//- (void) setBodies:(uint32_t)bodies
//{
        set {
//    _bodies = (bodies) ? bodies : NBody::Bodies::kCount;
            _particles = (newValue != 0) ? newValue : NBody.Particles.kCount
//
//    mpPreferences[kNBodyPrefBodies] = @(_bodies);
            mpPreferences[kNBodyPrefParticles] = _particles
//} // setBodies
        }
    }
//
    var demoType: Int {
        get {return _demoType}
//- (void) setDemoType:(uint32_t)demoType
//{
        set {
//    _demoType = (demoType > 6) ? 1 : demoType;
            _demoType = (newValue > 6 || newValue < 0) ? 1 : newValue
//
//    mpPreferences[kNBodyPrefDemoType] = @(_demoType);
            mpPreferences[kNBodyPrefDemoType] = _demoType
//} // setDemoType
        }
    }
//
    var config: NBody.Config {
        get {return _config}
//- (void) setConfig:(uint32_t)config
//{
        set {
//    _config = config;
            _config = newValue
//
//    mpPreferences[kNBodyPrefConfig] = @(_config);
            mpPreferences[kNBodyPrefConfig] = _config.rawValue
//} // setConfig
        }
    }
//
    var maxFramerate: Int {
        get {return _maxFramerate}
//- (void) setMaxFramerate:(size_t)maxFramerate
//{
        set {
//    _maxFramerate = maxFramerate;
            _maxFramerate = newValue
//
//    mpPreferences[kNBodyPrefMaxFrameRate] = @(_maxFramerate);
            mpPreferences[kNBodyPrefMaxFrameRate] = _maxFramerate
//} // setMaxFramerate
        }
    }
//
    var maxCPU: Int {
        get {return _maxCPU}
//- (void) setMaxCPU:(size_t)maxCPU
//{
        set {
//    _maxCPU = maxCPU;
            _maxCPU = newValue
//
//    mpPreferences[kNBodyPrefMaxCPU] = @(_maxCPU);
            mpPreferences[kNBodyPrefMaxCPU] = _maxCPU
//} // maxCPU
        }
    }
//
    var maxPerf: Int {
        get {return _maxPerf}
//- (void) setMaxPerf:(size_t)maxPerf
//{
        set {
//    _maxPerf = maxPerf;
            _maxPerf = newValue
//
//    mpPreferences[kNBodyPrefMaxPerf] = @(_maxPerf);
            mpPreferences[kNBodyPrefMaxPerf] = _maxPerf
//} // setMaxPerf
        }
    }
//
    var maxUpdates: Int {
        get {return _maxUpdates}
//- (void) setMaxUpdates:(size_t)maxUpdates
//{
        set {
//    _maxUpdates = maxUpdates;
            _maxUpdates = newValue
//
//    mpPreferences[kNBodyPrefMaxUpdates] = @(_maxUpdates);
            mpPreferences[kNBodyPrefMaxUpdates] = _maxUpdates
//} // setMaxUpdates
        }
    }
//
    var clearColor: Float {
        get {return _clearColor}
//- (void) setClearColor:(float)clearColor
//{
        set {
//    _clearColor = clearColor;
            _clearColor = newValue
//
//    mpPreferences[kNBodyPrefClearColor] = @(_clearColor);
            mpPreferences[kNBodyPrefClearColor] = _clearColor
//} // setClearColor
        }
    }
//
    var starScale: Float {
        get {return _starScale}
//- (void) setStarScale:(float)starScale
//{
        set {
//    _starScale = (starScale >= 0.125f) ? starScale : 1.0f;
            _starScale = (newValue >= 0.125) ? newValue : 1.0
//
//    mpPreferences[kNBodyPrefStarScale] = @(_starScale);
            mpPreferences[kNBodyPrefStarScale] = _starScale
//} // setStarScale
        }
    }
//
    var rotate: NSPoint {
        get {return _rotate}
//- (void) setRotate:(NSPoint)rotate
//{
        set {
//    _rotate.x = rotate.x;
            _rotate = newValue
//    _rotate.y = rotate.y;
//
//    mpPreferences[kNBodyPrefRotateX] = @(_rotate.x);
            mpPreferences[kNBodyPrefRotateX] = _rotate.x
//    mpPreferences[kNBodyPrefRotateY] = @(_rotate.y);
            mpPreferences[kNBodyPrefRotateY] = _rotate.y
//} // setRotate
        }
    }
//
    var size: NSSize {
        get {return _size}
//- (void) setSize:(NSSize)size
//{
        set {
//    _size.width  = (size.width  > 256.0f) ? size.width  : NBody::Window::kWidth;
            _size.width  = (newValue.width  > 256.0) ? newValue.width  : NBody.Window.kWidth.g
//    _size.height = (size.height > 256.0f) ? size.height : NBody::Window::kHeight;
            _size.height = (newValue.height > 256.0) ? newValue.height : NBody.Window.kHeight.g
//
//    mpPreferences[kNBodyPrefSizeWidth]  = @(_size.width);
            mpPreferences[kNBodyPrefSizeWidth]  = _size.width
//    mpPreferences[kNBodyPrefSizeHeight] = @(_size.height);
            mpPreferences[kNBodyPrefSizeHeight] = _size.height
//} // setSize
        }
    }
//
    var viewDistance: Float {
        get {return _viewDistance}
//- (void) setViewDistance:(float)viewDistance
//{
        set {
//    _viewDistance = viewDistance;
            _viewDistance = newValue
//
//    mpPreferences[kNBodyPrefViewDistance] = @(_viewDistance);
            mpPreferences[kNBodyPrefViewDistance] = _viewDistance
//} // setViewDistance
        }
    }
//
    var timeStep: Float {
        get {return _timeStep}
//- (void) setTimeStep:(float)timeStep
//{
        set {
//    _timeStep = timeStep;
            _timeStep = newValue
//
//    mpPreferences[kNBodyPrefTimeStep] = @(_timeStep);
            mpPreferences[kNBodyPrefTimeStep] = _timeStep
//} // setTimeStep
        }
    }
//
    var clusterScale: Float {
        get {return _clusterScale}
//- (void) setClusterScale:(float)clusterScale
//{
        set {
//    _clusterScale = clusterScale;
            _clusterScale = newValue
//
//    mpPreferences[kNBodyPrefClusterScale] = @(_clusterScale);
            mpPreferences[kNBodyPrefClusterScale] = _clusterScale
//} // setClusterScale
        }
    }
//
    var velocityScale: Float {
        get {return _velocityScale}
//- (void) setVelocityScale:(float)velocityScale
//{
        set {
//    _velocityScale = velocityScale;
            _velocityScale = newValue
//
//    mpPreferences[kNBodyPrefVelocityScale] = @(_velocityScale);
            mpPreferences[kNBodyPrefVelocityScale] = _velocityScale
//} // setVelocityScale
        }
    }
//
    var softening: Float {
        get {return _softening}
//- (void) setSoftening:(float)softening
//{
        set {
//    _softening = softening;
            _softening = newValue
//
//    mpPreferences[kNBodyPrefSoftening] = @(_softening);
            mpPreferences[kNBodyPrefSoftening] = _softening
//} // setSoftening
        }
    }
//
    var damping: Float {
        get {return _damping}
//- (void) setDamping:(float)damping
//{
        set {
//    _damping = damping;
            _damping = newValue
//
//    mpPreferences[kNBodyPrefDamping] = @(_damping);
            mpPreferences[kNBodyPrefDamping] = _damping
//} // setOscillation
        }
    }
//
    var pointSize: Float {
        get {return _pointSize}
//- (void) setPointSize:(float)pointSize
//{
        set {
//    _pointSize = pointSize;
            _pointSize = newValue
//
//    mpPreferences[kNBodyPrefPointSize] = @(_pointSize);
            mpPreferences[kNBodyPrefPointSize] = _pointSize
//} // setPointSize
        }
    }
//
    var fullscreen: Bool {
        get {return _fullscreen}
//- (void) setFullscreen:(BOOL)fullscreen
//{
        set {
//    _fullscreen = fullscreen;
            _fullscreen = newValue
//
//    mpPreferences[kNBodyPrefFullScreen] = @(_fullscreen);
            mpPreferences[kNBodyPrefFullScreen] = _fullscreen
//} // setFullscreen
        }
    }
//
    var GPUOnly: Bool {
        get {return _isGPUOnly}
//- (void) setIsGPUOnly:(BOOL)isGPUOnly
//{
        set {
//    _isGPUOnly = isGPUOnly;
            _isGPUOnly = newValue
//
//    mpPreferences[kNBodyPrefIsGPUOnly] = @(_isGPUOnly);
            mpPreferences[kNBodyPrefIsGPUOnly] = _isGPUOnly
//} // setIsGPUOnly
        }
    }
//
    var showUpdates: Bool {
        get {return _showUpdates}
//- (void) setShowUpdates:(BOOL)showUpdates
//{
        set {
//    _showUpdates = showUpdates;
            _showUpdates = newValue
//
//    mpPreferences[kNBodyPrefShowUpdates] = @(_showUpdates);
            mpPreferences[kNBodyPrefShowUpdates] = _showUpdates
//} // setShowUpdates
        }
    }
//
    var showFramerate: Bool {
        get {return _showFramerate}
//- (void) setShowFramerate:(BOOL)showFramerate
//{
        set {
//    _showFramerate = showFramerate;
            _showFramerate = newValue
//
//    mpPreferences[kNBodyPrefShowFrameRate] = @(_showFramerate);
            mpPreferences[kNBodyPrefShowFrameRate] = _showFramerate
//} // setShowFramerate
        }
    }
//
    var showPerf: Bool {
        get {return _showPerf}
//- (void) setShowPerf:(BOOL)showPerf
//{
        set {
//    _showPerf = showPerf;
            _showPerf = newValue
//
//    mpPreferences[kNBodyPrefShowPerf] = @(_showPerf);
            mpPreferences[kNBodyPrefShowPerf] = _showPerf
//} // setShowPref
        }
    }
//
    var showDock: Bool {
        get {return _showDock}
//- (void) setShowDock:(BOOL)showDock
//{
        set {
//    _showDock = showDock;
            _showDock = newValue
//
//    mpPreferences[kNBodyPrefShowDock] = @(_showDock);
            mpPreferences[kNBodyPrefShowDock] = _showDock
//} // setShowDock
        }
    }
//
    var showCPU: Bool {
        get {return _showCPU}
//- (void) setShowCPU:(BOOL)showCPU
//{
        set {
//    _showCPU = showCPU;
            _showCPU = newValue
//
//    mpPreferences[kNBodyPrefShowCPU] = @(_showCPU);
            mpPreferences[kNBodyPrefShowCPU] = _showCPU
//} // setShowCPU
        }
    }
//
//@end
}