//
//  NBodyButtons.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// Mediator object for managing buttons associated with N-Body simulator types.
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
//@interface NBodyButtons : NSObject
@objc(NBodyButtons)
class NBodyButtons: NSObject {
//
//@property (nonatomic, readonly) size_t   count;
//@property (nonatomic, readonly) CGRect   bounds;
//@property (nonatomic, readonly) CGPoint  position;
//
//@property (nonatomic) BOOL         isVisible;
//@property (nonatomic) BOOL         isSelected;
//@property (nonatomic) BOOL         isItalic;
//@property (nonatomic) size_t       index;
//@property (nonatomic) CGFloat      fontSize;
//@property (nonatomic) CGPoint      origin;
//@property (nonatomic) CGSize       size;
//@property (nonatomic) std::string  label;
//@property (nonatomic) GLfloat      speed;
//
//- (instancetype) initWithCount:(size_t)count;
//
//- (BOOL) acquire;
//- (void) toggle;
//- (void) draw;
//
//@end
///*
// <codex>
// <import>NBodyButtons.h</import>
// </codex>
// */
//
//#import "NBodyButton.h"
//#import "NBodyButtons.h"
//
//@implementation NBodyButtons
//{
//@private
//    size_t          _index;
    private var _index: Int
//    size_t          _count;
    private var _count: Int
//    NSMutableArray* mpButtons;
    private var mpButtons: [NBodyButton] = []
//    NBodyButton*    mpButton;
    private var mpButton: NBodyButton!
//}
//
//- (instancetype) initWithCount:(size_t)count
//{
    init(count: Int) {
//    self = [super init];
        assert(count > 0)
//
//    if(self)
//    {
//        _index = 0;
        _index = 0
//        _count = count;
        _count = count
//
//        mpButtons = [[NSMutableArray alloc] initWithCapacity:_count];
        mpButtons.reserveCapacity(_count)
//
//        if(mpButtons)
//        {
//            size_t i;
//
//            for(i = 0; i < _count; ++i)
//            {
        for _ in 0..<_count {
//                mpButtons[i] = [NBodyButton button];
            mpButtons.append(NBodyButton())
//            } // for
        }
//
//            mpButton = mpButtons[_index];
        mpButton = mpButtons[_index]
//        } // if
//    } // if
//
//    return self;
//} // init
    }
//
//- (void) dealloc
//{
//    if(mpButtons)
//    {
//        [mpButtons release];
//
//        mpButtons = nil;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
    var index: Int {
        get {return _index}
//- (void) setIndex:(size_t)index
//{
        set {
//    _index = (index < _count) ? index : 0;
            _index = (0 <= newValue && newValue < _count) ? newValue : 0
//
//    mpButton = mpButtons[_index];
            mpButton = mpButtons[_index]
//} // setIndex
        }
    }
//
//- (BOOL) isItalic
//{
//    return mpButton.isItalic;
//} // isItalic
//
//- (BOOL) isSelected
//{
//    return mpButton.isSelected;
//} // isSelected
//
//- (BOOL) isVisible
//{
//    return mpButton.isVisible;
//} // isVisible
//
//- (std::string) label
//{
//    return mpButton.label;
//} // label
//
//- (CGFloat) fontSize
//{
//    return mpButton.fontSize;
//} // fontSize
//
//- (GLfloat) speed
//{
//    return mpButton.speed;
//} // speed
//
//- (CGRect) bounds
//{
//    return mpButton.bounds;
//} // bounds
//
//- (CGPoint) origin
//{
//    return mpButton.origin;
//} // origin
//
//- (CGPoint) position
//{
//    return mpButton.position;
//} // position
//
//- (CGSize) size
//{
//    return mpButton.size;
//} // size
//
    var label: String {
        get {return mpButton.label}
//- (void) setLabel:(std::string)label
//{
        set {
//    mpButton.label = label;
            mpButton.label = newValue
//} // setLabel
        }
    }
//
    var italic: Bool {
        get {return mpButton.italic}
//- (void) setIsItalic:(BOOL)isItalic
//{
        set {
//    mpButton.isItalic = isItalic;
            mpButton.italic = newValue
//} // setIsItalic
        }
    }
//
    var selected: Bool {
        get {return mpButton.selected}
//- (void) setIsSelected:(BOOL)isSelected
//{
        set {
//    mpButton.isSelected = isSelected;
            mpButton.selected = newValue
//} // setIsSelected
        }
    }
//
    var visible: Bool {
        get {return mpButton.visible}
//- (void) setIsVisible:(BOOL)isVisible
//{
        set {
//    mpButton.isVisible = isVisible;
            mpButton.visible = newValue
//} // setIsVisible
        }
    }
//
    var fontSize: CGFloat {
        get {return mpButton.fontSize}
//- (void) setFontSize:(CGFloat)fontSize
//{
        set {
//    mpButton.fontSize = fontSize;
            mpButton.fontSize = newValue
//} // fontSize
        }
    }
//
    var speed: GLfloat {
        get {return mpButton.speed}
//- (void) setSpeed:(GLfloat)speed
//{
        set {
//    mpButton.speed = speed;
            mpButton.speed = newValue
//} // setSpeed
        }
    }
//
    var origin: CGPoint {
        get {return mpButton.origin}
//- (void) setOrigin:(CGPoint)origin
//{
        set {
//    mpButton.origin = origin;
            mpButton.origin = newValue
//} // setOrigin
        }
    }
//
    var size: CGSize {
        get {return mpButton.size}
//- (void) setSize:(CGSize)size
//{
        set {
//    mpButton.size = size;
            mpButton.size = newValue
//} // setSize
        }
    }
//
//- (BOOL) acquire
//{
    func acquire() -> Bool {
//    return [mpButton acquire];
        return mpButton.acquire()
//} // acquire
    }
//
//- (void) toggle
//{
    func toggle() {
//    [mpButton toggle];
        mpButton.toggle()
//} // toggle
    }
//
//- (void) draw
//{
    func draw() {
//    [mpButton draw];
        mpButton.draw()
//} // draw
    }
//
//@end
}