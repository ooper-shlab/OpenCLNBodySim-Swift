//
//  HUDMeterImage.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: HUDMeterImage.h
     File: HUDMeterImage.mm
 Abstract:
 Utility class for generating and manging an OpenGl based 2D meter.

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
    
    //    namespace Meter
    public struct Meter {
        //enum HUDTextureTypes
        static let Background = 0
        static let Needle = 1
        static let Legend = 2
        static let Max = 3
        
        typealias Hash = [String: GLU.Text]
        
        public class Image {
            deinit {destruct()}
            
            private var m_Texture: [GLuint] = [0, 0, 0]
            private var mnWidth: GLsizei = 0
            private var mnHeight: GLsizei = 0
            private var mnMax: Int = 0
            private var mnLimit: GLdouble = 0.0
            private var mnValue: GLdouble = 0.0
            private var mnSmooth: GLdouble = 0.0
            private var m_Bounds: [CGRect] = [CGRect(), CGRect(), CGRect()]
            private var m_Legend: String = ""
            private var m_Hash: Hash = [:]
            private var mpLegend: GLU.Text? = nil
            private var mpQuad: GLU.Quad? = nil
        }
    }
}

//MARK: -
//MARK: Private - Utilities

import OpenGL.GL

//MARK: -
//MARK: Private - Utilities

extension HUD {
    private static func Integer2String(i: GLuint) -> String {
        
        return String(format: "%u", i)
    }
    
    private static func emplaceTextureWithLabel(nKey: GLuint, inout _ rHash: HUD.Meter.Hash) -> GLuint {
        var nTexture: GLuint = 0
        
        let key = Integer2String(nKey)
        
        var pValue: GLU.Text? = nil
        
        if let pIter = rHash[key] {
            pValue = pIter
        } else {
            pValue = GLU.Text(text: key, fontSize: 52.0, isItalic: true, width: GLsizei(ValueWidth), height: GLsizei(ValueHeight))
            
            rHash[key] = pValue
        }
        
        nTexture = pValue!.texture
        
        return nTexture
    }
    
    private static func drawMark(pContext: CGContext,
        _ rOrigin: CGPoint,
        _ rText: String,
        _ rFont: String,
        _ nFontSize: CGFloat,
        _ nTextAlign: CTTextAlignment)
    {
        let pFrame = CT.Frame(text: rText, font: rFont, fontSize: nFontSize, origin: rOrigin, textAlign: nTextAlign)
        
        pFrame.draw(pContext)
        
    }
    
    private static func drawMarks(pContext: CGContext,
        _ center: CGPoint,
        _ iMax: Int,
        _ needle: CGFloat,
        _ fontSize: CGFloat,
        _ font: String,
        _ textAlign: CTTextAlignment)
    {
        let radial = 0.82 * needle
        var angle: CGFloat = 0.0
        
        var delta = CGPoint()
        var origin = CGPoint()
        var coord = CGPoint()
        
        var i: size_t = 0
        
        let iDelta = iMax / Ticks
        
        for var i = 0; i <= iMax; i += iDelta {
            let text = String(i)
            
            // hardcoded text centering for this font size
            
            if i > 199 {
                delta.x = -18.0
            } else if i > 99 {
                delta.x = -17.0
            } else if i > 0 {
                delta.x = -14.0
            } else {
                delta.x = -12.0
            }
            
            delta.y = -6.0
            
            angle = GLM.k4PiDiv3.g * i.g / iMax.g - GLM.kPiDiv6.g
            
            coord.x = radial * cos(angle)
            coord.y = radial * sin(angle)
            
            origin.x = center.x - coord.x + delta.x
            origin.y = center.y + coord.y + delta.y
            
            HUD.drawMark(pContext, origin, text, font, fontSize, textAlign)
            
        }
    }
    
