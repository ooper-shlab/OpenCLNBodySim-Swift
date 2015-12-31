//
//  NBodyEngine.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/7/5.
//
//
/*
<codex>
<abstract>
These methods performs an NBody simulation which calculates a gravity field
and corresponding velocity and acceleration contributions accumulated
by each body in the system from every other body.  This example
also shows how to mitigate computation between all available devices
including CPU and GPU devices, as well as a hybrid combination of both,
using separate threads for each simulator.
</abstract>
</codex>
 */
//
//#import <Cocoa/Cocoa.h>
import Cocoa
//#import <OpenGL/OpenGL.h>
import OpenGL.GL
//
//#import "NBodyPreferences.h"
let kMeterDefaultMaxFPS: size_t      = 120;
let kMeterDefaultMaxUpdates :size_t  = 120;
let kMeterDefaultMaxPerf: size_t     = 1400;
let kMeterDefaultMaxCPUUsage: size_t = 100;
//
//@interface NBodyEngine : NSObject
@objc(NBodyEngine)
class NBodyEngine: NSObject {
//
//@property (nonatomic, readonly) NBodyPreferences* preferences;
    private(set) var preferences: NBodyPreferences?
//
//@property (nonatomic, readonly) BOOL    isResized;
    private(set) var resized: Bool = false
//@property (nonatomic, readonly) NSSize  size;
    private(set) var size: NSSize = NSSize()
//
//@property (nonatomic) unichar  command;
    var command: unichar = 0 {
        willSet{willSetCommand(newValue)}
    }
//@property (nonatomic) GLuint   activeDemo;
    private var _activeDemo: Int = 0
//@property (nonatomic) GLfloat  clearColor;
    private var _clearColor: GLfloat = 0
//@property (nonatomic) GLfloat  viewDistance;
    var viewDistance: GLfloat = 0 {
        didSet{didSetViewDistance(oldValue)}
    }
//@property (nonatomic) NSRect   frame;
    var frame: NSRect = NSRect() {
        willSet{willSetFrame(newValue)}
    }
//
//- (instancetype) initWithPreferences:(NBodyPreferences *)preferences;
//
//+ (instancetype) engine;
//
//+ (instancetype) engineWithPreferences:(NBodyPreferences *)preferences;
//
//- (BOOL) acquire;
//
//- (void) draw;
//
//- (void) resize:(NSRect)frame;
//
//- (void) scroll:(GLfloat)delta;
//
//- (void) click:(GLint)state
//         point:(NSPoint)point;
//
//- (void) move:(NSPoint)point;
//
//@end
//
//#pragma mark -
//#pragma mark Private - Headers
//
//#import <OpenGL/gl.h>
//
//#import "GLMConstants.h"
//
//#import "NBodyConstants.h"
//#import "NBodyButtons.h"
//#import "NBodyMeters.h"
//
//#import "NBodySimulationMediator.h"
//#import "NBodyPreferences.h"
//#import "NBodySimulationVisualizer.h"
//
//#import "NBodyEngine.h"
//
//static const size_t kMeterDefaultMaxFPS      = 120;
//static const size_t kMeterDefaultMaxUpdates  = 120;
//static const size_t kMeterDefaultMaxPerf     = 1400;
//static const size_t kMeterDefaultMaxCPUUsage = 100;
//
//@implementation NBodyEngine
//{
//@private
//    // Properties
//    BOOL  _isResized;
//    BOOL  _fullscreen;
//
//    unichar _command;
//
//    GLuint   _activeDemo;
//
//    GLfloat  _clearColor;
//    GLfloat  _viewDistance;
//
//    NSSize _size;
//    NSRect _frame;
//
//    NBodyPreferences* _preferences;
//
//    // Instance Variables
//    BOOL mbIsWaiting;
    private var mbIsWaiting: Bool = false
//    BOOL mbIsRotating;
    private var mbIsRotating: Bool = false
//
//    GLuint  mnSimulatorIndex;
    private var mnSimulatorIndex: Int = 0
//    GLuint  mnSimulatorCount;
    private var mnSimulatorCount: Int = 0
//
//    GLfloat   mnStarScale;
    private var mnStarScale: GLfloat = 0.0
//
//    GLsizei   mnWidowWidth;
    private var mnWidowWidth: Int = 0
//    GLsizei   mnWidowHeight;
    private var mnWidowHeight: Int = 0
//
//    NSPoint   m_MousePt;
    private var m_MousePt: NSPoint = NSPoint()
//    NSPoint   m_Rotation;
    private var m_Rotation: NSPoint = NSPoint()
//
//    NBody::Simulation::Properties  m_Properties;
    private var m_Properties: NBody.Simulation.Properties?
//
//    NBodyMeters*  mpMeters;
    private var mpMeters: NBodyMeters?
//    NBodyButtons* mpButtons;
    private var mpButtons: NBodyButtons?
//
//    NBody::Simulation::Mediator*   mpMediator;
    private var mpMediator: NBody.Simulation.Mediator?
//    NBody::Simulation::Visualizer* mpVisualizer;
    private var mpVisualizer: NBody.Simulation.Visualizer?
//}
//
//#pragma mark -
//#pragma mark Private - Utiltites - Scene
//
//- (void) _reset
//{
    private func _reset() {
//    mpVisualizer->stopRotation();
        mpVisualizer?.stopRotation()
//    mpVisualizer->setRotationSpeed(0.0f);
        mpVisualizer?.setRotationSpeed(0.0)
//
//    mpMediator->reset();
        mpMediator?.reset()
//    mpVisualizer->reset(_activeDemo);
        mpVisualizer?.reset(activeDemo)
//} // _reset
    }
//
//- (void) _restart
//{
    private func _restart() {
//    mpVisualizer->setViewRotation(m_Rotation);
        mpVisualizer?.setViewRotation(m_Rotation)
//    mpVisualizer->setViewZoom(_viewDistance);
        mpVisualizer?.setViewZoom(viewDistance)
//    mpVisualizer->setViewTime(0.0f);
        mpVisualizer?.setViewTime(0.0)
//    mpVisualizer->setIsResetting(YES);
        mpVisualizer?.setIsResetting(true)
//    mpVisualizer->stopRotation();
        mpVisualizer?.stopRotation()
//} // _restart
    }
//
//- (void) _nextSimulator
//{
    private func _nextSimulator() {
//    mbIsWaiting = YES;
        mbIsWaiting = true
//
//    mnSimulatorIndex++;
        mnSimulatorIndex++
//
//    if(mnSimulatorIndex >= mnSimulatorCount)
//    {
        if mnSimulatorIndex >= mnSimulatorCount {
//        mnSimulatorIndex = 0;
            mnSimulatorIndex = 0
//    } // if
        }
//
//    mpMediator->pause();
        mpMediator?.pause()
//    mpMediator->select(mnSimulatorIndex);
        mpMediator?.select(mnSimulatorIndex)
//    mpMediator->reset();
        mpMediator?.reset()
//
//    mpButtons.index      = mnSimulatorIndex;
        mpButtons?.index      = mnSimulatorIndex
//    mpButtons.size       = _size;
        mpButtons?.size       = size
//    mpButtons.isSelected = YES;
        mpButtons?.selected = true
//} // _nextSimulator
    }
//
//- (void) _nextDemo
//{
    private func _nextDemo() {
//    _activeDemo = (_activeDemo + 1) % m_Properties.mnDemos;
        _activeDemo = (_activeDemo + 1) % (m_Properties?.mnDemos ?? 1)
//
//    [self _reset];
        self._reset()
//
//    _preferences.demoType = _activeDemo;
        preferences?.demoType = _activeDemo
//} // _nextDemo
    }
//
//- (void) _swapVisualizer
//{
    private func _swapVisualizer() {
//    [self draw];
        self.draw()
//
//    mbIsWaiting = YES;
        mbIsWaiting = true
//
//    mpVisualizer->reset(_activeDemo);
        mpVisualizer?.reset(_activeDemo)
//} // _swapVisualizer
    }
//
//- (void) _swapSimulators
//{
    private func _swapSimulators() {
//    [self draw];
        self.draw()
//
//    [self _nextSimulator];
        self._nextSimulator()
//
//    mpVisualizer->reset(_activeDemo);
        mpVisualizer?.reset(_activeDemo)
//
//    // Reset the target values of meters
//    [mpMeters reset];
        mpMeters?.reset()
//} // _swapSimulators
    }
//
//- (void) _swapInterval:(const BOOL)doSync
//{
    private func _swapInterval(doSync: Bool) {
//    CGLContextObj pContext = CGLGetCurrentContext();
        let pContext = CGLGetCurrentContext()
//
//    if(pContext != nullptr)
//    {
//        const GLint sync = GLint(doSync);
            var sync: GLint = doSync ? 1 : 0
//
//        CGLSetParameter(pContext,
            CGLSetParameter(pContext,
//                        kCGLCPSwapInterval,
                kCGLCPSwapInterval,
//                        &sync);
                &sync)
//    } // if
//} // _swapInterval
    }
//
//- (void) _drawScene
//{
    private func _drawScene() {
//    // Render stars
//    const GLfloat* pPosition = mpMediator->position();
        let pPosition = mpMediator?.position ?? nil
//
//    mpVisualizer->draw(pPosition);
        mpVisualizer?.draw(pPosition)
//
//    // Update and render the performance meters
//    mpMeters.index = NBody::eNBodyMeterFrames;
        mpMeters?.index = NBody.MeterType.Frames
//    mpMeters.point = NSMakePoint(208.0f, 160.0f);
        mpMeters?.point = NSMakePoint(208.0, 160.0)
//
//    [mpMeters update];
        mpMeters?.update()
//    [mpMeters draw];
        mpMeters?.draw()
//
//    mpMeters.index = NBody::eNBodyMeterCPU;
        mpMeters?.index = NBody.MeterType.CPU
//    mpMeters.point = NSMakePoint(208.0f + 0.25f * _size.width, 160.0f);
        mpMeters?.point = NSMakePoint(208.0 + 0.25 * size.width, 160.0)
//
//    [mpMeters update];
        mpMeters?.update()
//    [mpMeters draw];
        mpMeters?.draw()
//
//    mpMeters.index = NBody::eNBodyMeterUpdates;
        mpMeters?.index = NBody.MeterType.Updates
//    mpMeters.point = NSMakePoint(0.75f * _size.width - 208.0f, 160.0f);
        mpMeters?.point = NSMakePoint(0.75 * size.width - 208.0, 160.0)
//    mpMeters.value = mpMediator->updates();
        mpMeters?.value = mpMediator?.updates ?? 0.0
//
//    [mpMeters update];
        mpMeters?.update()
//    [mpMeters draw];
        mpMeters?.draw()
//
//    mpMeters.index = NBody::eNBodyMeterPerf;
        mpMeters?.index = NBody.MeterType.Perf
//    mpMeters.point = NSMakePoint(_size.width - 208.0f, 160.0f);
        mpMeters?.point = NSMakePoint(size.width - 208.0, 160.0)
//    mpMeters.value = mpMediator->performance();
        mpMeters?.value = mpMediator?.performance ?? 0.0
//
//    [mpMeters update];
        mpMeters?.update()
//    [mpMeters draw];
        mpMeters?.draw()
//
//    // Draw the button(s) in the dock
//    [mpButtons draw];
        mpButtons?.draw()
//} // _drawScene
    }
//
//- (void) _setDemo:(const GLuint)activeDemo
//{
    private func _setDemo(newValue: Int) {
//    _activeDemo = activeDemo;
        _activeDemo = newValue
//
//    [self _reset];
        self._reset()
//
//    _preferences.demoType = _activeDemo;
        preferences?.demoType = _activeDemo
//} // _setDemo
    }
//
//- (void) _selectDemo:(const unichar)command
//{
    private func _selectDemo(command: unichar) {
//    if(command != _command)
//    {
        if command != self.command {
//        GLuint demo = GLuint(command - '0');
            let demo = Int(command - "0")
//
//        if(demo < m_Properties.mnDemos)
//        {
            if demo < (m_Properties?.mnDemos ?? 1) {
//            [self _setDemo:demo];
                self._setDemo(demo)
//        } // if
            }
//
//        _command = command;
            self.command = command
//    } // if
        }
//} // _selectDemo
    }
//
//#pragma mark -
//#pragma mark Private - Utiltites - Constructors
//
//- (BOOL) _newSimulators
//{
    private func _newSimulators() -> Bool {
//    mpMediator = new (std::nothrow) NBody::Simulation::Mediator(m_Properties);
        mpMediator = NBody.Simulation.Mediator(m_Properties!)
//
//    if(mpMediator != nullptr)
//    {
//        mnSimulatorIndex = 0;
        mnSimulatorIndex = 0
//        mnSimulatorCount = mpMediator->count();
        mnSimulatorCount = mpMediator!.count
//
//        mpMediator->reset();
        mpMediator!.reset()
//        mpVisualizer->reset(_activeDemo);
        mpVisualizer?.reset(_activeDemo)
//    } // if
//
//    return mnSimulatorCount > 0;
        return mnSimulatorCount > 0
//} // _newSimulators
    }
//
//- (BOOL) _newVisualizer
//{
    func _newVisualizer() -> Bool {
//    BOOL bSuccess = NO;
        var bSuccess = false
//
//    try
//    {
//        mpVisualizer = new NBody::Simulation::Visualizer(m_Properties);
        mpVisualizer = NBody.Simulation.Visualizer(m_Properties)
//
//        bSuccess = mpVisualizer->isValid();
        bSuccess = mpVisualizer!.valid
//
//        if(bSuccess)
//        {
        if bSuccess {
//            mpVisualizer->setFrame(_size);
            mpVisualizer!.setFrame(size)
//            mpVisualizer->setStarScale(mnStarScale);
            mpVisualizer!.setStarScale(mnStarScale)
//            mpVisualizer->setStarSize(NBody::Star::kSize);
            mpVisualizer!.setStarSize(NBody.Star.kSize.f)
//            mpVisualizer->setRotationChange(NBody::Defaults::kRotationDelta);
            mpVisualizer!.setRotationChange(NBody.Defaults.kRotationDelta.f)
//
//            bSuccess =             [self _newSimulators];
            bSuccess = self._newSimulators()
//            bSuccess = bSuccess && [self _newMeters:NBody::Defaults::kMeterSize];
            bSuccess = bSuccess && self._newMeters(NBody.Defaults.kMeterSize)
//            bSuccess = bSuccess && [self _newDock:mpMediator->count()];
            bSuccess = bSuccess && self._newDock(mpMediator?.count ?? 0)
//        } // if
        }
//    } // try
//    catch(std::bad_alloc& ba)
//    {
//        NSLog(@">> ERROR: Failed allocating backing-store for the engine: \"%s\"", ba.what());
//
//        bSuccess = NO;
//    } // catch
//
//    return bSuccess;
        return bSuccess
//} // _newVisualizer
    }
//
//- (BOOL) _newDock:(const size_t)count
//{
    private func _newDock(count: Int) -> Bool {
//    mpButtons = [[NBodyButtons alloc] initWithCount:count];
        mpButtons = NBodyButtons(count: count)
//
//    if(mpButtons)
//    {
//        size_t i;
//
//        for(i = 0; i < count; ++i)
//        {
        for i in 0..<count {
//            mpButtons.index = i;
            mpButtons!.index = i
//            mpButtons.label = mpMediator->label(NBody::Simulation::Types(i));
            mpButtons?.label = mpMediator?.label(NBody.Simulation.Types(rawValue: i)!) ?? ""
//            mpButtons.size  = _size;
            mpButtons!.size  = size
//
//            if(![mpButtons acquire])
//            {
            if !mpButtons!.acquire() {
//                return NO;
                return false
//            } // if
            }
//        } // for
        }
//
//        mpButtons.index = 0;
        mpButtons!.index = 0
//
//        return YES;
        return true
//    } // if
//
//    return NO;
//} // _newDock
    }
//
//- (BOOL) _newMeterFrames:(const GLsizei)length
//{
    private func _newMeterFrames(length: Int) -> Bool {
//    mpMeters.index     = NBody::eNBodyMeterFrames;
        mpMeters?.index     = .Frames
//    mpMeters.isVisible = (_preferences) ? _preferences.showFramerate : NO;
        mpMeters?.visible = preferences?.showFramerate ?? false
//    mpMeters.max       = (_preferences) ? _preferences.maxFramerate  : kMeterDefaultMaxFPS;
        mpMeters?.max       = preferences?.maxFramerate ?? kMeterDefaultMaxFPS
//    mpMeters.bound     = length;
        mpMeters?.bound     = length
//    mpMeters.label     = "Frames/sec";
        mpMeters?.label     = "Frames/sec"
//    mpMeters.useTimer  = YES;
        mpMeters?.useTimer  = true
//    mpMeters.frame     = _size;
        mpMeters?.frame     = size
//
//    return [mpMeters acquire];
        return mpMeters?.acquire() ?? false
//} // _newMeterFrames
    }
//
//- (BOOL) _newMeterUpdates:(const GLsizei)length
//{
    private func _newMeterUpdates(length: Int) -> Bool {
//    mpMeters.index     = NBody::eNBodyMeterUpdates;
        mpMeters?.index     = .Updates
//    mpMeters.isVisible = (_preferences) ? _preferences.showUpdates : NO;
        mpMeters?.visible = preferences?.showUpdates ?? false
//    mpMeters.max       = (_preferences) ? _preferences.maxUpdates  : kMeterDefaultMaxUpdates;
        mpMeters?.max       = preferences?.maxUpdates ?? kMeterDefaultMaxUpdates
//    mpMeters.bound     = length;
        mpMeters?.bound     = length
//    mpMeters.label     = "Updates/sec";
        mpMeters?.label     = "Updates/sec"
//    mpMeters.frame     = _size;
        mpMeters?.frame     = size
//
//    return [mpMeters acquire];
        return mpMeters?.acquire() ?? false
//} // _newMeterUpdates
    }
//
//- (BOOL) _newMeterPerf:(const GLsizei)length
//{
    private func _newMeterPerf(length: Int) -> Bool {
//    mpMeters.index     = NBody::eNBodyMeterPerf;
        mpMeters?.index     = .Perf
//    mpMeters.isVisible = (_preferences) ? _preferences.showPerf : YES;
        mpMeters?.visible = preferences?.showPerf ?? true
//    mpMeters.max       = (_preferences) ? _preferences.maxPerf  : kMeterDefaultMaxPerf;
        mpMeters?.max       = preferences?.maxPerf ?? kMeterDefaultMaxPerf
//    mpMeters.bound     = length;
        mpMeters?.bound     = length
//    mpMeters.label     = "Relative Perf";
        mpMeters?.label     = "Relative Perf"
//    mpMeters.frame     = _size;
        mpMeters?.frame     = size
//
//    return [mpMeters acquire];
        return mpMeters?.acquire() ?? false
//} // _newMeterPerf
    }
//
//- (BOOL) _newMeterCPU:(const GLsizei)length
//{
    private func _newMeterCPU(length: Int) -> Bool {
//    mpMeters.index       = NBody::eNBodyMeterCPU;
        mpMeters?.index       = .CPU
//    mpMeters.isVisible   = (_preferences) ? _preferences.showCPU : YES;
        mpMeters?.visible   = preferences?.showCPU ?? true
//    mpMeters.max         = (_preferences) ? _preferences.maxCPU  : kMeterDefaultMaxCPUUsage;
        mpMeters?.max         = preferences?.maxCPU ?? kMeterDefaultMaxCPUUsage
//    mpMeters.bound       = length;
        mpMeters?.bound       = length
//    mpMeters.label       = "% CPU Usage";
        mpMeters?.label       = "% CPU Usage"
//    mpMeters.useHostInfo = YES;
        mpMeters?.useHostInfo = true
//    mpMeters.frame       = _size;
        mpMeters?.frame       = size
//
//    return [mpMeters acquire];
        return mpMeters?.acquire() ?? false
//} // _newMeterCPU
    }
//
//- (BOOL) _newMeters:(const GLsizei)length
//{
    private func _newMeters(length: Int) -> Bool {
//    BOOL bSuccess = NO;
        var bSuccess = false
//
//    mpMeters = [[NBodyMeters alloc] initWithCount:4];
        mpMeters = NBodyMeters(count: 4)
//
//    if(mpMeters)
//    {
        if mpMeters != nil {
//        bSuccess =             [self _newMeterFrames:length];
            bSuccess = self._newMeterFrames(length)
//        bSuccess = bSuccess && [self _newMeterUpdates:length];
                && self._newMeterUpdates(length)
//        bSuccess = bSuccess && [self _newMeterPerf:length];
                && self._newMeterPerf(length)
//        bSuccess = bSuccess && [self _newMeterCPU:length];
                && self._newMeterCPU(length)
//    } // if
        }
//
//    return bSuccess;
        return bSuccess
//} // _newMeters
    }
//
//- (BOOL) _newPreferences:(NBodyPreferences *)preferences
//{
    private func _newPreferences(preferences: NBodyPreferences?) -> Bool {
//    if(preferences)
//    {
        if preferences != nil {
//        _preferences = [preferences retain];
            self.preferences = preferences
//    } // if
//    else
//    {
        } else {
//        _preferences = [NBodyPreferences new];
            self.preferences = NBodyPreferences()
//    } // else
        }
//
//    return preferences != nil;
        return preferences != nil
//} // _newPreferences
    }
//
//#pragma mark -
//#pragma mark Private - Utiltites - UI
//
//- (void) _resizeButtons
//{
    private func _resizeButtons() {
//    if(mpButtons)
//    {
        if let mpButtons = mpButtons {
//        mpButtons.index      = mnSimulatorIndex;
            mpButtons.index      = mnSimulatorIndex
//        mpButtons.size       = _size;
            mpButtons.size       = size
//        mpButtons.isSelected = YES;
            mpButtons.selected = true
//    } // if
        }
//} // _resizeButtons
    }
//
//- (void) _resizeMeters
//{
    private func _resizeMeters() {
//    if(mpMeters)
//    {
        if let mpMeters = mpMeters {
//        [mpMeters resize:_size];
            mpMeters.resize(size)
//    } // if
        }
//} // _resizeMeters
    }
//
//- (void) _toggleMeter:(const size_t)index
//{
    private func _toggleMeter(index: NBody.MeterType) {
//    mpMeters.index = index;
        mpMeters?.index = index
//
//    [mpMeters toggle];
        mpMeters?.toggle()
//
//    switch(index)
//    {
        switch index {
//        case NBody::eNBodyMeterPerf:
        case .Perf:
//            _preferences.showPerf = mpMeters.isVisible;
            preferences?.showPerf = mpMeters?.visible ?? false
//            break;
//
//        case NBody::eNBodyMeterUpdates:
        case .Updates:
//            _preferences.showUpdates = mpMeters.isVisible;
            preferences?.showUpdates = mpMeters?.visible ?? false
//            break;
//
//        case NBody::eNBodyMeterCPU:
        case .CPU:
//            _preferences.showCPU = mpMeters.isVisible;
            preferences?.showCPU = mpMeters?.visible ?? false
//            break;
//
//        case NBody::eNBodyMeterFrames:
        case .Frames:
//        default:
//            _preferences.showFramerate = mpMeters.isVisible;
            preferences?.showFramerate = mpMeters?.visible ?? false
//            break;
//    } // switch
        }
//} // _toggleMeter
    }
//
//- (void) _showMeters:(const BOOL)doShow
//{
    private func _showMeters(doShow: Bool) {
//    [mpMeters show:doShow];
        mpMeters?.show(doShow)
//
//    _preferences.showPerf      = doShow;
        preferences?.showPerf      = doShow
//    _preferences.showUpdates   = doShow;
        preferences?.showUpdates   = doShow
//    _preferences.showFramerate = doShow;
        preferences?.showFramerate = doShow
//    _preferences.showCPU       = doShow;
        preferences?.showCPU       = doShow
//} // _showMeters
    }
//
//- (void) _setDefaults
//{
    private func _setDefaults() {
//    _isResized = NO;
        resized = false
//    _command   = 0;
        command = 0
//    _frame     = NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f);
        frame     = NSMakeRect(0.0, 0.0, 0.0, 0.0)
//
//    mbIsWaiting      = YES;
        mbIsWaiting      = true
//    mbIsRotating     = YES;
        mbIsRotating     = true
//    mnSimulatorIndex = 0;
        mnSimulatorIndex = 0
//    mnSimulatorCount = 0;
        mnSimulatorCount = 0
//    mnWidowWidth     = GLsizei(_size.width);
        mnWidowWidth     = Int(size.width)
//    mnWidowHeight    = GLsizei(_size.height);
        mnWidowHeight    = Int(size.height)
//    m_MousePt        = NSMakePoint(0.0f, 0.0f);
        m_MousePt        = NSMakePoint(0.0, 0.0)
//    mpMediator       = nullptr;
        mpMediator       = nil
//    mpVisualizer     = nullptr;
        mpVisualizer     = nil
//    mpButtons        = nil;
        mpButtons        = nil
//    mpMeters         = nil;
        mpMeters         = nil
//} // _setDefaults
    }
//
//- (void) _setPreferences:(NBodyPreferences *)preferences
//{
    private func _setPreferences(preferences: NBodyPreferences?) {
//    if([self _newPreferences:preferences])
//    {
        if self._newPreferences(preferences) {
//        m_Properties = _preferences;
            m_Properties <<- self.preferences
//
//        _activeDemo   = _preferences.demoType;
            activeDemo   = self.preferences!.demoType
//        _clearColor   = _preferences.clearColor;
            clearColor   = self.preferences!.clearColor
//        _viewDistance = _preferences.viewDistance;
            viewDistance = self.preferences!.viewDistance
//        _size         = _preferences.size;
            size         = self.preferences!.size
//
//        mnStarScale = _preferences.starScale;
            mnStarScale = self.preferences!.starScale
//        m_Rotation  = _preferences.rotate;
            m_Rotation  = self.preferences!.rotate
//    } // if
//    else
//    {
        } else {
//        _activeDemo   = 1;
            activeDemo   = 1
//        _clearColor   = 1.0f;
            clearColor   = 1.0
//        _viewDistance = 30.0f;
            viewDistance = 30.0
//        _size         = NSMakeSize(NBody::Window::kWidth, NBody::Window::kHeight);
            size         = NSMakeSize(NBody.Window.kWidth.g, NBody.Window.kHeight.g)
//
//        mnStarScale = 1.0f;
            mnStarScale = 1.0
//        m_Rotation  = NSMakePoint(0.0f, 0.0f);
            m_Rotation  = NSMakePoint(0.0, 0.0)
//    } // else
        }
//} // _setPreferences
    }
//
//- (void) _setEnginePreferences:(NBodyPreferences *)preferences
//{
    private func _setEnginePreferences(preferences: NBodyPreferences?) {
//    [self _setPreferences:preferences];
        self._setPreferences(preferences)
//    [self _setDefaults];
        self._setDefaults()
//} // _setEnginePreferences
    }
//
//#pragma mark -
//#pragma mark Public
//
//- (instancetype) init
//{
    override init() {
//    self = [super init];
        super.init()
//
//    if(self)
//    {
//        [self _setEnginePreferences:nil];
        self._setEnginePreferences(nil)
//    } // if
//
//    return self;
//} // init
    }
//
//- (instancetype) initWithPreferences:(NBodyPreferences *)preferences
//{
    init(preferences: NBodyPreferences?) {
//    self = [super init];
        super.init()
//
//    if(self)
//    {
//        [self _setEnginePreferences:preferences];
        self._setEnginePreferences(preferences)
//    } // if
//
//    return self;
//} // if
    }
//
//+ (instancetype) engine
//{
//    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:nil] autorelease];
//} // engine
//
//+ (instancetype) engineWithPreferences:(NBodyPreferences *)preferences
//{
//    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:preferences] autorelease];
//} // engineWithPreferences
//
//- (void) dealloc
//{
//    if(_preferences)
//    {
//        [_preferences release];
//
//        _preferences = nil;
//    } // if
//
//    if(mpButtons)
//    {
//        [mpButtons release];
//
//        mpButtons = nil;
//    } // if
//
//    if(mpMeters)
//    {
//        [mpMeters release];
//
//        mpMeters = nil;
//    } // if
//
//    if(mpVisualizer != nullptr)
//    {
//        delete mpVisualizer;
//
//        mpVisualizer = nullptr;
//    } // if
//
//    if(mpMediator != nullptr)
//    {
//        delete mpMediator;
//
//        mpMediator = nullptr;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
//- (BOOL) acquire
//{
    func acquire() {
//    [self _swapInterval:YES];
        self._swapInterval(true)
//
//    return [self _newVisualizer];
        self._newVisualizer()
//} // acquire
    }
//
//- (void) draw
//{
    func draw() {
//    mpMediator->update();
        mpMediator?.update()
//
//    glClearColor(_clearColor, _clearColor, _clearColor, 1.0f);
        glClearColor(_clearColor, _clearColor, _clearColor, 1.0)
//
//    if(_clearColor > 0.0f)
//    {
        if _clearColor > 0.0 {
//        _clearColor -= 0.05f;
            _clearColor -= 0.05
//    } // if
        }
//
//    glClear(GL_COLOR_BUFFER_BIT);
        glClear(GL_COLOR_BUFFER_BIT.ui)
//
//    if(!mpMediator->hasPosition())
//    {
        if !(mpMediator?.hasPosition ?? false) {
//        if(mbIsWaiting)
//        {
            if mbIsWaiting {
//            CGLFlushDrawable(CGLGetCurrentContext());
                CGLFlushDrawable(CGLGetCurrentContext())
//        } // if
            }
//    } // if
//    else
//    {
        } else {
//        mbIsWaiting = NO;
            mbIsWaiting = false
//
//        glClear(GL_COLOR_BUFFER_BIT);
            glClear(GL_COLOR_BUFFER_BIT.ui)
//
//        [self _drawScene];
            self._drawScene()
//
//        CGLFlushDrawable(CGLGetCurrentContext());
            CGLFlushDrawable(CGLGetCurrentContext())
//    } // else
        }
//
//    glFinish();
        glFinish()
//} // draw
    }
//
//- (void) resize:(NSRect)frame
//{
    func resize(frame: NSRect) {
//    if((frame.size.width >= NBody::Window::kWidth) &&  (frame.size.height >= NBody::Window::kHeight))
//    {
        if frame.size.width >= NBody.Window.kWidth.g && frame.size.height >= NBody.Window.kHeight.g {
//        const GLint nWidowWidth  = GLint(frame.size.width  + 0.5f);
            let nWidowWidth  = Int(frame.size.width  + 0.5)
//        const GLint nWidowHeight = GLint(frame.size.height + 0.5f);
            let nWidowHeight = Int(frame.size.height + 0.5)
//
//        _isResized = (nWidowWidth != mnWidowWidth) || (nWidowHeight != mnWidowHeight);
            resized = (nWidowWidth != mnWidowWidth) || (nWidowHeight != mnWidowHeight)
//
//        mnWidowWidth  = nWidowWidth;
            mnWidowWidth  = nWidowWidth
//        mnWidowHeight = nWidowHeight;
            mnWidowHeight = nWidowHeight
//
//        _size = frame.size;
            size = frame.size
//
//        if(mpVisualizer != nullptr)
//        {
            if let mpVisualizer = mpVisualizer {
//            mpVisualizer->setFrame(_size);
                mpVisualizer.setFrame(size)
//        } // if
            }
//
//        [self _resizeButtons];
            self._resizeButtons()
//        [self _resizeMeters];
            self._resizeMeters()
//    } // if
        }
//} // resize
    }
//
//- (void) move:(CGPoint)point
//{
    func move(point: CGPoint) {
//    if(mbIsRotating)
//    {
        if mbIsRotating {
//        m_Rotation.x += (point.x - m_MousePt.x) * 0.2f;
            m_Rotation.x += (point.x - m_MousePt.x) * 0.2
//        m_Rotation.y += (point.y - m_MousePt.y) * 0.2f;
            m_Rotation.y += (point.y - m_MousePt.y) * 0.2
//
//        mpVisualizer->setRotation(m_Rotation);
            mpVisualizer?.setRotation(m_Rotation)
//
//        m_MousePt.x = point.x;
            m_MousePt.x = point.x
//        m_MousePt.y = point.y;
            m_MousePt.y = point.y
//    } // if
        }
//} // move
    }
//
//- (void) click:(GLint)state
//         point:(CGPoint)point
//{
    func click(state: Int, point: CGPoint) {
//    CGPoint pos  = NSMakePoint(point.x, _size.height - point.y);
        let pos  = NSMakePoint(point.x, size.height - point.y)
//    CGFloat wmax = 0.75f * _size.width;
        let wmax = 0.75 * size.width
//    CGFloat wmin = 0.5f * NBody::Button::kWidth;
        let wmin = 0.5 * NBody.Button.kWidth.g
//
//    if (    (state == NBody::Mouse::Button::kDown)
        if state == NBody.Mouse.Button.kDown
//        &&  (pos.y <= (2.0f * NBody::Button::kHeight))
            && pos.y <= (2.0 * NBody.Button.kHeight.g)
//        &&  (pos.x >= (wmax - wmin))
            && pos.x >= (wmax - wmin)
//        &&  (pos.x <= (wmax + wmin)))
            && pos.x <= (wmax + wmin)
//    {
        {
//        [self _swapSimulators];
            self._swapSimulators()
//    } // if
        }
//} // click
    }
//
//- (void) scroll:(GLfloat)delta
//{
    func scroll(delta: GLfloat) {
//    mpVisualizer->setViewDistance(delta);
        mpVisualizer?.setViewDistance(delta)
//} // scroll
    }
//
    var activeDemo: Int {
        get {return _activeDemo}
//- (void) setActiveDemo:(GLuint)activeDemo
//{
        set {
//    [self _setDemo:activeDemo];
            self._setDemo(newValue)
//} // setActiveDemo
        }
    }
//
    var clearColor: GLfloat {
        get {return _clearColor}
//- (void) setClearColor:(GLfloat)clearColor
//{
        set {
//    _clearColor = clearColor;
            _clearColor = clearColor
//
//    _preferences.clearColor = _clearColor;
            preferences?.clearColor = _clearColor
//} // setClearColor
        }
    }
//
//- (void) setCommand:(unichar)command
//{
    private func willSetCommand(command: unichar) {
//    switch(command)
//    {
        switch command {
//        case '0':
        case "0", "1", "2", "3", "4", "5", "6":
//        case '1':
//        case '2':
//        case '3':
//        case '4':
//        case '5':
//        case '6':
//        {
//            // N-Body demo types
//            [self _selectDemo:command];
            self._selectDemo(command)
//
//            break;
//        }
//
//        case 'a':
//        {
        case "a":
//            [self _showMeters:YES];
            self._showMeters(true)
//
//            break;
//        }
//
//        case 'c':
        case "c":
//        {
//            [self _toggleMeter:NBody::eNBodyMeterCPU];
            self._toggleMeter(NBody.MeterType.CPU)
//
//            break;
//        }
//
//        case 'd':
//        {
        case "d":
//            [mpButtons toggle];
            mpButtons?.toggle()
//
//            _preferences.showDock = mpButtons.isVisible;
            preferences?.showDock = mpButtons?.visible ?? false
//
//            break;
//        }
//
//        case 'e':
//        {
        case "e":
//            mpVisualizer->toggleEarthView();
            mpVisualizer?.toggleEarthView()
//
//            break;
//        }
//
//        case 'f':
//        {
        case "f":
//            [self _toggleMeter:NBody::eNBodyMeterFrames];
            self._toggleMeter(.Frames)
//
//            break;
//        }
//
//        case 'g':
//        {
        case "g":
//            [self _swapVisualizer];
            self._swapVisualizer()
//
//            break;
//        }
//
//        case 'h':
//        {
        case "h":
//            [self _showMeters:NO];
            self._showMeters(false)
//
//            break;
//        }
//
//        case 'n':
//        {
        case "n":
//            [self _nextDemo];
            self._nextDemo()
//
//            break;
//        }
//
//        case 'p':
//        {
        case "p":
//            [self _toggleMeter:NBody::eNBodyMeterPerf];
            self._toggleMeter(.Perf)
//
//            break;
//        }
//
//        case 'r':
//        {
        case "r":
//            mpVisualizer->toggleRotation();
            mpVisualizer?.toggleRotation()
//
//            break;
//        }
//
//        case 'R':
//        {
        case "R":
//            [self _restart];
            self._restart()
//
//            break;
//        }
//
//        case 's':
//        {
        case "s":
//            [self _swapSimulators];
            self._swapSimulators()
//
//            break;
//        }
//
//        case 'u':
//        {
        case "u":
//            [self _toggleMeter:NBody::eNBodyMeterUpdates];
            self._toggleMeter(.Updates)
//
//            break;
//        }
//
//        case 'z':
//        {
        case "z":
//            [self _reset];
            self._reset()
//
//            break;
//        }
//
//        default:
        default:
//            break;
            break
//    } // switch
        }
//
//    _command = command;
//} // setCommand
    }
//
//- (void) setFrame:(NSRect)frame
//{
    private func willSetFrame(newValue: NSRect) {
//    [self resize:frame];
        self.resize(newValue)
//} // setFrame
    }
//
//- (void) setViewDistance:(GLfloat)viewDistance
//{
    private func didSetViewDistance(viewDistance: GLfloat) {
//    _viewDistance = viewDistance;
//
//    _preferences.viewDistance = _viewDistance;
        preferences?.viewDistance = viewDistance
//} // setViewDistance
    }
//
//@end
}
