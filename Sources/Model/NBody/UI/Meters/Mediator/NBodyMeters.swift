//
//  NBodyMeters.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// Mediator object for managing multiple hud objects for n-body simulators.
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
//@interface NBodyMeters: NSObject
@objc(NBodyMeters)
class NBodyMeters: NSObject {
//
//@property (nonatomic, readonly) size_t count;
//
//@property (nonatomic) BOOL         isVisible;
//@property (nonatomic) BOOL         useTimer;
//@property (nonatomic) BOOL         useHostInfo;
//@property (nonatomic) std::string  label;
//@property (nonatomic) size_t       index;
//@property (nonatomic) size_t       max;
//@property (nonatomic) GLsizei      bound;
//@property (nonatomic) GLfloat      speed;
//@property (nonatomic) GLfloat      value;
//@property (nonatomic) CGSize       frame;
//@property (nonatomic) CGPoint      point;
//
//- (instancetype) initWithCount:(size_t)count;
//
//- (BOOL) acquire;
//
//- (void) toggle;
//- (void) show:(BOOL)doShow;
//
//- (void) update;
//- (void) reset;
//
//- (void) resize:(NSSize)size;
//
//- (void) draw;
//- (void) draw:(NSArray *)positions;
//
//@end
//
//#pragma mark -
//
//#import <OpenGL/gl.h>
//
//#import "GLMConstants.h"
//#import "GLMTransforms.h"
//
//#import "NBodyMeter.h"
//#import "NBodyMeters.h"
//
//@implementation NBodyMeters
//{
//@private
//    size_t           _index;
    private var _index: NBody.MeterType
//    size_t           _count;
    private var _count: Int
//    NSMutableArray*  mpMeters;
    private var mpMeters: [NBodyMeter] = []
//    NBodyMeter*      mpMeter;
    private var mpMeter: NBodyMeter!
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
        _index = NBody.MeterType(rawValue: 0)!
//        _count = count;
        _count = count
        super.init()
//
//        mpMeters = [[NSMutableArray alloc] initWithCapacity:_count];
        mpMeters.reserveCapacity(_count)
//
//        if(mpMeters)
//        {
//            size_t i;
//
//            for(i = 0; i < _count; ++i)
//            {
        for _ in 0..<_count {
//                mpMeters[i] = [NBodyMeter meter];
            mpMeters.append(NBodyMeter())
//            } // for
        }
//
//            mpMeter = mpMeters[_index];
        mpMeter = mpMeters[_index.rawValue]
//        } // if
//    } // if
//
//    return self;
//} // init
    }
//
//- (void) dealloc
//{
//    if(mpMeters)
//    {
//        [mpMeters release];
//
//        mpMeters = nil;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
//- (void) reset
//{
    func reset() {
//    for(NBodyMeter* pMeter in mpMeters)
//    {
        for pMeter in mpMeters {
//        pMeter.value = 0.0;
            pMeter.value = 0.0
//
//        [pMeter reset];
            pMeter.reset()
//    } // for
        }
//} // reset
    }
//
//- (void) resize:(NSSize)size
//{
    func resize(size: NSSize) {
//    for(NBodyMeter* pMeter in mpMeters)
//    {
        for pMeter in mpMeters {
//        pMeter.frame = size;
            pMeter.frame = size
//    } // for
        }
//} // resize
    }
//
//- (void) show:(BOOL)doShow;
//{
    func show(doShow: Bool) {
//    for(NBodyMeter* pMeter in mpMeters)
//    {
        for pMeter in mpMeters {
//        pMeter.isVisible = doShow;
            pMeter.visible = doShow
//    } // for
        }
//} // show
    }
//
//- (BOOL) acquire
//{
    func acquire() -> Bool {
//    return [mpMeter acquire];
        return mpMeter.acquire()
//} // acquire
    }
//
//- (void) toggle
//{
    func toggle() {
//    [mpMeter toggle];
        mpMeter.toggle()
//} // toggle
    }
//
//- (void) update
//{
    func update() {
//    [mpMeter update];
        mpMeter.update()
//} // update
    }
//
//- (void) draw
//{
    func draw() {
//    [mpMeter draw];
        mpMeter.draw()
//} // draw
    }
