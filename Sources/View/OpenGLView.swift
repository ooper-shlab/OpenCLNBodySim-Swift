//
//  OpenGLView.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
     File: OpenGLView.h
     File: OpenGLView.mm
 Abstract:
 OpenGL view class with idle timer and fullscreen mode support.

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

@objc(OpenGLView)
class OpenGLView: NSOpenGLView {
    private var mnInitDemo: Int = 0
    private var mnStarScale: GLfloat = 0
    
    private var mbFullscreen: Bool = false
    
    private var mbShowHUD: Bool = false
    private var mbShowDock: Bool = false
    private var mbShowUpdatesMeter: Bool = false
    private var mbShowFramesMeter: Bool = false
    private var mbShowPerfMeter: Bool = false
    
    private var mpOptions: NSDictionary!
    private var mpContext: NSOpenGLContext!
    private var mpTimer: NSTimer!
    
    private var mpEngine: NBody.Engine!
    
    @IBOutlet var mpHUD: NSPanel!
    
    //MARK: -
    //MARK: Private - Destructor
    
    private func cleanupOptions() {
    }
    
    private func cleanupTimer() {
        if mpTimer != nil {
            mpTimer.invalidate()
        }
    }
    
    private func cleanupEngine() {
        if mpEngine != nil {
            
            mpEngine = nil
        }
    }
    
    // Tear-down objects
    private func cleanup() {
        self.cleanupOptions()
        self.cleanupTimer()
        self.cleanupEngine()
    }
    
    //MARK: -
    //MARK: Private - Preferences
    
    private func alert(pMessage: String?) {
        if pMessage != nil {
            let pAlert = NSAlert()
            
            pAlert.addButtonWithTitle("OK")
            pAlert.messageText = pMessage
            pAlert.alertStyle = .CriticalAlertStyle
            
            let response = pAlert.runModal()
            
            if response == NSAlertFirstButtonReturn {
                NSLog(">> MESSAGE: %@", pMessage!)
            }
            
        }
    }
    
    private func query() -> Bool {
        let query = GLU.Query.create()
        
        // NOTE: For OpenCL 1.2 support refer to <http://support.apple.com/kb/HT5942>
        let keys: GLstrings = [
            "120",   "130",  "285",  "320M",
            "330M", "X1800", "2400",  "2600",
            "3000",  "4670", "4800",  "4870",
            "5600",  "8600", "8800", "9600M"
        ]
        
        println(">> N-body Simulation: Renderer = \"\(query.renderer)\"")
        println(">> N-body Simulation: Vendor   = \"\(query.vendor)\"")
        println(">> N-body Simulation: Version  = \"\(query.version)\"")
        
        return query.match(keys)
    }
    
    private func savePrefs(pBundleID: String?) {
        if pBundleID != nil {
            let pPrefs: NSDictionary = [
                "fullscreen": mbFullscreen,
                "initDemo": Int(mnInitDemo),
                "starScale": mnStarScale,
                "showHUD": mbShowHUD,
                "showUpdates": mbShowUpdatesMeter,
                "showFramerate": mbShowFramesMeter,
                "showPref": mbShowPerfMeter,
                "showDock": mbShowDock,
            ]
            
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(pBundleID!)
            
            NSUserDefaults.standardUserDefaults().setPersistentDomain(pPrefs, forName: pBundleID!)
            
        }
    }
    
    //MARK: -
    //MARK: Private - Prepare
    
    private func preparePrefs() {
        var pBundleID: String? = nil
        
        var pUserDefaults: NSDictionary? = nil
        if NSUserDefaults.standardUserDefaults().respondsToSelector("dictionaryRepresentation") {
            pUserDefaults = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        }
        
        if pUserDefaults == nil {
            pBundleID = NSBundle.mainBundle().bundleIdentifier
            
            if pBundleID != nil {
                pUserDefaults = NSUserDefaults.standardUserDefaults().persistentDomainForName(pBundleID!)
            }
        }
        
        if pUserDefaults != nil {
            
            mbFullscreen = pUserDefaults!["fullscreen"]?.boolValue ?? true
            
            mnInitDemo = pUserDefaults!["initDemo"]?.integerValue ?? 1
            
            mnStarScale = pUserDefaults!["starScale"]?.floatValue ?? 1.0
            
            mbShowHUD = pUserDefaults!["showHUD"]?.boolValue ?? true
            
            mbShowUpdatesMeter = pUserDefaults!["showUpdates"]?.boolValue ?? false
            
            mbShowFramesMeter = pUserDefaults!["showFramerate"]?.boolValue ?? false
            
            mbShowPerfMeter = pUserDefaults!["showPref"]?.boolValue ?? true
            
            mbShowDock = pUserDefaults!["showDock"]?.boolValue ?? true
        }
        
        self.savePrefs(pBundleID)
        
        if mnInitDemo < 0 {
            mnInitDemo = 0
        }
        
        if mnInitDemo > 6 {
            mnInitDemo = 6
        }
    }
    
