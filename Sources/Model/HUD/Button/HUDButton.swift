//
//  HUDButton.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: HUDButton.h
     File: HUDButton.mm
 Abstract:
 Utility class for generating a button in an OpenGL view.

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

extension HUD {
    public struct Button {
        public typealias Label = String
        
        //MARK: -
        //MARK: Private - Enumerated Types
        
        enum Tracking {
            case Nothing
            case Pressed
            case Unpressed
        }
        
        typealias Position = CGPoint
        typealias Bounds = CGRect
        
        public class Image {
            
            deinit {destruct()}
            
            private var mbIsItalic: Bool = false
            private var m_Texture: [GLuint] = [0, 0]
            private var mnSize: CGFloat = 0
            private var mnWidth: GLsizei = 0
            private var mnHeight: GLsizei = 0
            private var m_Bounds: CGRect = CGRect()
            private var m_Label: Label = ""
            private var mpQuad: GLU.Quad!
            private var mpText: GLU.Text!
            
        }
    }
}

//MARK: -
//MARK: Private - Utilities

extension HUD {
    private static func addRoundedRectToPath(context: CGContext,
        _ rect: CGRect,
        _ ovalWidth: GLfloat,
        _ ovalHeight: GLfloat)
    {
        
        if ovalWidth == 0.0 || ovalHeight == 0.0 {
            CGContextAddRect(context, rect)
            
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextTranslateCTM(context,
            CGRectGetMinX(rect),
            CGRectGetMinY(rect))
        
        CGContextScaleCTM(context, CGFloat(ovalWidth), CGFloat(ovalHeight))
        
        let fw = CGRectGetWidth(rect) / CGFloat(ovalWidth)
        let fh = CGRectGetHeight(rect) / CGFloat(ovalHeight)
        
        CGContextMoveToPoint(context, fw, fh / 2.0)
        
        CGContextAddArcToPoint(context, fw, fh, fw / 2.0, fh, 1.0)
        CGContextAddArcToPoint(context, 0.0, fh, 0.0, fh / 2.0, 1.0)
        CGContextAddArcToPoint(context, 0.0, 0.0, fw / 2.0, 0.0, 1.0)
        CGContextAddArcToPoint(context, fw, 0.0, fw, fh / 2.0, 1.0)
        
        CGContextClosePath(context)
        
        CGContextRestoreGState(context)
    }
}

extension HUD.Button {
    private static func createTexture(rSize: CGSize) -> GLuint {
        var texture: GLuint = 0
        
        glGenTextures(1, &texture)
        
        if texture != 0 {
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, texture)
            
            if let pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB) {
                
                let width  = GLsizei(rSize.width)
                let height = GLsizei(rSize.height)
                let bpp     = size_t(width) * size_t(HUD.SamplesPerPixel)
                
                if let pContext = CGBitmapContextCreate(nil,
                    width.l,
                    height.l,
                    HUD.BitsPerComponent,
                    bpp,
                    pColorspace,
                    HUD.BitmapInfo)
                {
                    
                    let cx = HUD.CenterX * GLfloat(rSize.width)
                    let cy = HUD.CenterY * GLfloat(rSize.height)
                    let sx = 0.05 * GLfloat(rSize.width)
                    let sy = 0.5  * GLfloat(rSize.height) - 32.0
                    
                    let bound = CGRectMake(CGFloat(sx), CGFloat(sy), 0.9 * rSize.width, 64.0)
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0, CGFloat(height))
                    CGContextScaleCTM(pContext, 1.0, -1.0)
                    CGContextClearRect(pContext, CGRectMake(0, 0.0, CGFloat(width), CGFloat(height)))
                    CGContextSetRGBFillColor(pContext, 0.0, 0.0, 0.0, 0.8)
                    
                    HUD.addRoundedRectToPath(pContext, bound, 32.0, 32.0)
                    
                    CGContextFillPath(pContext)
                    
                    // top bevel
                    CGContextSaveGState(pContext)
                    
                    let count: size_t = 2
                    
                    let locations: [CGFloat] = [0.0, 1.0]
                    
                    let components: [CGFloat] = [
                        1.0, 1.0, 1.0, 0.5,
                        0.0, 0.0, 0.0, 0.0,
                    ]
                    
                    HUD.addRoundedRectToPath(pContext, bound, 32.0, 32.0)
                    
                    CGContextEOClip(pContext)
                    
                    if let pGradient = CGGradientCreateWithColorComponents(pColorspace,
                        components,
                        locations,
                        count)
                    {
                        
                        
                        CGContextDrawLinearGradient(pContext,
                            pGradient,
                            CGPointMake(CGFloat(cx), CGFloat(cy) + 32.0),
                            CGPointMake(CGFloat(cx), CGFloat(cy)),
                            0)
                        
                        CGContextDrawLinearGradient(pContext,
                            pGradient,
                            CGPointMake(CGFloat(cx), CGFloat(cy) - 32.0),
                            CGPointMake(CGFloat(cx), CGFloat(cy) - 16.0),
                            0)
                        
                    }
                    
                    CGContextRestoreGState(pContext)
                    
                    let pData = CGBitmapContextGetData(pContext)
                    
                    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB.ui,
                        0,
                        GL_RGBA,
                        width,
                        height,
                        0,
                        GL_RGBA.ui,
                        GL_UNSIGNED_BYTE.ui,
                        pData)
                    
                }
                
            }
            
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, 0)
        }
        
        return texture
    }
}

