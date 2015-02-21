//
//  NBodyMeters.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodyMeters.h
     File: NBodyMeters.mm
 Abstract:
 Mediator object for managing multiple hud objects for n-body simulators.

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

extension NBody {
    static let MeterPerf = 0
    static let MeterUpdates = 1
    static let MeterFrames = 2
    static let MeterAll = 3
    static let MeterMax = 4
    
    public typealias MeterType = Int
    
    typealias Timer = HUD.Meter.Timer
    typealias Meter = HUD.Meter.Image
    
    public class Meters {
        
        private var mbStart: Bool = false
        private var m_IsVisible: [Bool] = [false, false, false, false]
        private var m_Bound: [Int] = [0, 0]
        private var m_Frame: CGSize = CGSize()
        private var mnPosition: GLfloat = 0
        private var mnSpeed: GLfloat = 0
        private var mpTimer: Timer?
        private var mpMeter: [Meter?] = [nil, nil, nil]
        private var m_Label: [String] = ["", "", ""]
        private var m_Size: [Int] = [0, 0, 0]
        private var m_Value: [GLdouble] = [0, 0, 0]
    }
}

//MARK: -
//MARK: Private - Headers

import OpenGL.GL

//MARK: -
//MARK: Private - Constants

private let kDefaultSpeed: GLfloat = 0.06

//MARK: -
//MARK: Private - Utilities

extension NBody.Meters {
    public convenience init(length nLength: Int) {
        self.init()
        if nLength != 0 {
            mbStart = false
            mnPosition = 0.0
            mnSpeed    = kDefaultSpeed
            
            mpTimer = nil
            
            m_IsVisible[NBody.MeterPerf]    = true
            m_IsVisible[NBody.MeterUpdates] = false
            m_IsVisible[NBody.MeterFrames]  = false
            m_IsVisible[NBody.MeterAll]     = true
            
            mpMeter[NBody.MeterPerf]    = nil
            mpMeter[NBody.MeterUpdates] = nil
            mpMeter[NBody.MeterFrames]  = nil
            
            m_Label[NBody.MeterPerf]    = ""
            m_Label[NBody.MeterUpdates] = ""
            m_Label[NBody.MeterFrames]  = ""
            
            m_Size[NBody.MeterPerf]    = 0
            m_Size[NBody.MeterUpdates] = 0
            m_Size[NBody.MeterFrames]  = 0
            
            m_Value[NBody.MeterPerf]    = 0.0
            m_Value[NBody.MeterUpdates] = 0.0
            m_Value[NBody.MeterFrames]  = 0.0
            
            m_Bound[0] = nLength
            m_Bound[1] = nLength
            
            m_Frame.width  = 0.0
            m_Frame.height = 0.0
        }
    }
    
    //NBody::Meters::~Meters()
    //{
    //    GLuint i;
    //
    //    for(i = eNBodyMeterPerf; i < eNBodyMeterAll; ++i)
    //    {
    //        if(mpMeter[i] != nullptr)
    //        {
    //            delete mpMeter[i];
    //
    //            mpMeter[i] = nullptr;
    //        } // if
    //
    //        if(!m_Label[i].empty())
    //        {
    //            m_Label[i].clear();
    //        } // if
    //    } // for
    //
    //    if(mpTimer != nullptr)
    //    {
    //        delete mpTimer;
    //
    //        mpTimer = nullptr;
    //    } // if
    //} // Destructor
    
    public func update() {
        if !mbStart {
            mpTimer?.start()
            
            mbStart = true
        } else {
            if let timer = mpTimer {
                timer.stop()
                timer.update()
                
                mpMeter[NBody.MeterFrames]?.setTarget(timer.persecond)
                
                timer.reset()
            }
            
            mpMeter[NBody.MeterFrames]?.update()
        }
    }
    
    public func toggle(type nType: NBody.MeterType = NBody.MeterAll) {
        m_IsVisible[nType] = !m_IsVisible[nType]
    }
    
    public func set(nType: NBody.MeterType, value nValue: GLdouble) {
        m_Value[nType] = nValue
        
        mpMeter[nType]?.setTarget(m_Value[nType])
        mpMeter[nType]?.update()
    }
    
    public func set(nType: NBody.MeterType, label rLabel: String) {
        if !rLabel.isEmpty {
            m_Label[nType] = rLabel
        }
    }
    
    public func set(nType: NBody.MeterType, size nSize: Int) {
        m_Size[nType] = nSize
    }
    
    public func setFrame(rFrame: CGSize) {
        if (rFrame.width > 0.0) && (rFrame.height > 0.0) {
            m_Frame = rFrame
        }
    }
    
    public func setPosition(nPosiiton: GLfloat) {
        if m_IsVisible[NBody.MeterAll] {
            if mnPosition <= (GLM.kHalfPi.f - mnSpeed) {
                mnPosition += mnSpeed
            }
        } else if mnPosition > 0.0 {
            mnPosition -= mnSpeed
        }
    }
    
    public func setSpeed(nSpeed: GLfloat) {
        mnSpeed = nSpeed
    }
    
    public func draw() {
        glMatrixMode(GL_PROJECTION.ui)
        
        let ortho = GLM.ortho(0.0, m_Frame.width.f, 0.0, m_Frame.height.f, -1.0, 1.0)
        
        GLM.load(true, ortho)
        
        glMatrixMode(GL_MODELVIEW.ui)
        glLoadIdentity()
        
        glPushMatrix()
        glTranslatef(0.0, 416.0 - sinf(mnPosition) * 416.0, 0.0)
        
        if m_IsVisible[NBody.MeterFrames] {
            mpMeter[NBody.MeterFrames]?.draw(208.0, y: m_Frame.height.f - 160.0)
        }
        
        if m_IsVisible[NBody.MeterUpdates] {
            mpMeter[NBody.MeterUpdates]?.draw(0.5 * m_Frame.width.f, y: m_Frame.height.f - 160.0)
        }
        
        if m_IsVisible[NBody.MeterPerf] {
            mpMeter[NBody.MeterPerf]?.draw(m_Frame.width.f - 208.0, y: m_Frame.height.f - 160.0)
        }
        glPopMatrix()
    }
    
    public func finalize() -> Bool {
        mpTimer = HUD.Meter.Timer(size: 20, doAscend: false)
        
        for i in NBody.MeterPerf..<NBody.MeterAll {
            mpMeter[i] = HUD.Meter.Image(width: m_Bound[0].i, height: m_Bound[1].i, max: m_Size[i], legend: m_Label[i])
        }
        
        return true
    }
}