    private func prepareNBody() {
        if !self.query() {
            self.alert("Requires OpenCL 1.2!")
            
            self.cleanupOptions()
            self.cleanupTimer()
            
            exit(-1)
        } else {
            let frame = NSScreen.mainScreen()!.frame
            
            mpEngine = NBody.Engine(starScale: mnStarScale, activeDemo: mnInitDemo)
            
            mpEngine.setFrame(frame)
            
            mpEngine.finalize()
        }
    }
    
    private func prepareRunLoop() {
        mpTimer = NSTimer(timeInterval: 0.0,
            target: self,
            selector: "idle",
            userInfo: self,
            repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(mpTimer,
            forMode: NSRunLoopCommonModes)
    }
    
    //MARK: -
    //MARK: Private - Quitting
    
    // When application is terminating cleanup the objects
    func quit(NSNotification) {
        self.cleanup()
    }
    
    //MARK: -
    //MARK: Private - Display
    
    func idle() {
        self.needsDisplay = true
    }
    
    //MARK: -
    //MARK: Public - Designated Initializer
    
    override init() {
        super.init()
    }
    
    override init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat!) {
        super.init(frame: frameRect, pixelFormat: format)
    }
    
    override init(frame frameRect: NSRect) {
        var bIsValid = false
        
        let attribs: [NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAcceleratedCompute),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAllowOfflineRenderers),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 24,
            0
        ]
        
        var format = NSOpenGLPixelFormat(attributes: attribs)
        
        if format == nil {
            
            let attribs: [NSOpenGLPixelFormatAttribute] = [
                NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
                NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 24,
                0
            ]
            
            format = NSOpenGLPixelFormat(attributes: attribs)
        }
        
        super.init(frame: frameRect)
        if format != nil {
            self.pixelFormat = format
            
            mpContext = self.openGLContext
            bIsValid = mpContext != nil
            
            mpOptions = [NSFullScreenModeSetting: true]
            
            // It's important to clean up our rendering objects before we terminate -- Cocoa will
            // not specifically release everything on application termination, so we explicitly
            // call our cleanup (private object destructor) routines.
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "quit:",
                name: "NSApplicationWillTerminateNotification",
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
        
        self.cleanup()
    }
    
    //MARK: -
    //MARK: Public - Prepare
    
    override func prepareOpenGL() {
        
        self.preparePrefs()
        self.prepareNBody()
        self.prepareRunLoop()
    }
    
    //MARK: -
    //MARK: Public - Delegates
    
    func isOpaque() -> Bool {
        return true
    }
    
    func acceptsFirstResponder() -> Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(NSApplication) -> Bool {
        return true
    }
    
    //MARK: -
    //MARK: Public - Updates
    
    override func renewGState() {
        super.renewGState()
        
        self.window?.disableScreenUpdatesUntilFlush()
    }
    
    //MARK: -
    //MARK: Public - Display
    
    func resize() {
        if mpEngine != nil {
            let bounds = self.bounds
            
            mpEngine.resize(bounds)
        }
    }
    
    override func reshape() {
        self.resize()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        mpEngine.draw()
    }
    
    //MARK: -
    //MARK: Public - Fullscreen
    
    @IBAction func toggleHelp(sender: AnyObject) {
        if mpHUD.visible {
            mpHUD.orderOut(sender)
        } else {
            mpHUD.makeKeyAndOrderFront(sender)
        }
    }
    
    @IBAction func toggleFullscreen(AnyObject) {
        if self.inFullScreenMode {
            self.exitFullScreenModeWithOptions(mpOptions)
            
            self.window?.makeFirstResponder(self)
        } else {
            self.enterFullScreenMode(NSScreen.mainScreen()!, withOptions: mpOptions)
        }
    }
    
    //MARK: -
    //MARK: Public - Keys
    
    override func keyDown(event: NSEvent) {
        let pChars = event.characters
        
        if (pChars?.utf16Count ?? 0) >  0 {
            let key = event.characters!.utf16[0]
            
            if key == 27 {
                self.toggleFullscreen(self)
            } else {
                mpEngine.run(GLubyte(key))
            }
        }
    }
    
    override func mouseDown(event: NSEvent) {
        let loc = event.locationInWindow
        let bounds = self.bounds
        let point = NSMakePoint(loc.x, bounds.size.height - loc.y)
        
        mpEngine.click(NBody.Mouse.Button.kDown, point: point)
    }
    
    override func mouseUp(event: NSEvent) {
        let loc = event.locationInWindow
        let bounds = self.bounds
        let point = NSMakePoint(loc.x, bounds.size.height - loc.y)
        
        mpEngine.click(NBody.Mouse.Button.kUp, point: point)
    }
    
    override func mouseDragged(event: NSEvent) {
        var loc = event.locationInWindow
        
        loc.y = 1080.0 - loc.y
        
        mpEngine.move(loc)
    }
    
    override func scrollWheel(event: NSEvent) {
        let dy = event.deltaY
        
        mpEngine.scroll(GLfloat(dy))
    }
    
}