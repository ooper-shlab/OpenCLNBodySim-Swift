//
//  OpenGLView.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
<codex>
<abstract>
OpenGL view class with idle timer and fullscreen mode support.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

//MARK: -

private let kOpenGLAttribsLegacyProfile: [NSOpenGLPixelFormatAttribute] =
[
    NSOpenGLPFADoubleBuffer.ui,
    NSOpenGLPFAAccelerated.ui,
    NSOpenGLPFAAcceleratedCompute.ui,
    NSOpenGLPFAAllowOfflineRenderers.ui,   // NOTE: Needed to connect to compute-only gpus
    NSOpenGLPFADepthSize.ui, 24,
    0
]

let  kOpenGLAttribsLegacyDefault: [NSOpenGLPixelFormatAttribute] =
[
    NSOpenGLPFADoubleBuffer.ui,
    NSOpenGLPFADepthSize.ui, 24,
    0
]

@objc(OpenGLView)
class OpenGLView: NSOpenGLView {
    //    private var mnInitDemo: Int = 0
    //    private var mnStarScale: GLfloat = 0
    
    private var mbFullscreen: Bool = false
    
    private var mpOptions: [String: AnyObject] = [:]
    private var mpContext: NSOpenGLContext?
    private var mpTimer: Timer?
    
    private var mpEngine: NBodyEngine?
    private var mpPrefs: NBodyPreferences?
    
    @IBOutlet var mpHUD: NSPanel?
    
    //MARK: -
    //MARK: Private - Destructor
    
    private func _cleanupOptions() {
        mpOptions.removeAll()
    }
    
    private func _cleanupTimer() {
        if mpTimer != nil {
            mpTimer!.invalidate()
        }
    }
    
    private func _cleanUpPrefs() {
        if mpPrefs != nil {
            mpPrefs!.addEntries(mpEngine?.preferences)
            
            mpPrefs!.write()
            
            mpPrefs = nil;
        }
    }
    
    private func _cleanupEngine() {
        if mpEngine != nil {
            
            mpEngine = nil
        }
    }
    
    private func _cleanUpObserver() {
        // If self isn't removed as an observer, the Notification Center
        // will continue sending notification objects to the deallocated
        // object.
        NotificationCenter.default.removeObserver(self)
    }
    
    // Tear-down objects
    private func _cleanup() {
        self._cleanupOptions()
        self._cleanUpPrefs()
        self._cleanupTimer()
        self._cleanupEngine()
        self._cleanUpObserver()
    }
    
    //MARK: -
    //MARK: Private - Utilities - Misc.
    
    // When application is terminating cleanup the objects
    @objc private func _quit(_ notification: Notification) {
        self._cleanup()
    }
    
    @objc private func _idle() {
        self.needsDisplay = true
    }
    
    private func _toggleFullscreen() {
        if mpPrefs?.fullscreen ?? false {
            self.enterFullScreenMode(NSScreen.main()!, withOptions: mpOptions)
        }
    }
    
    private func _alert(_ pMessage: String?) {
        if pMessage != nil {
            let pAlert = NSAlert()
            
            pAlert.addButton(withTitle: "OK")
            pAlert.messageText = pMessage!
            pAlert.alertStyle = .critical
            
            let response = pAlert.runModal()
            
            if response == NSAlertFirstButtonReturn {
                NSLog(">> MESSAGE: %@", pMessage!)
            }
            
        }
    }
    
    private func _query() -> Bool {
        let query = GLU.Query.create()
        
        // NOTE: For OpenCL 1.2 support refer to <http://support.apple.com/kb/HT5942>
        let keys: GLstrings = [
            "120",   "130",  "285",  "320M",
            "330M", "X1800", "2400",  "2600",
            "3000",  "4670", "4800",  "4870",
            "5600",  "8600", "8800", "9600M"
        ]
        
        Swift.print(">> N-body Simulation: Renderer = \"\(query.renderer)\"")
        Swift.print(">> N-body Simulation: Vendor   = \"\(query.vendor)\"")
        Swift.print(">> N-body Simulation: Version  = \"\(query.version)\"")
        
        return query.match(keys)
    }
    
    //- (NSOpenGLPixelFormat *) _newPixelFormat
    //{
    private static func _newPixelFormat() -> NSOpenGLPixelFormat? {
        //    NSOpenGLPixelFormat* pFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:kOpenGLAttribsLegacyProfile];
        var pFormat = NSOpenGLPixelFormat(attributes: kOpenGLAttribsLegacyProfile)
        //
        //    if(!pFormat)
        //    {
        if pFormat == nil {
            //        NSLog(@">> WARNING: Failed to initialize an OpenGL context with the desired pixel format!");
            NSLog(">> WARNING: Failed to initialize an OpenGL context with the desired pixel format!")
            //        NSLog(@">> MESSAGE: Attempting to initialize with a fallback pixel format!");
            NSLog(">> MESSAGE: Attempting to initialize with a fallback pixel format!")
            //
            //        pFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:kOpenGLAttribsLegacyDefault];
            pFormat = NSOpenGLPixelFormat(attributes: kOpenGLAttribsLegacyDefault)
            //    } // if
        }
        //
        //    return pFormat;
        return pFormat
        //} // _newPixelFormat
    }
    
