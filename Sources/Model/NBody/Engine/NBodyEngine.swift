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

import Cocoa
import OpenGL.GL

let kMeterDefaultMaxFPS: size_t      = 120;
let kMeterDefaultMaxUpdates :size_t  = 120;
let kMeterDefaultMaxPerf: size_t     = 1400;
let kMeterDefaultMaxCPUUsage: size_t = 100;

@objc(NBodyEngine)
class NBodyEngine: NSObject {
    
    private(set) var preferences: NBodyPreferences?
    
    private(set) var resized: Bool = false
    private(set) var size: NSSize = NSSize()
    
    private var _activeDemo: Int = 0
    private var _clearColor: GLfloat = 0
    var viewDistance: GLfloat = 0 {
        didSet{didSetViewDistance(oldValue)}
    }
    
    
    private var _command: unichar = 0
    
    private var _frame: NSRect = NSRect()
    
    // Instance Variables
    private var mbIsWaiting: Bool = false
    private var mbIsRotating: Bool = false
    
    private var mnSimulatorIndex: Int = 0
    private var mnSimulatorCount: Int = 0
    
    private var mnStarScale: GLfloat = 0.0
    
    private var mnWidowWidth: Int = 0
    private var mnWidowHeight: Int = 0
    
    private var m_MousePt: NSPoint = NSPoint()
    private var m_Rotation: NSPoint = NSPoint()
    
    private var m_Properties: NBody.Simulation.Properties?
    
    private var mpMeters: NBodyMeters?
    private var mpButtons: NBodyButtons?
    
    private var mpMediator: NBody.Simulation.Mediator?
    private var mpVisualizer: NBody.Simulation.Visualizer?
    
    //MARK: -
    //MARK: Private - Utiltites - Scene
    
    private func _reset() {
        mpVisualizer?.stopRotation()
        mpVisualizer?.setRotationSpeed(0.0)
        
        mpMediator?.reset()
        mpVisualizer?.reset(activeDemo)
    }
    
    private func _restart() {
        mpVisualizer?.setViewRotation(m_Rotation)
        mpVisualizer?.setViewZoom(viewDistance)
        mpVisualizer?.setViewTime(0.0)
        mpVisualizer?.setIsResetting(true)
        mpVisualizer?.stopRotation()
    }
    
    private func _nextSimulator() {
        mbIsWaiting = true
        
        mnSimulatorIndex++
        
        if mnSimulatorIndex >= mnSimulatorCount {
            mnSimulatorIndex = 0
        }
        
        mpMediator?.pause()
        mpMediator?.select(mnSimulatorIndex)
        mpMediator?.reset()
        
        mpButtons?.index      = mnSimulatorIndex
        mpButtons?.size       = size
        mpButtons?.selected = true
    }
    
    private func _nextDemo() {
        _activeDemo = (_activeDemo + 1) % (m_Properties?.mnDemos ?? 1)
        
        self._reset()
        
        preferences?.demoType = _activeDemo
    }
    
    private func _swapVisualizer() {
        self.draw()
        
        mbIsWaiting = true
        
        mpVisualizer?.reset(_activeDemo)
    }
    
    private func _swapSimulators() {
        self.draw()
        
        self._nextSimulator()
        
        mpVisualizer?.reset(_activeDemo)
        
        // Reset the target values of meters
        mpMeters?.reset()
    }
    
    private func _swapInterval(doSync: Bool) {
        let pContext = CGLGetCurrentContext()
        
        var sync: GLint = doSync ? 1 : 0
        
        CGLSetParameter(pContext,
            kCGLCPSwapInterval,
            &sync)
    }
    
