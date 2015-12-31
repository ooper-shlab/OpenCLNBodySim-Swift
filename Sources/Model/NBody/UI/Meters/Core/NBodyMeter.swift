//
//  NBodyMeter.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// A base utility class for managing performance meters.
// </abstract>
// </codex>
// */
//
//#import <string>
//
//#import <Cocoa/Cocoa.h>
import Cocoa
//#import <OpenGL/OpenGL.h>
import OpenGL.GL

private let kDefaultSpeed: GLfloat = 0.06
//
//@interface NBodyMeter: NSObject
@objc(NBodyMeter)
class NBodyMeter: NSObject {
//
//@property (nonatomic) BOOL         isVisible;
    private var _visible: Bool = true
//@property (nonatomic) BOOL         useTimer;
    var useTimer: Bool = false
//@property (nonatomic) BOOL         useHostInfo;
    var useHostInfo: Bool = false
//@property (nonatomic) std::string  label;
    private var _label: String = ""
//@property (nonatomic) size_t       max;
    var max: Int = 0
//@property (nonatomic) GLsizei      bound;
    var bound: Int = 0
//@property (nonatomic) GLfloat      speed;
    var speed: GLfloat = kDefaultSpeed
//@property (nonatomic) GLdouble     value;
    private var _value: GLdouble = 0.0
//@property (nonatomic) CGSize       frame;
    private var _frame: CGSize = NSMakeSize(0.0, 0.0)
//@property (nonatomic) CGPoint      point;
    var point: CGPoint = NSMakePoint(0.0, 0.0)
//
//+ (instancetype) meter;
//
//- (BOOL) acquire;
//- (void) toggle;
//
//- (void) update;
//- (void) draw;
//
//- (void) reset;
//
//@end
//
///*
// <codex>
// <import>NBodyMeter.h</import>
// </codex>
// */
//
//#import <OpenGL/gl.h>
//
//#import "CFCPULoad.h"
//
//#import "GLMConstants.h"
//#import "GLMTransforms.h"
//
//#import "HUDMeterImage.h"
//#import "HUDMeterTimer.h"
//
//#import "NBodyMeter.h"
//
//static const GLfloat kDefaultSpeed = 0.06f;
//
//@implementation NBodyMeter
//{
//@private
//    BOOL  _isVisible;
//    BOOL  _useTimer;
//    BOOL  _useHostInfo;
//
//    size_t   _max;
//    GLsizei  _bound;
//    GLfloat  _speed;
//    CGSize   _frame;
//    CGPoint  _point;
//
//    std::string  _label;
//
//    BOOL mbStart;
    private var mbStart: Bool = false
//
//    GLfloat mnPosition;
    private var mnPosition: GLfloat = 0.0
//
//    HUD::Meter::Image* mpMeter;
    private var mpMeter: HUD.Meter.Image?
//    HUD::Meter::Timer* mpTimer;
    private var mpTimer: HUD.Meter.Timer?
//
//    CF::CPU::Load* mpLoad;
    private var mpLoad: CF.CPU.Load?
//}
//
//- (instancetype) init
//{
    override init() {
//    self = [super init];
//
//    if(self)
//    {
//        _isVisible   = YES;
        _visible   = true
//        _useTimer    = NO;
        useTimer    = false
//        _useHostInfo = NO;
        useHostInfo = false
//
//        _speed = kDefaultSpeed;
        speed = kDefaultSpeed
//        _bound = 0;
        bound = 0
//        _max   = 0;
        max   = 0
//        _frame = NSMakeSize(0.0f, 0.0f);
        _frame = NSMakeSize(0.0, 0.0)
//        _point = NSMakePoint(0.0f, 0.0f);
        point = NSMakePoint(0.0, 0.0)
//        _label = "";
        _label = ""
//
//        mbStart    = NO;
        mbStart    = false
//        mnPosition = 0.0f;
        mnPosition = 0.0
//
//        mpMeter = nullptr;
        mpMeter = nil
//        mpTimer = nullptr;
        mpTimer = nil
//        mpLoad  = nullptr;
        mpLoad  = nil
//    } // if
//
//    return self;
        super.init()
//} // initWithBound
    }
//
//+ (instancetype) meter
//{
//    return [[[NBodyMeter allocWithZone:[self zone]] init] autorelease];
//} // meterWithBound
//
//- (void) dealloc
//{
//    if(mpTimer != nullptr)
//    {
//        delete mpTimer;
//
//        mpTimer = nullptr;
//    } // if
//
//    if(mpMeter != nullptr)
//    {
//        delete mpMeter;
//
//        mpMeter = nullptr;
//    } // if
//
//    if(mpLoad != nullptr)
//    {
//        delete mpLoad;
//
//        mpLoad = nullptr;
//    } // if
//
//    if(!_label.empty())
//    {
//        _label.clear();
//    } // if
//
//    [super dealloc];
//} // dealloc
//
    var frame: CGSize {
        get {return _frame}
//- (void) setFrame:(CGSize)frame
//{
        set {
//    if((frame.width > 0.0f) && (frame.height > 0.0f))
//    {
            if (newValue.width > 0.0) && (newValue.height > 0.0) {
//        _frame = frame;
                _frame = newValue
//    } // if
            }
//} // setFrame
        }
    }
//
    var visible: Bool {
        get {return _visible}
//- (void) setIsVisible:(BOOL)isVisible
//{
        set {
//    _isVisible = isVisible;
            _visible = newValue
//} // setIsVisible
        }
    }
//
    var label: String {
        get {return _label}
//- (void) setLabel:(std::string)label
//{
        set {
//    if(!label.empty())
//    {
            if !newValue.isEmpty {
//        _label = label;
                _label = newValue
//    } // if
            }
        }
//} // setLabel
    }
//
    var value: GLdouble {
//- (void) setValue:(GLdouble)value
//{
        set {
//    mpMeter->setTarget(value);
            mpMeter?.target = value
//} // setValue
        }
//
//- (GLdouble) value
//{
        get {
//    return mpMeter->target();
            return mpMeter?.target ?? 0.0
//} // value
        }
    }
//
//- (void) toggle
//{
    func toggle() {
//    _isVisible = !_isVisible;
        _visible = !_visible
//} // toggle
    }
//
//- (BOOL) acquire
//{
    func acquire() -> Bool {
//    if(_useHostInfo)
//    {
        if useHostInfo {
//        mpLoad = new (std::nothrow) CF::CPU::Load;
            mpLoad = CF.CPU.Load()
//
//        if(!mpLoad)
//        {
//            NSLog(@">> ERROR: Failed acquiring a CPU utilization query object!");
//
//            return false;
//        } // if
//    } // if
        }
//
//    if(_useTimer)
//    {
        if useTimer {
//        mpTimer = new (std::nothrow) HUD::Meter::Timer(20, false);
            mpTimer = HUD.Meter.Timer(20, doAscend: false)
//
//        if(!mpTimer)
//        {
//            NSLog(@">> ERROR: Failed acquiring a hi-res timer for the meters!");
//
//            return false;
//        } // if
//    } // if
        }
//
//    mpMeter = new (std::nothrow) HUD::Meter::Image(_bound, _bound, _max, _label);
        mpMeter = HUD.Meter.Image(width: bound.i, height: bound.i, max: max, legend: _label)
//
//    if(!mpMeter)
//    {
//        NSLog(@">> ERROR: Failed acquiring a meter object!");
//
//        return false;
//    } // if
//
//    return true;
        return true
//} // acquire
    }
//
//- (void) reset
//{
    func reset() {
//    if(_useTimer)
//    {
        if useTimer {
//        mpTimer->reset();
            mpTimer?.reset()
//    } // if
        }
//} // reset
    }
//
//- (void) update
//{
    func update() {
//    if(_useTimer)
//    {
        if useTimer {
//        if(!mbStart)
//        {
            if !mbStart {
//            mpTimer->start();
                mpTimer?.start()
//
//            mbStart = YES;
                mbStart = true
//        } // if
//        else
//        {
            } else {
//            mpTimer->stop();
                mpTimer?.stop()
//            mpTimer->update();
                mpTimer?.update()
//
//            mpMeter->setTarget(mpTimer->persecond());
                mpMeter?.target = mpTimer?.persecond ?? 0.0
//
//            mpTimer->reset();
                mpTimer?.reset()
//        } // else
            }
//    } // if
        }
//
//    if(_useHostInfo)
//    {
        if useHostInfo {
//        GLdouble nPercentage = mpLoad->percentage();
            let nPercentage = mpLoad?.percentage ?? 0.0
//
//        GLdouble nTargetSrc = mpMeter->target();
            let nTargetSrc = mpMeter?.target ?? 0.0
//        GLdouble nTargetDst = 0.01 * nPercentage + 0.99 * nTargetSrc;
            let nTargetDst = 0.01 * nPercentage + 0.99 * nTargetSrc
//
//        mpMeter->setTarget(nTargetDst);
            mpMeter?.target = nTargetDst
//    } // if
        }
//
//    mpMeter->update();
        mpMeter?.update()
//} // update
    }
//
//- (void) draw
//{
    func draw() {
//    glMatrixMode(GL_PROJECTION);
        glMatrixMode(GL_PROJECTION.ui)
//
//    GLM::load(true, GLM::ortho(0.0f, _frame.width, 0.0f, _frame.height, -1.0f, 1.0f));
        GLM.load(true, GLM.ortho(0.0, _frame.width.f, 0.0, _frame.height.f, -1.0, 1.0))
//
//    GLM::identity(GL_MODELVIEW);
        GLM.identity(GL_MODELVIEW.ui)
//
//    if(_isVisible)
//    {
        if _visible {
//        if(mnPosition <= (GLM::kHalfPi_f - _speed))
//        {
            if mnPosition <= GLM.kHalfPi.f - speed {
//            mnPosition += _speed;
                mnPosition += speed
//        } // if
            }
//    } // if
//    else if(mnPosition > 0.0f)
//    {
        } else if mnPosition > 0.0 {
//        mnPosition -= _speed;
            mnPosition -= speed
//    } // else if
        }
//
//    GLfloat y = 416.0f * (1.0f - std::sin(mnPosition));
        let y = 416.0 * (1.0 - sin(mnPosition))
//
//    GLM::load(true, GLM::translate(0.0f, y, 0.0f));
        GLM.load(true, GLM.translate(0.0, y, 0.0))
//
//    if(mnPosition > 0.0f)
//    {
        if mnPosition > 0.0 {
//        mpMeter->draw(_point.x, _frame.height - _point.y);
            mpMeter?.draw(point.x.f, _frame.height.f - point.y.f)
//    } // if
        }
//
//    GLM::identity(GL_MODELVIEW);
        GLM.identity(GL_MODELVIEW.ui)
//} // draw
    }
//
//@end
}