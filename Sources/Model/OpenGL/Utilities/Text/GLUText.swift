//
//  GLUText.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
     File: GLUText.h
     File: GLUText.mm
 Abstract:
 Utility methods for generating OpenGL texture from a string.

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



//MARK: -
//MARK: Private - Headers

import OpenGL.GL

extension GLU {
    public class Text {
        
        deinit {
            self.destruct()
        }
        
        private var mnTexture: GLuint = 0
        private var m_Bounds: CGRect = CGRect()
        private var m_Range: CFRange = CFRange(location: 0, length: 0)
        
        //MARK: -
        //MARK: Private - Constants
        
        private final let kGLUTextBPC: GLuint = 8
        private final let kGLUTextSPP: GLuint = 4
        
        private final let kGLUTextBitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        //MARK: -
        //MARK: Private - Utilities - Constructors - Contexts
        
        private func create(nWidth: GLsizei, _ nHeight: GLsizei) -> CGContext? {
            var pContext: CGContext? = nil
            
            if nWidth * nHeight != 0 {
                let pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
                
                if pColorspace != nil {
                    let bpp = nWidth.ul * kGLUTextSPP.ul
                    
                    pContext = CGBitmapContextCreate(nil,
                        nWidth.ul,
                        nHeight.ul,
                        kGLUTextBPC.ul,
                        bpp,
                        pColorspace,
                        kGLUTextBitmapInfo)
                    
                    if pContext != nil {
                        CGContextSetShouldAntialias(pContext, true)
                    }
                    
                }
            }
            
            return pContext
        }
        
        private func create(rSize: CGSize) -> CGContext? {
            return create(GLsizei(rSize.width), GLsizei(rSize.height))
        }
        
        //MARK: -
        //MARK: Private - Utilities - Constructors - Texturers
        
        private func create(pContext: CGContext) -> GLuint {
            var texture: GLuint = 0
            
            glGenTextures(1, &texture)
            
            if texture != 0 {
                glBindTexture(GL_TEXTURE_2D.ui, texture)
                
                glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
                glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
                glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
                glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
                
                let width = GLsizei(CGBitmapContextGetWidth(pContext))
                let height = GLsizei(CGBitmapContextGetHeight(pContext))
                let pData  = CGBitmapContextGetData(pContext)
                
                glTexImage2D(GL_TEXTURE_2D.ui,
                    0,
                    GL_RGBA,
                    width,
                    height,
                    0,
                    GL_RGBA.ui,
                    GL_UNSIGNED_BYTE.ui,
                    pData)
            }
            
            return texture
        }
        
        private func create(rText: String, _ rFont: String, _ nFontSize: CGFloat, _ rOrigin: CGPoint, _ nTextAlign: CTTextAlignment) -> GLuint {
            var nTexture: GLuint = 0
            
            let pFrame = CT.Frame(text: rText, font: rFont, fontSize: nFontSize, origin: rOrigin, textAlign: nTextAlign)
            
            m_Bounds = pFrame.bounds
            m_Range  = pFrame.range
            
            let pContext = create(m_Bounds.size)
            
            if pContext != nil {
                pFrame.draw(pContext)
                
                nTexture = create(pContext!)
                /*if let cgImage = CGBitmapContextCreateImage(pContext) {
                let url = NSURL(fileURLWithPath: "/Users/dev/Desktop/\(rText).png")!
                if let dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) {
                CGImageDestinationAddImage(dest, cgImage, nil);
                if (!CGImageDestinationFinalize(dest)) {
                NSLog("Failed to write image to %@", url);
                }
                } else {
                println("CGImageDestinationCreateWithURL")
                }
                } else {
                println("err:CGBitmapContextCreateImage")
                }*/
                
            } else {
                NSLog(">> ERROR: Failed creating Core-Text frame object")
            }
            
            return nTexture
        }
        
        private func create(rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment)
            -> GLuint {
                var nTexture: GLuint = 0
                
                let pFrame = CT.Frame(text: rText, font: rFont, fontSize: nFontSize, width: nWidth, height: nHeight, textAlign: nTextAlign)
                
                m_Bounds = pFrame.bounds
                m_Range = pFrame.range
                
                let pContext = create(nWidth, nHeight)
                
                if pContext != nil {
                    pFrame.draw(pContext)
                    
                    nTexture = create(pContext!)
                    /*if let cgImage = CGBitmapContextCreateImage(pContext) {
                    let url = NSURL(fileURLWithPath: "/Users/dev/Desktop/\(rText).png")!
                    if let dest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) {
                    CGImageDestinationAddImage(dest, cgImage, nil);
                    if (!CGImageDestinationFinalize(dest)) {
                    NSLog("Failed to write image to %@", url);
                    }
                    } else {
                    println("CGImageDestinationCreateWithURL")
                    }
                    } else {
                    println("err:CGBitmapContextCreateImage")
                    }*/
                    
                } else {
                    NSLog(">> ERROR: Failed creating Core-Text frame object")
                }
                
                return nTexture
        }
        
        //MARK: -
        //MARK: Public - Constructors
        
        // Create a texture with bounds derived from the text size.
        public init(text rText: String,
            font rFont: String,
            fontSize nFontSize: CGFloat,
            origin rOrigin: CGPoint,
            textAlign nTextAlign: CTTextAlignment = .TextAlignmentCenter) {
                mnTexture = create(rText, rFont, nFontSize, rOrigin, nTextAlign)
        }
        
        // Create a texture with bounds derived from the input width and height.
        public init(text rText: String,
            font rFont: String,
            fontSize nFontSize: CGFloat,
            width nWidth: GLsizei,
            height nHeight: GLsizei,
            textAlign nTextAlign: CTTextAlignment = .TextAlignmentCenter) {
                mnTexture = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        // Create a texture with bounds derived from the text size using
        // helvetica bold or helvetica bold oblique font.
        public init(text rText: String,
            fontSize nFontSize: CGFloat,
            isItalic bIsItalic: Bool,
            origin rOrigin: CGPoint,
            textAlign nTextAlign: CTTextAlignment = .TextAlignmentCenter) {
                let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
                
                mnTexture = create(rText, font, nFontSize, rOrigin, nTextAlign)
        }
        
        // Create a texture with bounds derived from input width and height,
        // and using helvetica bold or helvetica bold oblique font.
        public init(text rText: String,
            fontSize nFontSize: CGFloat,
            isItalic bIsItalic: Bool,
            width nWidth: GLsizei,
            height nHeight: GLsizei,
            textAlign nTextAlign: CTTextAlignment = .TextAlignmentCenter) {
                let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
                
                mnTexture = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        //MARK: -
        //MARK: Public - Destructor
        
        private func destruct() {
            if mnTexture != 0 {
                glDeleteTextures(1, &mnTexture)
                
                mnTexture = 0
            }
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        public var texture: GLuint {
            return mnTexture
        }
        
        public var bounds: CGRect {
            return m_Bounds
        }
        
        public var range: CFRange {
            return m_Range
        }
    }
}