    private static func drawMarks(pContext: CGContext,
        _ width: GLsizei,
        _ height: GLsizei,
        _ max: Int)
    {
        var angle: CGFloat = 0, tick: CGFloat = 0
        var r0: CGFloat = 0, r1: CGFloat = 0, r2: CGFloat = 0, r3: CGFloat = 0
        var start = 0, end = 0, section = 0
        
        let center = CGPointMake(CenterX.g * CGFloat(width),
            CenterY.g * CGFloat(height))
        
        let redline = HUD.Ticks.g * HUD.SubTicks.g * 0.8
        let radius  = 0.5 * CGFloat(width > height ? width : height)
        
        let needle  = radius * 0.85
        
        for section in 0..<2 {
            start = section != 0 ? Int(redline) + 1 : 0
            end   = section != 0 ? HUD.Ticks * HUD.SubTicks : Int(redline)
            
            if section != 0 {
                CGContextSetRGBStrokeColor(pContext, 1.0, 0.1, 0.1, 1.0)
            } else {
                CGContextSetRGBStrokeColor(pContext, 0.9, 0.9, 1.0, 1.0)
            }
            
            // inner tick ring
            r0 = 0.97 * needle
            r1 = 1.04 * needle
            r2 = 1.00 * needle
            r3 = 1.01 * needle
            
            for i in start...end {
                tick  = CGFloat(i) / (SubTicks.g * Ticks.g)
                angle = GLM.k4PiDiv3.g * tick  -  GLM.kPiDiv6.g
                
                let c = cos(angle)
                let s = sin(angle)
                
                if i % SubTicks != 0 {
                    CGContextMoveToPoint(pContext, center.x - r0 * c, center.y + r0 * s)
                    CGContextAddLineToPoint(pContext, center.x - r1 * c, center.y + r1 * s)
                } else {
                    CGContextMoveToPoint(pContext, center.x - r2 * c, center.y + r2 * s)
                    CGContextAddLineToPoint(pContext, center.x - r3 * c, center.y + r3 * s)
                }
            }
            
            CGContextSetLineWidth(pContext, 2.0)
            CGContextStrokePath(pContext)
            
            // outer tick ring
            start = (start / SubTicks) + section
            end   = end / SubTicks
            
            r0 = 1.05 * needle
            r1 = 1.14 * needle
            
            for i in start...end {
                tick  = CGFloat(i) / Ticks.g
                angle = GLM.k4PiDiv3.g * tick - GLM.kPiDiv6.g
                
                let c = cos(angle)
                let s = sin(angle)
                
                CGContextMoveToPoint(pContext, center.x - r0 * c, center.y + r0 * s)
                CGContextAddLineToPoint(pContext, center.x - r1 * c, center.y + r1 * s)
            }
            
            CGContextSetLineWidth(pContext, 3.0)
            CGContextStrokePath(pContext)
        }
        
        HUD.drawMarks(pContext,
            center,
            max,
            needle,
            18.0,
            "Helvetica-Bold",
            .TextAlignmentCenter)
    }
    
    private static func acquireShadowWithColor(pContext: CGContext,
        _ offset: CGSize,
        _ blur: CGFloat,
        _ pColors: [CGFloat])
    {
        if let pShadowColor = CGColorCreateGenericRGB(pColors[0],
            pColors[1],
            pColors[2],
            pColors[3])
        {
            
            CGContextSetShadowWithColor(pContext,
                offset,
                blur,
                pShadowColor)
            
        }
    }
    
    private static func shadowAcquireWithColor(pContext: CGContext) {
        let offset = CGSizeMake(0.0, CGFloat(HUD.Offscreen))
        let colors: [CGFloat] = [0.5, 0.5, 1.0, 0.7]
        
        HUD.acquireShadowWithColor(pContext, offset, 48.0, colors)
    }
    
    private static func backgroundShadowAcquireWithColor(pContext: CGContext) {
        let offset = CGSizeMake(0.0, 1.0)
        let colors: [CGFloat] = [0.7, 0.7, 1.0, 0.9]
        
        acquireShadowWithColor(pContext, offset, 6.0, colors)
    }
    
    private static func needleShadowAcquireWithColor(pContext: CGContext) {
        let offset    = CGSizeMake(0.0, 1.0)
        let colors: [CGFloat] = [0.0, 0.0, 0.5, 0.7]
        
        acquireShadowWithColor(pContext, offset, 6.0, colors)
    }
    
    private static func backgroundCreateTexture(width: GLsizei,
        _ height: GLsizei,
        _ max: Int) -> GLuint
    {
        var texture: GLuint = 0
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        glGenTextures(1, &texture)
        
        if texture != 0 {
            if let pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB) {
                
                let bpp = size_t(width) * size_t(SamplesPerPixel)
                
                if let pContext = CGBitmapContextCreate(nil,
                    UInt(width),
                    UInt(height),
                    UInt(BitsPerComponent),
                    bpp,
                    pColorspace,
                    BitmapInfo)
                {
                    
                    let cx = CGFloat(CenterX) * CGFloat(width)
                    let cy = CGFloat(CenterY) * CGFloat(height)
                    
                    let radius = 0.5 * CGFloat(width > height ? width : height)
                    let needle = radius * 0.85
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0, CGFloat(height))
                    CGContextScaleCTM(pContext, 1.0, -1.0)
                    CGContextClearRect(pContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)))
                    CGContextSetRGBFillColor(pContext, 0.0, 0.0, 0.0, 0.7)
                    CGContextAddArc(pContext, cx, cy, radius, 0.0, GLM.kTwoPi.g, false)
                    CGContextFillPath(pContext)
                    