    private func _drawScene() {
        // Render stars
        let pPosition = mpMediator?.position ?? nil
        
        mpVisualizer?.draw(pPosition)
        
        // Update and render the performance meters
        mpMeters?.index = NBody.MeterType.Frames
        mpMeters?.point = NSMakePoint(208.0, 160.0)
        
        mpMeters?.update()
        mpMeters?.draw()
        
        mpMeters?.index = NBody.MeterType.CPU
        mpMeters?.point = NSMakePoint(208.0 + 0.25 * size.width, 160.0)
        
        mpMeters?.update()
        mpMeters?.draw()
        
        mpMeters?.index = NBody.MeterType.Updates
        mpMeters?.point = NSMakePoint(0.75 * size.width - 208.0, 160.0)
        mpMeters?.value = mpMediator?.updates ?? 0.0
        
        mpMeters?.update()
        mpMeters?.draw()
        
        mpMeters?.index = NBody.MeterType.Perf
        mpMeters?.point = NSMakePoint(size.width - 208.0, 160.0)
        mpMeters?.value = mpMediator?.performance ?? 0.0
        
        mpMeters?.update()
        mpMeters?.draw()
        
        // Draw the button(s) in the dock
        mpButtons?.draw()
    }
    
    private func _setDemo(newValue: Int) {
        _activeDemo = newValue
        
        self._reset()
        
        preferences?.demoType = _activeDemo
    }
    
    private func _selectDemo(command: unichar) {
        if command != _command {
            let demo = Int(command - "0")
            
            if demo < (m_Properties?.mnDemos ?? 1) {
                self._setDemo(demo)
            }
            
            _command = command
        }
    }
    
    //MARK: -
    //MARK: Private - Utiltites - Constructors
    
    private func _newSimulators() -> Bool {
        mpMediator = NBody.Simulation.Mediator(m_Properties!)
        
        mnSimulatorIndex = 0
        mnSimulatorCount = mpMediator!.count
        
        mpMediator!.reset()
        mpVisualizer?.reset(_activeDemo)
        
        return mnSimulatorCount > 0
    }
    
    func _newVisualizer() -> Bool {
        var bSuccess = false
        
        mpVisualizer = NBody.Simulation.Visualizer(m_Properties)
        
        bSuccess = mpVisualizer!.valid
        
        if bSuccess {
            mpVisualizer!.setFrame(size)
            mpVisualizer!.setStarScale(mnStarScale)
            mpVisualizer!.setStarSize(NBody.Star.kSize.f)
            mpVisualizer!.setRotationChange(NBody.Defaults.kRotationDelta.f)
            
            bSuccess = self._newSimulators()
            bSuccess = bSuccess && self._newMeters(NBody.Defaults.kMeterSize)
            bSuccess = bSuccess && self._newDock(mpMediator?.count ?? 0)
        }
        
        return bSuccess
    }
    
    private func _newDock(count: Int) -> Bool {
        mpButtons = NBodyButtons(count: count)
        
        for i in 0..<count {
            mpButtons!.index = i
            mpButtons?.label = mpMediator?.label(NBody.Simulation.Types(rawValue: i)!) ?? ""
            mpButtons!.size  = size
            
            if !mpButtons!.acquire() {
                return false
            }
        }
        
        mpButtons!.index = 0
        
        return true
        
    }
    
    private func _newMeterFrames(length: Int) -> Bool {
        mpMeters?.index     = .Frames
        mpMeters?.visible = preferences?.showFramerate ?? false
        mpMeters?.max       = preferences?.maxFramerate ?? kMeterDefaultMaxFPS
        mpMeters?.bound     = length
        mpMeters?.label     = "Frames/sec"
        mpMeters?.useTimer  = true
        mpMeters?.frame     = size
        
        return mpMeters?.acquire() ?? false
    }
    
    private func _newMeterUpdates(length: Int) -> Bool {
        mpMeters?.index     = .Updates
        mpMeters?.visible = preferences?.showUpdates ?? false
        mpMeters?.max       = preferences?.maxUpdates ?? kMeterDefaultMaxUpdates
        mpMeters?.bound     = length
        mpMeters?.label     = "Updates/sec"
        mpMeters?.frame     = size
        
        return mpMeters?.acquire() ?? false
    }
    
    private func _newMeterPerf(length: Int) -> Bool {
        mpMeters?.index     = .Perf
        mpMeters?.visible = preferences?.showPerf ?? true
        mpMeters?.max       = preferences?.maxPerf ?? kMeterDefaultMaxPerf
        mpMeters?.bound     = length
        mpMeters?.label     = "Relative Perf"
        mpMeters?.frame     = size
        
        return mpMeters?.acquire() ?? false
    }
    