    //MARK: -
    //MARK: Private - Utilities - Prepare
    
    private func _preparePrefs() {
        mpPrefs = NBodyPreferences()
        
        if mpPrefs != nil {
            mbFullscreen = mpPrefs!.fullscreen
        }
    }
    
    private func _prepareNBody() {
        if !self._query() {
            self._alert("Requires OpenCL 1.2!")
            
            self._cleanupOptions()
            self._cleanupTimer()
            
            exit(-1)
        } else {
            let frame = NSScreen.main()!.frame
            
            mpEngine = NBodyEngine(preferences: mpPrefs)
            
            mpEngine!.frame = frame
            
            mpEngine!.acquire()
        }
    }
    
    private func _prepareRunLoop() {
        mpTimer = Timer(timeInterval: 0.0,
            target: self,
            selector: #selector(OpenGLView._idle),
            userInfo: self,
            repeats: true)
        
        RunLoop.current.add(mpTimer!,
            forMode: RunLoopMode.commonModes)
    }
    
    //MARK: -
    //MARK: Public - Designated Initializer
    
    override init(frame frameRect: NSRect) {
        var bIsValid = false
        
        if let pFormat = OpenGLView._newPixelFormat() {
            super.init(frame: frameRect, pixelFormat: pFormat)!
            
            mpContext = self.openGLContext
            bIsValid = mpContext != nil
            
            mpOptions = [NSFullScreenModeSetting: true as AnyObject]
            
            // It's important to clean up our rendering objects before we terminate -- Cocoa will
            // not specifically release everything on application termination, so we explicitly
            // call our cleanup (private object destructor) routines.
            NotificationCenter.default.addObserver(self,
                selector: #selector(OpenGLView._quit(_:)),
                name: NSNotification.Name(rawValue: "NSApplicationWillTerminateNotification"),
                object: NSApp)
            
        } else{
            fatalError(">> ERROR: Failed to acquire a valid pixel format!")
        }
        
        if !bIsValid {
            exit(-1)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    deinit {
        
        self._cleanup()
    }
    
    //MARK: -
    //MARK: Public - Prepare
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        
        self._preparePrefs()
        self._prepareNBody()
        self._prepareRunLoop()
        
        self._toggleFullscreen()
    }
    
    //MARK: -
    //MARK: Public - Delegates
    
    override var isOpaque: Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
    
    //MARK: -
    //MARK: Public - Updates
    
    //### deprecation message says this is useless.
    //    override func renewGState() {
    //        super.renewGState()
    //
    //        self.window?.disableScreenUpdatesUntilFlush()
    //    }
    
    //MARK: -
    //MARK: Public - Display
    
    func _resize() {
        if let mpEngine = mpEngine {
            let bounds = self.bounds
            
            mpEngine.resize(bounds)
        }
    }
    
    override func reshape() {
        self._resize()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        mpEngine?.draw()
    }
    
    //MARK: -
    //MARK: Public - Fullscreen
    
    @IBAction func toggleHelp(_ sender: AnyObject) {
        if mpHUD?.isVisible ?? false {
            mpHUD!.orderOut(sender)
        } else {
            mpHUD?.makeKeyAndOrderFront(sender)
        }
    }
    
    @IBAction func toggleFullscreen(_: AnyObject) {
        if self.isInFullScreenMode {
            self.exitFullScreenMode(options: mpOptions)
            
            self.window?.makeFirstResponder(self)
            
            mpPrefs?.fullscreen = false
        } else {
            self.enterFullScreenMode(NSScreen.main()!, withOptions: mpOptions)
            
            mpPrefs?.fullscreen = true
        }
    }
    
    //MARK: -
    //MARK: Public - Keys
    
    override func keyDown(with event: NSEvent) {
        if let pChars = event.characters, !pChars.isEmpty {
            let key = pChars.utf16[pChars.utf16.startIndex]
            
            if key == 27 {
                self.toggleFullscreen(self)
            } else {
                mpEngine?.command = key
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let loc = event.locationInWindow
        let bounds = self.bounds
        let point = NSMakePoint(loc.x, bounds.size.height - loc.y)
        
        mpEngine?.click(NBody.Mouse.Button.kDown, point: point)
    }
    
    override func mouseUp(with event: NSEvent) {
        let loc = event.locationInWindow
        let bounds = self.bounds
        let point = NSMakePoint(loc.x, bounds.size.height - loc.y)
        
        mpEngine?.click(NBody.Mouse.Button.kUp, point: point)
    }
    
    override func mouseDragged(with event: NSEvent) {
        var loc = event.locationInWindow
        
        loc.y = 1080.0 - loc.y
        
        mpEngine?.move(loc)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let dy = event.deltaY
        
        mpEngine?.scroll(dy.f)
    }
    
}