                    let count: size_t = 2
                    var locations: [CGFloat] = [0.0, 1.0]
                    var components: [CGFloat] = [
                        1.0, 1.0, 1.0, 0.5,  // Start color
                        0.0, 0.0, 0.0, 0.0, // End color
                    ]
                    
                    if let pGradient = CGGradientCreateWithColorComponents(pColorspace,
                        components,
                        locations,
                        count)
                    {
                        CGContextSaveGState(pContext)
                        
                        CGContextAddArc(pContext, cx, cy, radius, 0.0, GLM.kTwoPi.g, false)
                        CGContextAddArc(pContext, cx, cy, needle * 1.05, 0.0, GLM.kTwoPi.g, false)
                        CGContextEOClip(pContext)
                        
                        CGContextDrawRadialGradient(pContext,
                            pGradient,
                            CGPointMake(cx, cy),
                            radius * 1.01,
                            CGPointMake(cx, cy * 0.96),
                            radius * 0.98,
                            0)
                        // bottom rim light
                        CGContextDrawRadialGradient(pContext,
                            pGradient,
                            CGPointMake(cx, cy),
                            radius * 1.01,
                            CGPointMake(cx, cy * 1.04),
                            radius * 0.98,
                            0)
                        // top bevel
                        CGContextDrawRadialGradient(pContext,
                            pGradient,
                            CGPointMake(cx, cy * 2.2),
                            radius * 0.2,
                            CGPointMake(cx, cy),
                            radius,
                            0)
                        
                        CGContextRestoreGState(pContext)
                        
                        // bottom bevel
                        CGContextSaveGState(pContext)
                        
                        CGContextAddArc(pContext, cx, cy, needle * 1.05, 0.0, GLM.kTwoPi.g, false)
                        CGContextAddArc(pContext, cx, cy, needle * 0.96, 0.0, GLM.kTwoPi.g, false)
                        CGContextEOClip(pContext)
                        
                        CGContextDrawRadialGradient(pContext,
                            pGradient,
                            CGPointMake(cx, -0.5 * cy),
                            radius * 0.2,
                            CGPointMake(cx, cy),
                            radius,
                            0)
                        
                        CGContextRestoreGState(pContext)
                        
                    }
                    
                    // top rim light
                    
                    CGContextSetRGBFillColor(pContext, 0.9, 0.9, 1.0, 1.0)
                    CGContextSetRGBStrokeColor(pContext, 0.9, 0.9, 1.0, 1.0)
                    CGContextSetLineCap(pContext, kCGLineCapRound)
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0, CGFloat(Offscreen) - 10.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    CGContextTranslateCTM(pContext, 0.0, 20.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    CGContextTranslateCTM(pContext, -10.0, -10.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    CGContextTranslateCTM(pContext, 20.0, 0.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    CGContextTranslateCTM(pContext, -10.0, CGFloat(-HUD.Offscreen))
                    
                    // draw real content
                    HUD.backgroundShadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, texture)
                    
                    let pData  = CGBitmapContextGetData(pContext)
                    
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
        }
        
        glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        return texture
    }
    
    private static func angleForValue(var val: GLdouble,
        _ max: Int) -> GLdouble
    {
        
        if val < 0.0 {
            val = 0.0
        }
        
        var max_f = GLdouble(max)
        
        if val > max_f * 1.05 {
            val = max_f * 1.05  //###
        }
        
        return  GLM.kPiDiv6 - GLM.k4PiDiv3 * val / max_f
    }
    