//MARK: -
//MARK: Public - Button - Utilities

extension HUD.Button.Image {
    public convenience init(bounds rBounds: CGRect,
        size: CGFloat)
    {
        self.init()
        
        if !CGRectIsEmpty(rBounds) {
            m_Bounds     = rBounds
            mbIsItalic   = false
            mnSize       = (size > 12.0) ? size : 24.0
            m_Label      = ""
            mnWidth      = GLsizei(rBounds.size.width  + 0.5)
            mnHeight     = GLsizei(rBounds.size.height + 0.5)
            m_Texture[0] = HUD.Button.createTexture(rBounds.size)
            m_Texture[1] = 0;
            mpText       = nil
            mpQuad       = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
        }
    }
    
    public convenience init(bounds rBounds: CGRect,
        size: CGFloat,
        italic: Bool,
        label: String)
    {
        self.init()
        if !CGRectIsEmpty(rBounds) {
            m_Bounds     = rBounds
            mnWidth      = GLsizei(rBounds.size.width  + 0.5)
            mnHeight     = GLsizei(rBounds.size.height + 0.5)
            mbIsItalic   = italic
            mnSize       = (size > 12.0) ? size : 24.0
            m_Label      = label
            mpQuad       = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
            mpText       = GLU.Text(text: m_Label, fontSize: mnSize, isItalic: mbIsItalic, width: mnWidth, height: mnHeight)
            m_Texture[1] = mpText.texture
            m_Texture[0] = HUD.Button.createTexture(rBounds.size)
        }
    }
    
    private func destruct() {
        if m_Texture[0] != 0 {
            glDeleteTextures(1, &m_Texture[0])
            
            m_Texture[0] = 0
        }
    }
    
    public func setLabel(label: HUD.Button.Label) -> Bool {
        if mpText != nil {
            let pText = GLU.Text(text: m_Label, fontSize: mnSize, isItalic: mbIsItalic, width: mnWidth, height: mnHeight)
            
            m_Label = label
            mpText = pText
            m_Texture[1] = mpText.texture
        }
        
        return m_Texture[1] != 0
    }
    
    public func draw(selected: Bool,
        position: CGPoint,
        bounds: CGRect)
    {
        glPushMatrix()
        
        glTranslatef(position.x.f, position.y.f, 0.0)
        
        glColor3f(1.0, 1.0, 1.0)
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[0])
        
        glMatrixMode(GL_TEXTURE.ui)
        
        glPushMatrix()
        
        glLoadIdentity()
        glScalef(bounds.size.width.f, bounds.size.height.f, 1.0)
        
        glMatrixMode(GL_MODELVIEW.ui)
        
        if selected {
            glColor3f(0.5, 0.5, 0.5)
        } else {
            glColor3f(0.3, 0.3, 0.3)
        }
        
        mpQuad.setIsInverted(false)
        mpQuad.setBounds(bounds)
        
        if !mpQuad.isFinalized {
            mpQuad.finalize()
        } else {
            mpQuad.update()
        }
        
        mpQuad.draw()
        
        glMatrixMode(GL_TEXTURE.ui)
        
        glPopMatrix()
        
        glMatrixMode(GL_MODELVIEW.ui)
        
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, 0)
        
        glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        glEnable(GL_TEXTURE_2D.ui)
        
        glBindTexture(GL_TEXTURE_2D.ui, m_Texture[1])
        
        if selected {
            glColor3f(0.4, 0.7, 1.0)
        } else {
            glColor3f(0.85, 0.2, 0.2)
        }
        
        glTranslatef(0.0, -10.0, 0.0)
        
        mpQuad.setIsInverted(true)
        mpQuad.setBounds(bounds)
        
        mpQuad.update()
        mpQuad.draw()
        
        glTranslatef(0.0, 10.0, 0.0)
        
        glColor3f(1.0, 1.0, 1.0)
        
        glBindTexture(GL_TEXTURE_2D.ui, 0)
        
        glDisable(GL_TEXTURE_2D.ui)
        
        glPopMatrix()
    }
}