//
//- (void) draw:(NSArray *)positions
//{
    func draw(positions: [NSPoint]) {
//    if(positions)
//    {
//        size_t i = 0;
//
//       for(NSValue* position in positions)
//       {
        for (i, position) in positions.enumerate() {
//           NBodyMeter* pMeter = mpMeters[i];
            let pMeter = mpMeters[i]
//
//           pMeter.point = position.pointValue;
            pMeter.point = position
//
//           [pMeter update];
            pMeter.update()
//           [pMeter draw];
            pMeter.draw()
//
//           i++;
//       } // for
        }
//    } // if
//} // draw
    }
//
//- (GLsizei) bound
//{
//    return mpMeter.bound;
//} // bound
//
//- (CGSize) frame
//{
//    return mpMeter.frame;
//} // frame
//
//- (BOOL) useTimer
//{
//    return mpMeter.useTimer;
//} // useTimer
//
//- (BOOL) useHostInfo
//{
//    return mpMeter.useHostInfo;
//} // useHostInfo
//
//- (BOOL) isVisible
//{
//    return mpMeter.isVisible;
//} // isVisible
//
//- (std::string) label
//{
//    return mpMeter.label;
//} // label
//
//- (size_t) max
//{
//    return mpMeter.max;
//} // max
//
//- (CGPoint) point
//{
//    return mpMeter.point;
//} // point
//
//- (GLfloat) speed
//{
//    return mpMeter.speed;
//}// speed
//
//- (GLfloat) value
//{
//    return mpMeter.value;
//} // value
//
    var bound: Int {
        get {return mpMeter.bound}
//- (void) setBound:(GLsizei)bound
//{
        set {
//    mpMeter.bound = bound;
            mpMeter.bound = bound
//} // setBound
        }
    }
//
    var frame: CGSize {
        get {return mpMeter.frame}
//- (void) setFrame:(CGSize)frame
//{
        set {
//    mpMeter.frame = frame;
            mpMeter.frame = newValue
//} // setFrame
        }
    }
//
    var useTimer: Bool {
        get {return mpMeter.useTimer}
//- (void) setUseTimer:(BOOL)useTimer
//{
        set {
//    mpMeter.useTimer = useTimer;
            mpMeter.useTimer = newValue
//} // setUseTimer
        }
    }
//
    var useHostInfo: Bool {
        get {return mpMeter.useHostInfo}
//- (void) setUseHostInfo:(BOOL)useHostInfo
//{
        set {
//    mpMeter.useHostInfo = useHostInfo;
            mpMeter.useHostInfo = newValue
//} // setUseHostInfo
        }
    }
//
    var index: NBody.MeterType {
        get {return _index}
//- (void) setIndex:(size_t)index
//{
        set {
//    _index = (index < _count) ? index : 0;
            _index = (newValue.rawValue < _count) ? newValue : NBody.MeterType(rawValue: 0)!
//
//    mpMeter = mpMeters[_index];
            mpMeter = mpMeters[_index.rawValue]
//} // setIndex
        }
    }
//
    var visible: Bool {
        get {return mpMeter.visible}
//- (void) setIsVisible:(BOOL)isVisible
//{
        set {
//    mpMeter.isVisible = isVisible;
            mpMeter.visible = newValue
//} // setIsVisible
        }
    }
//
    var label: String {
        get {return mpMeter.label}
//- (void) setLabel:(std::string)label
//{
        set {
//    mpMeter.label = label;
            mpMeter.label = newValue
//} // setLabel
        }
    }
//
    var max: Int {
        get {return mpMeter.max}
//- (void) setMax:(size_t)max
//{
        set {
//    mpMeter.max = max;
            mpMeter.max = newValue
//} // setMax
        }
    }
//
    var point: CGPoint {
        get {return mpMeter.point}
//- (void) setPoint:(CGPoint)point
//{
        set {
//    mpMeter.point = point;
            mpMeter.point = newValue
//} // setPoint
        }
    }
//
    var speed: GLfloat {
        get {return mpMeter.speed}
//- (void) setSpeed:(GLfloat)speed
//{
        set {
//    mpMeter.speed = speed;
            mpMeter.speed = newValue
//} // setSpeed
        }
    }
//
    var value: GLdouble {
        get {return mpMeter.value}
//- (void) setValue:(GLfloat)value
//{
        set {
//    mpMeter.value = value;
            mpMeter.value = newValue
//} // setValue
        }
    }
//
//@end
}