    private static func needleDraw(pContext: CGContext,
        _ width: GLsizei,
        _ height: GLsizei,
        _ angle: CGFloat)
    {
        let cx     = HUD.CenterX.g * CGFloat(width)
        let cy     = HUD.CenterY.g * CGFloat(height)
        let dx     = -cos(angle)
        let dy     = -sin(angle)
        let hdx    = 0.5 * dx
        let hdy    = 0.5 * dy
        let radius = 0.5 * CGFloat(width > height ? width : height)
        let needle = radius * 0.85
        
        CGContextMoveToPoint(pContext,
            cx + needle * dx - hdy,
            cy + needle * dy + hdx)
        
        CGContextAddLineToPoint(pContext,
            cx + needle * dx + hdy,
            cy + needle * dy - hdx)
        
        CGContextAddLineToPoint(pContext,
            cx - HUD.NeedleThickness.g * (dx + hdy),
            cy - HUD.NeedleThickness.g * (dy - hdx))
        
        CGContextAddArc(pContext,
            cx - HUD.NeedleThickness.g * dx,
            cy - HUD.NeedleThickness.g * dy,
            0.5 * HUD.NeedleThickness.g,
            angle - GLM.kHalfPi.g,
            angle + GLM.kHalfPi.g,
            false)
        
        CGContextAddLineToPoint(pContext,
            cx - HUD.NeedleThickness.g * (dx - hdy),
            cy - HUD.NeedleThickness.g * (dy + hdx))
        
        CGContextFillPath(pContext)
    }
    