    private func _newMeterCPU(length: Int) -> Bool {
        mpMeters?.index       = .CPU
        mpMeters?.visible   = preferences?.showCPU ?? true
        mpMeters?.max         = preferences?.maxCPU ?? kMeterDefaultMaxCPUUsage
        mpMeters?.bound       = length
        mpMeters?.label       = "% CPU Usage"
        mpMeters?.useHostInfo = true
        mpMeters?.frame       = size
        
        return mpMeters?.acquire() ?? false
    }
    
    private func _newMeters(length: Int) -> Bool {
        var bSuccess = false
        
        mpMeters = NBodyMeters(count: 4)
        
        if mpMeters != nil {
            bSuccess = self._newMeterFrames(length)
                && self._newMeterUpdates(length)
                && self._newMeterPerf(length)
                && self._newMeterCPU(length)
        }
        
        return bSuccess
    }
    
    private func _newPreferences(preferences: NBodyPreferences?) -> Bool {
        if preferences != nil {
            self.preferences = preferences
        } else {
            self.preferences = NBodyPreferences()
        }
        
        return preferences != nil
    }
    
    //MARK: -
    //MARK: Private - Utiltites - UI
    
    private func _resizeButtons() {
        if let mpButtons = mpButtons {
            mpButtons.index      = mnSimulatorIndex
            mpButtons.size       = size
            mpButtons.selected = true
        }
    }
    
    private func _resizeMeters() {
        if let mpMeters = mpMeters {
            mpMeters.resize(size)
        }
    }
    
    private func _toggleMeter(index: NBody.MeterType) {
        mpMeters?.index = index
        
        mpMeters?.toggle()
        
        switch index {
        case .Perf:
            preferences?.showPerf = mpMeters?.visible ?? false
            
        case .Updates:
            preferences?.showUpdates = mpMeters?.visible ?? false
            
        case .CPU:
            preferences?.showCPU = mpMeters?.visible ?? false
            
        case .Frames:
            preferences?.showFramerate = mpMeters?.visible ?? false
        }
    }
    
    private func _showMeters(doShow: Bool) {
        mpMeters?.show(doShow)
        
        preferences?.showPerf      = doShow
        preferences?.showUpdates   = doShow
        preferences?.showFramerate = doShow
        preferences?.showCPU       = doShow
    }
    
    private func _setDefaults() {
        resized = false
        _command = 0
        _frame     = NSMakeRect(0.0, 0.0, 0.0, 0.0)
        
        mbIsWaiting      = true
        mbIsRotating     = true
        mnSimulatorIndex = 0
        mnSimulatorCount = 0
        mnWidowWidth     = Int(size.width)
        mnWidowHeight    = Int(size.height)
        m_MousePt        = NSMakePoint(0.0, 0.0)
        mpMediator       = nil
        mpVisualizer     = nil
        mpButtons        = nil
        mpMeters         = nil
    }
    
    private func _setPreferences(preferences: NBodyPreferences?) {
        if self._newPreferences(preferences) {
            m_Properties <<- self.preferences
            
            activeDemo   = self.preferences!.demoType
            clearColor   = self.preferences!.clearColor
            viewDistance = self.preferences!.viewDistance
            size         = self.preferences!.size
            
            mnStarScale = self.preferences!.starScale
            m_Rotation  = self.preferences!.rotate
        } else {
            activeDemo   = 1
            clearColor   = 1.0
            viewDistance = 30.0
            size         = NSMakeSize(NBody.Window.kWidth.g, NBody.Window.kHeight.g)
            
            mnStarScale = 1.0
            m_Rotation  = NSMakePoint(0.0, 0.0)
        }
    }
    
    private func _setEnginePreferences(preferences: NBodyPreferences?) {
        self._setPreferences(preferences)
        self._setDefaults()
    }
    
    //MARK: -
    //MARK: Public
    
    override init() {
        super.init()
        
        self._setEnginePreferences(nil)
        
    }
    
    init(preferences: NBodyPreferences?) {
        super.init()
        
        self._setEnginePreferences(preferences)
        
    }
    
    //+ (instancetype) engine
    //{
    //    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:nil] autorelease];
    //} // engine
    //
    //+ (instancetype) engineWithPreferences:(NBodyPreferences *)preferences
    //{
    //    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:preferences] autorelease];
    //} // engineWithPreferences
    
    
    func acquire() -> Bool {
        self._swapInterval(true)
        
        return self._newVisualizer()
    }
    
