//
//  NBodyConstants.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodyConstants.h
 Abstract:
 Common constant for NBody simulation.

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

import OpenGL

extension NBody {
    public struct Mouse {
        public struct Button {
            public static let kLeft: Int = 0
            public static let kDown: Int = 1
            public static let kUp: Int = 0
        }
        
        public struct Wheel {
            public static let kDown: Int = -1
            public static let kUp: Int = 1
        }
    }
    
    public struct Button {
        public static let kWidth: GLfloat = 1000.0
        public static let kHeight: GLfloat = 48.0
        public static let kSpacing: GLfloat = 32.0
    }
    
    public struct Scale {
        public static let kTime: GLfloat = 0.4
        public static let kSoftening: GLfloat = 1.0
    }
    
    public struct Window {
        public static let kWidth: GLfloat = 800.0
        public static let kHeight: GLfloat = 500.0
    }
    
    public struct Bodies {
        public static let kCountMax: Int = 32768
        public static let kCountMin: Int = kCountMax / 4
        public static let kCount: Int = kCountMax
    }
    
    public struct Star {
        public static let kSize: GLfloat = 4.0
        public static let kScale: GLfloat = 1.0
    }
    
    public struct Defaults {
        public static let kSpeed: GLfloat = 0.06
        public static let kRotationDelta: GLfloat = 0.06
        public static let kScrollZoomSpeed: GLfloat = 0.5
        public static let kViewDistance: GLfloat = 30.0
        public static let kMeterSize: Int = 300
    }
}

extension NBody {
    public enum Config: Int {
        case Random = 0
        case Shell
        case Expand
        case MWM31
    }
}