    private static func needleCreateTexture(width: GLsizei, _ height: GLsizei) -> GLuint {
        var texture: GLuint = 0
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        glGenTextures(1, &texture)
        
        if texture != 0 {
            let pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
            
            if pColorspace != nil {
                let bpp = width.ul * HUD.SamplesPerPixel.ul
                
                let pContext = CGBitmapContextCreate(nil,
                    width.ul,
                    height.ul,
                    HUD.BitsPerComponent.ul,
                    bpp,
                    pColorspace,
                    HUD.BitmapInfo)
                
                if pContext != nil {
                    let angle: CGFloat  = 0.0
                    let cx     = HUD.CenterX.g * width.g
                    let cy     = HUD.CenterY.g * height.g
                    
                    CGContextTranslateCTM(pContext, 0.0, height.g)
                    CGContextScaleCTM(pContext, 1.0, -1.0)
                    CGContextClearRect(pContext, CGRectMake(0.0, 0.0, width.g, height.g))
                    
                    CGContextSaveGState(pContext)
                    let radius = 0.5 * (width > height ? width : height).g
                    let needle = radius * 0.85
                    
                    let count = 2
                    
                    let locations: [CGFloat] = [0.0, 1.0]
                    let components: [CGFloat] = [
                        0.7, 0.7, 1.0, 0.7,  // Start color
                        0.0, 0.0, 0.0, 0.0 // End color
                    ]
                    
                    CGContextAddArc(pContext, cx, cy, needle * 1.05, 0.0, GLM.kTwoPi.g, false)
                    CGContextAddArc(pContext, cx, cy, needle * 0.96, 0.0, GLM.kTwoPi.g, false)
                    
                    CGContextEOClip(pContext)
                    
                    if let  pGradient = CGGradientCreateWithColorComponents(pColorspace,
                        components,
                        locations,
                        count.ul) {
                            // draw glow reflecting on inner bevel
                            let dx = -cos(angle) + 1.0
                            let dy = -sin(angle) + 1.0
                            
                            CGContextDrawRadialGradient(pContext,
                                pGradient,
                                CGPointMake(cx * dx, cy * dy),
                                radius * 0.1,
                                CGPointMake(cx, cy),
                                radius,
                                0)
                            
                    }
                    CGContextRestoreGState(pContext)
                    
                    CGContextSetRGBFillColor(pContext, 0.9, 0.9, 1.0, 1.0)
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0, HUD.Offscreen.g - 10.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    CGContextTranslateCTM(pContext, 0.0, 20.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    CGContextTranslateCTM(pContext, -10.0, -10.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    CGContextTranslateCTM(pContext, 20.0, 0.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    CGContextTranslateCTM(pContext, -10.0, -HUD.Offscreen.g)
                    
                    // draw real content
                    needleShadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, texture)
                    
                    let pData  = CGBitmapContextGetData(pContext)
                    
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
        }
        glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        return texture
    }
}

//MARK: -
//MARK: Public - Meter - Image

extension HUD.Meter.Image {
    public convenience init(width: GLsizei,
        height: GLsizei,
        max : Int,
        legend: String)
    {
        self.init()
        mnWidth  = width
        mnHeight = height
        mnMax    = max
        mnLimit  = GLdouble(mnMax)
        m_Legend = legend
        
        mnValue  = 0.0
        mnSmooth = 0.0
        
        mpLegend = nil
        
        m_Texture[HUD.Meter.Background] = 0
        m_Texture[HUD.Meter.Needle]     = 0
        m_Texture[HUD.Meter.Legend]     = 0
        
        let fWidth  = CGFloat(mnWidth)
        let fHeight = CGFloat(mnHeight)
        
        let fx = -0.5 * fWidth
        let fy = -0.5 * fHeight
        
        m_Bounds[0] = CGRectMake(fx, fy, fWidth, fHeight)
        
        m_Bounds[1] = CGRectMake(-0.5 * HUD.LegendWidth.g,
            -220.0,
            HUD.LegendWidth.g,
            HUD.LegendHeight.g)
        
        m_Bounds[2] = CGRectMake(-0.5 * HUD.ValueWidth.g,
            -110.0,
            HUD.ValueWidth.g,
            HUD.ValueHeight.g)
        
        mpQuad = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
    }
    
    private func destruct() {
        if m_Texture[HUD.Meter.Background] != 0 {
            glDeleteTextures(1, &m_Texture[HUD.Meter.Background])
            
            m_Texture[HUD.Meter.Background] = 0
        }
        
        if m_Texture[HUD.Meter.Needle] != 0 {
            glDeleteTextures(1, &m_Texture[HUD.Meter.Needle])
            
            m_Texture[HUD.Meter.Needle] = 0
        }
        
    }
    
    public func setTarget(target: GLdouble) {
        mnValue = target
    }
    
    public func reset() {
        mnValue  = 0.0
        mnSmooth = 0.0
    }
    
    public func update() {
        // TODO: Move to time-based
        let step = mnLimit / 60.0
        
        if abs(mnSmooth - mnValue) < step {
            mnSmooth = mnValue
        } else if mnValue > mnSmooth {
            mnSmooth += step
        } else if mnValue < mnSmooth {
            mnSmooth -= step
        }
    }
    
    private func render() {
        if m_Texture[HUD.Meter.Background] == 0 {
            m_Texture[HUD.Meter.Background] = HUD.backgroundCreateTexture(mnWidth, mnHeight, mnMax)
        }
        
        if m_Texture[HUD.Meter.Needle] == 0 {
            m_Texture[HUD.Meter.Needle] = HUD.needleCreateTexture(mnWidth, mnHeight)
        }
        
        if mpLegend == nil {
            mpLegend = GLU.Text(text: m_Legend,
                fontSize: 36.0,
                isItalic: false,
                width: GLsizei(HUD.LegendWidth),
                height: GLsizei(HUD.LegendHeight))
            
            m_Texture[HUD.Meter.Legend] = mpLegend!.texture
        }
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        glMatrixMode(GL_TEXTURE.ui)
        
        glPushMatrix()
        glLoadIdentity()
        glScalef(mnWidth.f, mnHeight.f, 1.0)
        
        mpQuad!.setIsInverted(false)
        mpQuad!.setBounds(m_Bounds[0])
        
        if !mpQuad!.isFinalized {
            mpQuad!.finalize()
        } else {
            mpQuad!.update()
        }
        
        glMatrixMode(GL_MODELVIEW.ui)
        
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[HUD.Meter.Background])
        mpQuad!.draw()
        
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[HUD.Meter.Needle])
        
        glPushMatrix()
        let angle = GLM.k180DivPi.f * HUD.angleForValue(mnSmooth, mnMax).f
        
        glRotatef(angle, 0.0, 0.0, 1.0)
        
        mpQuad!.draw()
        glPopMatrix()
        
        glMatrixMode(GL_TEXTURE.ui)
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, 0)
        glPopMatrix()
        
        glMatrixMode(GL_MODELVIEW.ui)
        glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
        
        glEnable(GL_TEXTURE_2D.ui)
        glBindTexture(GL_TEXTURE_2D.ui, m_Texture[HUD.Meter.Legend])
        mpQuad!.setIsInverted(true)
        mpQuad!.setBounds(m_Bounds[1])
        
        mpQuad!.update()
        mpQuad!.draw()
        glBindTexture(GL_TEXTURE_2D.ui, 0)
        
        let nValue = GLuint(lrint(mnSmooth))
        let nTex   = HUD.emplaceTextureWithLabel(nValue, &m_Hash)
        
        if nTex != 0 {
            glBindTexture(GL_TEXTURE_2D.ui, nTex)
            mpQuad!.setIsInverted(true)
            mpQuad!.setBounds(m_Bounds[2])
            
            mpQuad!.update()
            mpQuad!.draw()
            glBindTexture(GL_TEXTURE_2D.ui, 0)
        }
        glDisable(GL_TEXTURE_2D.ui)
    }
    
    public func draw(x: GLfloat, y: GLfloat) {
        glPushMatrix()
        glTranslatef(x, y, 0.0)
        glColor3f(1.0, 1.0, 1.0)
        
        render()
        glPopMatrix()
    }
}