    func draw() {
        mpMediator?.update()
        
        glClearColor(_clearColor, _clearColor, _clearColor, 1.0)
        
        if _clearColor > 0.0 {
            _clearColor -= 0.05
        }
        
        glClear(GL_COLOR_BUFFER_BIT.ui)
        
        if !(mpMediator?.hasPosition ?? false) {
            if mbIsWaiting {
                CGLFlushDrawable(CGLGetCurrentContext())
            }
        } else {
            mbIsWaiting = false
            
            glClear(GL_COLOR_BUFFER_BIT.ui)
            
            self._drawScene()
            
            CGLFlushDrawable(CGLGetCurrentContext())
        }
        
        glFinish()
    }
    
    func resize(frame: NSRect) {
        if frame.size.width >= NBody.Window.kWidth.g && frame.size.height >= NBody.Window.kHeight.g {
            let nWidowWidth  = Int(frame.size.width  + 0.5)
            let nWidowHeight = Int(frame.size.height + 0.5)
            
            resized = (nWidowWidth != mnWidowWidth) || (nWidowHeight != mnWidowHeight)
            
            mnWidowWidth  = nWidowWidth
            mnWidowHeight = nWidowHeight
            
            size = frame.size
            
            if let mpVisualizer = mpVisualizer {
                mpVisualizer.setFrame(size)
            }
            
            self._resizeButtons()
            self._resizeMeters()
        }
    }
    
    func move(point: CGPoint) {
        if mbIsRotating {
            m_Rotation.x += (point.x - m_MousePt.x) * 0.2
            m_Rotation.y += (point.y - m_MousePt.y) * 0.2
            
            mpVisualizer?.setRotation(m_Rotation)
            
            m_MousePt.x = point.x
            m_MousePt.y = point.y
        }
    }
    
    func click(state: Int, point: CGPoint) {
        let pos  = NSMakePoint(point.x, size.height - point.y)
        let wmax = 0.75 * size.width
        let wmin = 0.5 * NBody.Button.kWidth.g
        
        if state == NBody.Mouse.Button.kDown
            && pos.y <= (2.0 * NBody.Button.kHeight.g)
            && pos.x >= (wmax - wmin)
            && pos.x <= (wmax + wmin)
        {
            self._swapSimulators()
        }
    }
    
    func scroll(delta: GLfloat) {
        mpVisualizer?.setViewDistance(delta)
    }
    
    var activeDemo: Int {
        get {return _activeDemo}
        set {
            self._setDemo(newValue)
        }
    }
    
    var clearColor: GLfloat {
        get {return _clearColor}
        set {
            _clearColor = clearColor
            
            preferences?.clearColor = _clearColor
        }
    }
    
    var command: unichar {
        get {return _command}
        set {
            switch newValue {
            case "0", "1", "2", "3", "4", "5", "6":
                // N-Body demo types
                self._selectDemo(newValue)
                
            case "a":
                self._showMeters(true)
                
            case "c":
                self._toggleMeter(NBody.MeterType.CPU)
                
            case "d":
                mpButtons?.toggle()
                
                preferences?.showDock = mpButtons?.visible ?? false
                
            case "e":
                mpVisualizer?.toggleEarthView()
                
            case "f":
                self._toggleMeter(.Frames)
                
            case "g":
                self._swapVisualizer()
                
            case "h":
                self._showMeters(false)
                
            case "n":
                self._nextDemo()
                
            case "p":
                self._toggleMeter(.Perf)
                
            case "r":
                mpVisualizer?.toggleRotation()
                
            case "R":
                self._restart()
                
            case "s":
                self._swapSimulators()
                
            case "u":
                self._toggleMeter(.Updates)
                
            case "z":
                self._reset()
                
            default:
                break
            }
            
            _command = newValue
        }
    }
    
    var frame: NSRect {
        get {return _frame}
        set {
            self.resize(newValue)
        }
    }
    
    private func didSetViewDistance(viewDistance: GLfloat) {
        
        preferences?.viewDistance = viewDistance
    }
    
}
