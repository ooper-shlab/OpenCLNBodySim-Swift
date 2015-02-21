//
//  GLMSizes.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: GLMSizes.h
     File: GLMSizes.mm
 Abstract:
 OpenGL size types.

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

extension GLM {
    public struct Size {
        
        private static let GLSizeChar = strideof(GLchar)
        private static let GLSizeChrPtr = strideof(UnsafePointer<GLchar>)
        private static let GLSizeFloat = strideof(GLfloat)
        private static let GLSizeDouble = strideof(GLdouble)
        private static let GLSizeSignedByte = strideof(GLbyte)
        private static let GLSizeSignedBytePtr = strideof(UnsafePointer<GLbyte>)
        private static let GLSizeSignedShort = strideof(GLshort)
        private static let GLSizeSignedInt = strideof(GLint)
        private static let GLSizeUnsignedByte = strideof(GLubyte)
        private static let GLSizeUnsignedShort = strideof(GLushort)
        private static let GLSizeUnsignedInt = strideof(GLuint)
        private static let GLSizeLong = strideof(Int64)
        private static let GLSizeULong = strideof(UInt64)
        
        public static let kByte = GLSizeSignedByte
        public static let kBytePtr = GLSizeSignedBytePtr
        public static let kChar = GLSizeChar
        public static let kCharPtr = GLSizeChrPtr
        public static let kFloat = GLSizeFloat
        public static let kHFloat = GLSizeFloat / 2
        public static let kDouble = GLSizeDouble
        public static let kShort = GLSizeSignedShort
        public static let kInt = GLSizeSignedInt
        public static let kLong = GLSizeLong
        public static let kUByte = GLSizeUnsignedByte
        public static let kUInt = GLSizeUnsignedInt
        public static let kULong = GLSizeULong
        public static let kUShort = GLSizeUnsignedShort
    }
}
