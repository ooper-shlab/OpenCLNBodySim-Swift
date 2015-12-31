//
//  NBodyButton.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// Utility  class for managing a button associated with N-Body simulator.
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
//
//@interface NBodyButton : NSObject
@objc(NBodyButton)
class NBodyButton: NSObject {
//
//@property (nonatomic, readonly) CGRect   bounds;
    private(set) var bounds: CGRect
//@property (nonatomic, readonly) CGPoint  position;
    private(set) var position: CGPoint
//
//@property (nonatomic) BOOL         isVisible;
//@property (nonatomic) BOOL         isSelected;
    var selected: Bool
//@property (nonatomic) BOOL         isItalic;
    var italic: Bool
//@property (nonatomic) CGFloat      fontSize;
    var fontSize: CGFloat
//@property (nonatomic) CGPoint      origin;
    var origin: CGPoint
//@property (nonatomic) CGSize       size;
//@property (nonatomic) std::string  label;
//@property (nonatomic) GLfloat      speed;
    var speed: GLfloat
//
//+ (instancetype) button;
//
//- (BOOL) acquire;
//- (void) toggle;
//- (void) draw;
//
//@end
///*
// <codex>
// <import>NBodyButton.h</import>
// </codex>
// */
//
//#pragma mark -
//#pragma mark Private - Headers
//
//#import "GLMConstants.h"
//#import "HUDButton.h"
//#import "NBodyConstants.h"
//#import "NBodyButton.h"
//
//@implementation NBodyButton
//{
//@private
//    BOOL         _isVisible;
    private var _visible: Bool
//    BOOL         _isSelected;
//    BOOL         _isItalic;
//    CGFloat      _fontSize;
//    GLfloat      _speed;
//    CGRect       _bounds;
//    CGPoint      _position;
//    CGPoint      _origin;
//    CGSize       _size;
    private var _size: CGSize
//    std::string  _label;
    private var _label: String
//
//    HUD::Button::Image* mpButton;
    var mpButton: HUD.Button.Image?
//}
//
//- (instancetype) init
//{
    override init() {
//    self = [super init];
//
//    if(self)
//    {
//        mpButton    = nullptr;
        mpButton    = nil
//        _label      = "";
        _label      = ""
//        _isVisible  = YES;
        _visible  = true
//        _isSelected = NO;
        selected = false
//        _isItalic   = NO;
        italic   = false
//        _fontSize   = 24.0f;
        fontSize   = 24.0
//        _bounds     = NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f);
        bounds     = NSMakeRect(0.0, 0.0, 0.0, 0.0)
//        _size       = NSMakeSize(0.0f, 0.0f);
        _size       = NSMakeSize(0.0, 0.0)
//        _position   = NSMakePoint(0.0f, 0.0f);
        position   = NSMakePoint(0.0, 0.0)
//        _origin     = CGPointMake(0.0f, (_isVisible ? GLM::kHalfPi_f : 0.0f));
        origin     = CGPointMake(0.0, (_visible ? GLM.kHalfPi.g : 0.0))
//        _speed      = NBody::Defaults::kSpeed;
        speed      = NBody.Defaults.kSpeed.f
//    } // if
//
//    return self;
        super.init()
//} // init
    }
//
//+ (instancetype) button
//{
//    return [[[NBodyButton allocWithZone:[self zone]] init] autorelease];
//} // button
//
//- (void) dealloc
//{
//    if(!_label.empty())
//    {
//        _label.clear();
//    } // if
//
//    if(mpButton != nullptr)
//    {
//        delete mpButton;
//
//        mpButton = nullptr;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
    var visible: Bool {
        get {return _visible}
//- (void) setIsVisible:(BOOL)isVisible
//{
        set {
//    _isVisible = isVisible;
            _visible = newValue
//    _origin.y  = _isVisible ? GLM::kHalfPi_f : 0.0f;
            origin.y  = _visible ? GLM.kHalfPi.g : 0.0
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
    var size: CGSize {
        get {return _size}
//- (void) setSize:(CGSize)size
//{
        set {
//    _size   = size;
            _size = newValue
//    _bounds = CGRectMake(0.75f * _size.width - 0.5f * NBody::Button::kWidth,
            bounds = CGRectMake(0.75 * _size.width - 0.5 * NBody.Button.kWidth.g,
//                         NBody::Button::kSpacing,
                NBody.Button.kSpacing.g,
//                         NBody::Button::kWidth,
                NBody.Button.kWidth.g,
//                         NBody::Button::kHeight);
                NBody.Button.kHeight.g)
//} // setSize
        }
    }
//
//- (BOOL) acquire
//{
    func acquire() -> Bool {
//    if(mpButton == nullptr)
//    {
        if mpButton == nil {
//        mpButton = new (std::nothrow) HUD::Button::Image(_bounds,
            mpButton = HUD.Button.Image(bounds,
//                                                         _fontSize,
                fontSize,
//                                                         _isItalic,
                italic,
//                                                         _label);
                _label)
//    } // if
        }
//
//    return mpButton != nullptr;
        return mpButton != nil
//} // acquire
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
//- (void) draw
//{
    func draw() {
//    if(mpButton != nullptr)
//    {
        guard let mpButton = mpButton else {return}
//        if(_isVisible)
//        {
        if _visible {
//            if(_origin.y <= (GLM::kHalfPi_f - _speed))
//            {
            if origin.y <= (GLM.kHalfPi.g - speed.g) {
//                _origin.y += _speed;
                origin.y += speed.g
//            } // if
            }
//        } // if
//        else if(_origin.y > 0.0f)
//        {
        } else if origin.y > 0.0 {
//            _origin.y -= _speed;
            origin.y -= speed.g
//        } // else if
        }
//
//        GLfloat x = -NBody::Button::kWidth * std::sin(_origin.x);
        let x = -NBody.Button.kWidth.g * sin(origin.x)
//        GLfloat y = 100.0f * (std::sin(_origin.y) - 1.0f);
        let y = 100.0 * (sin(origin.y) - 1.0)
//
//        _position = CGPointMake(x, y);
        position = CGPointMake(x, y)
//
//        mpButton->draw(_isSelected, _position, _bounds);
        mpButton.draw(selected, position, bounds)
//    } // if
//} // draw
    }
//
//@end
}