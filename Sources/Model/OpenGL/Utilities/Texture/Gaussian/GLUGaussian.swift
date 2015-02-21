//
//  GLUGaussian.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: GLUGaussian.h
     File: GLUGaussian.mm
 Abstract:
 Utility methods for creating a Gaussian texture.

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

extension GLU {
    public class Gaussian {
        
        deinit {destruct()}
        
        private var mnTexture: GLuint = 0
        private var mnTexRes: GLuint = 0
        private var mnTarget: GLenum = 0
        
        //MARK: -
        //MARK: Private - Utilities - Gaussian Map
        
        private class func HermiteBasis(pA: GLfloat,
            _ pB: GLfloat,
            _ vA: GLfloat,
            _ vB: GLfloat,
            _ u1: GLfloat)
            -> GLfloat
        {
            let u2 = u1 * u1
            let u3 = u2 * u1
            let B0 = 2.0 * u3 - 3.0 * u2 + 1.0
            let B1 = -2.0 * u3 + 3.0 * u2
            let B2 = u3 - 2.0 * u2 + u1
            let B3 = u3 - u1
            
            return B0 * pA + B1 * pB + B2 * vA + B3 * vB
        }
        
        private class func createImage(nTexRes: GLuint) -> [GLubyte] {
            var pImage: [GLubyte] = []
            
            if nTexRes != 0 {
                let nCardinality = nTexRes * nTexRes
                
                var pMap = [GLfloat](count: 2 * Int(nCardinality), repeatedValue: 0.0)
                
                pImage = [GLubyte](count: Int(nCardinality), repeatedValue: 0)
                
                var X: GLfloat      = -1.0
                var Y: GLfloat      = -1.0
                var Y2: GLfloat     =  0.0
                var nDist: GLfloat  =  0.0
                let nDelta: GLfloat =  2.0 / GLfloat(nTexRes)
                
                var i = 0
                var j = 0
                
                for var y: GLint = 0; y < GLint(nTexRes); ++y, Y += nDelta {
                    Y2 = Y * Y
                    
                    for var x: GLint = 0; x < GLint(nTexRes); ++x, X += nDelta, i += 2, ++j {
                        nDist = sqrtf(X * X + Y2)
                        
                        if nDist > 1.0 {
                            nDist = 1.0
                        }
                        
                        pMap[i]   = HermiteBasis(1.0, 0.0, 0.0, 0.0, nDist)
                        
                        pMap[i+1] = pMap[i]
                        
                        pImage[j] = GLubyte(pMap[i] * 255.0)
                    }
                    
                    X  = -1.0
                }
                
            }
            
            return pImage
        }
        
        //MARK: -
        //MARK: Private - Utilities - Constructors
        
        private class func createTexture(nTexRes: GLsizei) -> GLuint {
            var texture: GLuint = 0
            
            let pImage = createImage(GLuint(nTexRes))
            
            if !pImage.isEmpty {
                glGenTextures(1, &texture)
                
                if texture != 0 {
                    glBindTexture(GL_TEXTURE_2D.ui, texture)
                    
                    glTexParameteri(GL_TEXTURE_2D.ui, GL_GENERATE_MIPMAP_SGIS.ui, GL_TRUE)
                    glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR_MIPMAP_LINEAR)
                    glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
                    
                    glTexImage2D(GL_TEXTURE_2D.ui,
                        0,
                        GL_LUMINANCE8,
                        nTexRes,
                        nTexRes,
                        0,
                        GL_LUMINANCE.ui,
                        GL_UNSIGNED_BYTE.ui,
                        pImage)
                }
                
            }
            
            return texture
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        public init(texRes nTexRes: GLuint) {
            mnTarget = GL_TEXTURE_2D.ui
            mnTexRes = nTexRes
            mnTexture = GLU.Gaussian.createTexture(GLsizei(mnTexRes))
        }
        
        private func destruct() {
            if mnTexture != 0 {
                glDeleteTextures(1, &mnTexture)
                
            }
        }
        
        public init(texture rTexture: Gaussian) {
            mnTarget = rTexture.mnTarget
            mnTexRes = rTexture.mnTexRes
            mnTexture = GLU.Gaussian.createTexture(GLsizei(mnTexRes))
        }
        
        public func enable() {
            glBindTexture(mnTarget, mnTexture)
        }
        
        public func disable() {
            glBindTexture(mnTarget, 0)
        }
        
        public var texture: GLuint {
            return mnTexture
        }
        
        public var target: GLenum {
            return mnTarget
        }
    }
}