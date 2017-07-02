//
//  HUDMeterImage.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility class for generating and manging an OpenGl based 2D meter.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import simd

extension HUD {
    
    //    namespace Meter
    public struct Meter {
        //enum HUDTextureTypes
        static let Background = 0
        static let Needle = 1
        static let Legend = 2
        static let Max = 3
        
        typealias Hash = [String: GLU.Text]
        
        open class Image {
            deinit {destruct()}
            
            fileprivate var m_Texture: [GLuint] = [0, 0, 0]
            fileprivate var mnWidth: GLsizei = 0
            fileprivate var mnHeight: GLsizei = 0
            fileprivate var mnMax: Int = 0
            fileprivate var mnLimit: GLdouble = 0.0
            fileprivate var mnValue: GLdouble = 0.0
            fileprivate var mnSmooth: GLdouble = 0.0
            fileprivate var m_Bounds: [CGRect] = [CGRect(), CGRect(), CGRect()]
            fileprivate var m_Legend: String = ""
            fileprivate var m_Hash: Hash = [:]
            fileprivate var mpLegend: GLU.Text? = nil
            fileprivate var mpQuad: GLU.Quad? = nil
        }
    }
}

//MARK: -
//MARK: Private - Utilities

import OpenGL.GL

extension HUD {
    
    //MARK: -
    //MARK: Private - Constants
    
    private static let Center = double2(0.5, 0.5)
    
    //MARK: -
    //MARK: Private - Utilities
    
    private static func Integer2String(_ i: GLuint) -> String {
        
        return String(i)
    }
    
    fileprivate static func emplaceTextureWithLabel(_ nKey: GLuint,
        _ rHash: inout HUD.Meter.Hash) -> GLuint
    {
        var nTexture: GLuint = 0
        
        var pValue: GLU.Text? = nil
        
        let key = Integer2String(nKey)
        
        if let pIter = rHash[key] {
            pValue = pIter
        } else {
            pValue = GLU.Text(key, 52.0, true, GLsizei(ValueWidth), GLsizei(ValueHeight))
            
            rHash[key] = pValue
        }
        
        nTexture = pValue!.texture
        
        return nTexture
    }
    
    private static func drawMark(_ pContext: CGContext,
        _ rOrigin: CGPoint,
        _ rText: String,
        _ rFont: String,
        _ nFontSize: CGFloat,
        _ nTextAlign: CTTextAlignment)
    {
        let pFrame = CT.Frame(rText, rFont, nFontSize, rOrigin, nTextAlign)
        
        pFrame.draw(pContext)
        
    }
    
    private static func drawMarks(_ pContext: CGContext,
        _ center: CGPoint,
        _ iMax: Int,
        _ needle: CGFloat,
        _ fontSize: CGFloat,
        _ font: String,
        _ textAlign: CTTextAlignment)
    {
        let radial: GLdouble = 0.82 * needle.d
        var angle: GLdouble = 0.0
        
        var origin = CGPoint()
        
        var cos: GLdouble = 0.0
        var sin: GLdouble = 0.0
        
        var vCoord  = double2()
        var vDelta  = double2()
        var vCenter = double2()
        var vOrigin = double2()
        
        let iDelta = iMax / Ticks
        
        for i in stride(from: 0, to: iMax, by: iDelta) {
            let text = String(i)
            
            // hardcoded text centering for this font size
            if i > 999 {
                vDelta.x = -24.0
            } else if i > 99 {
                vDelta.x = -18.0
            } else if i > 0 {
                vDelta.x = -14.0
            } else {
                vDelta.x = -12.0
            }
            
            vDelta.y = -6.0
            
            angle = GLM.k4PiDiv3 * i.d / iMax.d - GLM.kPiDiv6
            
            __sincos(angle, &sin, &cos)
            
            vCoord = double2(-cos, sin)
            vCenter = double2(center.x.d, center.y.d)
            
            vOrigin = vCenter + vDelta + radial * vCoord;
            
            origin = CGPoint(x: vOrigin.x.g, y: vOrigin.y.g);
            
            HUD.drawMark(pContext, origin, text, font, fontSize, textAlign)
            
        }
    }
    
    private static func drawMarks(_ pContext: CGContext,
        _ width: GLsizei,
        _ height: GLsizei,
        _ max: Int)
    {
        var start = 0, end = 0
        
        var angle: GLdouble = 0, cos: GLdouble = 0, sin: GLdouble = 0, tick: GLdouble = 0
        
        let redline = HUD.Ticks.d * HUD.SubTicks.d * 0.8
        let radius  = 0.5 * GLdouble(width > height ? width : height)
        let needle  = radius * 0.85
        
        var c = double2(GLdouble(width), GLdouble(height))
        
        c *= HUD.Center
        
        var u = double2()
        var v = double2()
        
        let q = double4(c.x, c.x, c.y, c.y)
        var r = double4()
        
        for section in 0..<2 {
            start = section != 0 ? Int(redline) + 1 : 0
            end   = section != 0 ? HUD.Ticks * HUD.SubTicks : Int(redline)
            
            if section != 0 {
                pContext.setStrokeColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
            } else {
                pContext.setStrokeColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
            }
            
            // inner tick ring
            r.x = 0.97 * needle
            r.y = 1.04 * needle
            r.z = 1.00 * needle
            r.w = 1.01 * needle
            
            for i in start...end {
                tick  = GLdouble(i) / (SubTicks.d * Ticks.d)
                angle = GLM.k4PiDiv3 * tick  -  GLM.kPiDiv6
                
                __sincos(angle, &sin, &cos)
                
                if i % SubTicks != 0 {
                    u = double2(q.x, q.y) - cos * double2(r.x, r.y)
                    v = double2(q.z, q.w) + sin * double2(r.x, r.y)
                    
                    pContext.move(to: CGPoint(x: u.x.g, y: v.x.g))
                    pContext.addLine(to: CGPoint(x: u.y.g, y: v.y.g))
                } else {
                    u = double2(q.x, q.y) - cos * double2(r.z, r.w)
                    v = double2(q.z, q.w) + sin * double2(r.z, r.w)
                    
                    pContext.move(to: CGPoint(x: u.x.g, y: v.x.g))
                    pContext.addLine(to: CGPoint(x: u.y.g, y: v.y.g))
                }
            }
            
            pContext.setLineWidth(2.0)
            pContext.strokePath()
            
            // outer tick ring
            start = (start / SubTicks) + section
            end   = end / SubTicks
            
            r.x = 1.05 * needle
            r.y = 1.14 * needle
            
            for i in start...end {
                tick  = GLdouble(i) / Ticks.d
                angle = GLM.k4PiDiv3 * tick - GLM.kPiDiv6
                
                __sincos(angle, &sin, &cos)
                
                u = double2(q.x, q.y) - cos * double2(r.x, r.y)
                v = double2(q.z, q.w) + sin * double2(r.x, r.y)
                
                pContext.move(to: CGPoint(x: u.x.g, y: v.x.g))
                pContext.addLine(to: CGPoint(x: u.y.g, y: v.y.g))
            }
            
            pContext.setLineWidth(3.0)
            pContext.strokePath()
        }
        
        let center = CGPoint(x: c.x.g, y: c.y.g)
        
        HUD.drawMarks(pContext,
            center,
            max,
            needle.g,
            18.0,
            "Helvetica-Bold",
            .center)
    }
    
    private static func acquireShadowWithColor(_ pContext: CGContext,
        _ offset: CGSize,
        _ blur: CGFloat,
        _ pColors: [CGFloat])
    {
        let pShadowColor = CGColor(red: pColors[0],
            green: pColors[1],
            blue: pColors[2],
            alpha: pColors[3])
        
        pContext.setShadow(offset: offset,
            blur: blur,
            color: pShadowColor)
        
    }
    
    private static func shadowAcquireWithColor(_ pContext: CGContext) {
        let offset = CGSize(width: 0.0, height: HUD.Offscreen.g)
        let colors: [CGFloat] = [0.5, 0.5, 1.0, 0.7]
        
        HUD.acquireShadowWithColor(pContext, offset, 48.0, colors)
    }
    
    private static func backgroundShadowAcquireWithColor(_ pContext: CGContext) {
        let offset = CGSize(width: 0.0, height: 1.0)
        let colors: [CGFloat] = [0.7, 0.7, 1.0, 0.9]
        
        acquireShadowWithColor(pContext, offset, 6.0, colors)
    }
    
    private static func needleShadowAcquireWithColor(_ pContext: CGContext) {
        let offset    = CGSize(width: 0.0, height: 1.0)
        let colors: [CGFloat] = [0.0, 0.0, 0.5, 0.7]
        
        acquireShadowWithColor(pContext, offset, 6.0, colors)
    }
    
    fileprivate static func backgroundCreateTexture(_ width: GLsizei,
        _ height: GLsizei,
        _ max: Int) -> GLuint
    {
        var texture: GLuint = 0
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        do {
            glGenTextures(1, &texture)
            
            if texture != 0 {
                let pColorspace = CGColorSpaceCreateDeviceRGB()
                
                let bpp = size_t(width) * size_t(SamplesPerPixel)
                
                if let pContext = CGContext(data: nil,
                                            width: width.l,
                                            height: height.l,
                                            bitsPerComponent: BitsPerComponent,
                                            bytesPerRow: bpp,
                                            space: pColorspace,
                                            bitmapInfo: BitmapInfo)
                {
                    var c = double2(GLdouble(width), GLdouble(height))
                    
                    c *= HUD.Center
                    
                    let radius = 0.5 * GLdouble(width > height ? width : height)
                    let needle = radius * 0.85
                    
                    // background
                    pContext.translateBy(x: 0.0, y: height.g)
                    pContext.scaleBy(x: 1.0, y: -1.0)
                    pContext.clear(CGRect(x: 0, y: 0, width: width.g, height: height.g))
                    pContext.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
                    pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: radius.g, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                    pContext.fillPath()
                    
                    let count: size_t = 2
                    
                    let locations: [CGFloat] = [0.0, 1.0]
                    let components: [CGFloat] = [
                        1.0, 1.0, 1.0, 0.5,  // Start color
                        0.0, 0.0, 0.0, 0.0, // End color
                    ]
                    
                    if let pGradient = CGGradient(colorSpace: pColorspace,
                                                  colorComponents: components,
                                                  locations: locations,
                                                  count: count)
                    {
                        let center = CGPoint(x: c.x.g, y: c.y.g)
                        
                        pContext.saveGState()
                        do {
                            pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: radius.g, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                            pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: needle.g * 1.05, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                            pContext.clip(using: .evenOdd)
                            
                            pContext.drawRadialGradient(pGradient,
                                                        startCenter: center,
                                                        startRadius: radius.g * 1.01,
                                                        endCenter: CGPoint(x: c.x.g, y: c.y.g * 0.96),
                                                        endRadius: radius.g * 0.98,
                                                        options: [])
                            // bottom rim light
                            pContext.drawRadialGradient(pGradient,
                                                        startCenter: center,
                                                        startRadius: radius.g * 1.01,
                                                        endCenter: CGPoint(x: c.x.g, y: c.y.g * 1.04),
                                                        endRadius: radius.g * 0.98,
                                                        options: [])
                            // top bevel
                            pContext.drawRadialGradient(pGradient,
                                                        startCenter: CGPoint(x: c.x.g, y: c.y.g * 2.2),
                                                        startRadius: radius.g * 0.2,
                                                        endCenter: center,
                                                        endRadius: radius.g,
                                                        options: [])
                        }
                        pContext.restoreGState()
                        
                        // bottom bevel
                        pContext.saveGState()
                        do {
                            pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: needle.g * 1.05, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                            pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: needle.g * 0.96, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                            pContext.clip(using: .evenOdd)
                            
                            pContext.drawRadialGradient(pGradient,
                                                        startCenter: CGPoint(x: c.x.g, y: -0.5 * c.y.g),
                                                        startRadius: radius.g * 0.2,
                                                        endCenter: center,
                                                        endRadius: radius.g,
                                                        options: [])
                        }
                        pContext.restoreGState()
                        
                    }
                    
                    // top rim light
                    
                    pContext.setFillColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
                    pContext.setStrokeColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
                    pContext.setLineCap(.round)
                    
                    // draw several glow passes, with the content offscreen
                    pContext.translateBy(x: 0.0, y: CGFloat(Offscreen) - 10.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    pContext.translateBy(x: 0.0, y: 20.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    pContext.translateBy(x: -10.0, y: -10.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    pContext.translateBy(x: 20.0, y: 0.0)
                    
                    HUD.shadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    pContext.translateBy(x: -10.0, y: CGFloat(-HUD.Offscreen))
                    
                    // draw real content
                    HUD.backgroundShadowAcquireWithColor(pContext)
                    
                    HUD.drawMarks(pContext, width, height, max)
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, texture)
                    
                    let pData  = pContext.data
                    
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
    
    fileprivate static func angleForValue(_ _val: GLdouble,
        _ max: Int) -> GLdouble
    {
        
        var val = _val
        if val < 0.0 {
            val = 0.0
        }
        
        let max_f = GLdouble(max)
        
        if val > max_f * 1.05 {
            val = max_f * 1.05  //###
        }
        
        return  GLM.kPiDiv6 - GLM.k4PiDiv3 * val / max_f
    }
    
    private static func needleDraw(_ pContext: CGContext,
        _ width: GLsizei,
        _ height: GLsizei,
        _ angle: GLdouble)
    {
        var c = double2(GLdouble(width), GLdouble(height))
        
        c *= Center;
        
        var cos: GLdouble = 0.0
        var sin: GLdouble = 0.0
        
        __sincos(angle, &sin, &cos);
        
        var d  = double2(cos, sin)
        var hd = -0.5 * d;
        
        let radius = 0.5 * GLdouble(width > height ? width : height)
        let needle = radius * 0.85
        
        var p = c - needle * d
        
        pContext.move(to: CGPoint(x: p.x.g - hd.y.g, y: p.y.g + hd.x.g))
        pContext.addLine(to: CGPoint(x: p.x.g + hd.y.g, y: p.y.g - hd.x.g))
        
        d  *= NeedleThickness.d
        hd *= NeedleThickness.d
        
        p = c + d;
        
        pContext.addLine(to: CGPoint(x: p.x.g - hd.y.g, y: p.y.g + hd.x.g))
        
        pContext.addArc(center: CGPoint(x: p.x.g, y: p.y.g), radius: 0.5 * NeedleThickness.g, startAngle: angle.g - GLM.kHalfPi.g, endAngle: angle.g + GLM.kHalfPi.g, clockwise: false)
        
        pContext.addLine(to: CGPoint(x: p.x.g + hd.y.g, y: p.y.g - hd.x.g))
        
        pContext.fillPath()
    }
    
    fileprivate static func needleCreateTexture(_ width: GLsizei, _ height: GLsizei) -> GLuint {
        var texture: GLuint = 0
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
        do {
            glGenTextures(1, &texture)
            
            if texture != 0 {
                let pColorspace = CGColorSpaceCreateDeviceRGB()
                
                let bpp = width.l * HUD.SamplesPerPixel
                
                if let pContext = CGContext(data: nil,
                                            width: width.l,
                                            height: height.l,
                                            bitsPerComponent: HUD.BitsPerComponent,
                                            bytesPerRow: bpp,
                                            space: pColorspace,
                                            bitmapInfo: HUD.BitmapInfo)
                {
                    
                    let angle: GLdouble  = 0.0
                    
                    var c = double2(GLdouble(width), GLdouble(height))
                    
                    c *= Center
                    
                    pContext.translateBy(x: 0.0, y: height.g)
                    pContext.scaleBy(x: 1.0, y: -1.0)
                    pContext.clear(CGRect(x: 0.0, y: 0.0, width: width.g, height: height.g))
                    
                    pContext.saveGState()
                    do {
                        let radius = 0.5 * (width > height ? width : height).d
                        let needle = radius * 0.85
                        
                        let count = 2
                        
                        let locations: [CGFloat] = [0.0, 1.0]
                        let components: [CGFloat] = [
                            0.7, 0.7, 1.0, 0.7,  // Start color
                            0.0, 0.0, 0.0, 0.0 // End color
                        ]
                        
                        pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: needle.g * 1.05, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                        pContext.addArc(center: CGPoint(x: c.x.g, y: c.y.g), radius: needle.g * 0.96, startAngle: 0.0, endAngle: GLM.kTwoPi.g, clockwise: false)
                        
                        pContext.clip(using: .evenOdd)
                        
                        if let  pGradient = CGGradient(colorSpace: pColorspace,
                                                       colorComponents: components,
                                                       locations: locations,
                                                       count: count)
                        {
                            // draw glow reflecting on inner bevel
                            var cos: GLdouble = 0.0
                            var sin: GLdouble = 0.0
                            
                            __sincos(angle, &sin, &cos);
                            
                            var d = double2(cos, sin)
                            
                            d = c * (double2(1.0, 1.0) - d);
                            
                            pContext.drawRadialGradient(pGradient,
                                                        startCenter: CGPoint(x: d.x.g, y: d.y.g),
                                                        startRadius: 0.1 * radius.g,
                                                        endCenter: CGPoint(x: c.x.g, y: c.y.g),
                                                        endRadius: radius.g,
                                                        options: [])
                            
                        }
                    }
                    pContext.restoreGState()
                    
                    pContext.setFillColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
                    
                    // draw several glow passes, with the content offscreen
                    pContext.translateBy(x: 0.0, y: HUD.Offscreen.g - 10.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    pContext.translateBy(x: 0.0, y: 20.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    pContext.translateBy(x: -10.0, y: -10.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    pContext.translateBy(x: 20.0, y: 0.0)
                    
                    shadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    pContext.translateBy(x: -10.0, y: -HUD.Offscreen.g)
                    
                    // draw real content
                    needleShadowAcquireWithColor(pContext)
                    
                    needleDraw(pContext, width, height, angle)
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, texture)
                    
                    let pData  = pContext.data
                    
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
        do {
            mnWidth  = width
            mnHeight = height
            mnMax    = max
            mnLimit  = GLdouble(mnMax)
            m_Legend = legend
            
            mnValue  = 0.0
            mnSmooth = 0.0
            
            let fWidth  = CGFloat(mnWidth)
            let fHeight = CGFloat(mnHeight)
            
            let fx = -0.5 * fWidth
            let fy = -0.5 * fHeight
            
            m_Bounds[0] = CGRect(x: fx, y: fy, width: fWidth, height: fHeight)
            
            m_Bounds[1] = CGRect(x: -0.5 * HUD.LegendWidth.g,
                y: -220.0,
                width: HUD.LegendWidth.g,
                height: HUD.LegendHeight.g);
            
            m_Bounds[2] = CGRect(x: -0.5 * HUD.ValueWidth.g,
                y: -110.0,
                width: HUD.ValueWidth.g,
                height: HUD.ValueHeight.g);
            
            mpQuad = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
            
            m_Texture[HUD.Meter.Background] = HUD.backgroundCreateTexture(mnWidth, mnHeight, mnMax)
            m_Texture[HUD.Meter.Needle]     = HUD.needleCreateTexture(mnWidth, mnHeight)
            
            mpLegend = GLU.Text(m_Legend,
                36.0,
                false,
                GLsizei(HUD.LegendWidth),
                GLsizei(HUD.LegendHeight))
            
            m_Texture[HUD.Meter.Legend] = mpLegend!.texture
            //        } catch let ba {
            //            NSLog(">> ERROR: Failed an OpenGL text label for meter's legend: \"\(ba)\"")
        }
    }
    
    fileprivate func destruct() {
        if m_Texture[HUD.Meter.Background] != 0 {
            glDeleteTextures(1, &m_Texture[HUD.Meter.Background])
            
            m_Texture[HUD.Meter.Background] = 0
        }
        
        if m_Texture[HUD.Meter.Needle] != 0 {
            glDeleteTextures(1, &m_Texture[HUD.Meter.Needle])
            
            m_Texture[HUD.Meter.Needle] = 0
        }
        
    }
    
    public var target: GLdouble {
        get {
            return mnValue
        }
        set {
            mnValue = newValue
        }
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
    
    public func draw(_ x: GLfloat, _ y: GLfloat) {
        glBlendFunc(GL_ONE.ui, GL_ONE_MINUS_SRC_ALPHA.ui)
        glEnable(GL_BLEND.ui)
        do {
            let mv1 = GLM.modelview(true)
            
            let translate = GLM.translate(x, y, 0.0)
            
            GLM.load(true, mv1 * translate);
            
            glColor3f(1.0, 1.0, 1.0)
            
            glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
            do {
                glMatrixMode(GL_TEXTURE.ui)
                
                let tm = GLM.texture(true);
                
                GLM.load(true, GLM.scale(mnWidth.f, mnHeight.f, 1.0))
                
                mpQuad!.setIsInverted(false)
                mpQuad!.setBounds(m_Bounds[0])
                
                if !mpQuad!.isFinalized {
                    mpQuad!.finalize()
                } else {
                    mpQuad!.update()
                }
                
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[HUD.Meter.Background])
                do {
                    mpQuad!.draw()
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[HUD.Meter.Needle])
                    
                    glMatrixMode(GL_MODELVIEW.ui)
                    
                    let mv2 = GLM.modelview(false);
                    
                    let angle = GLM.k180DivPi.f * HUD.angleForValue(mnSmooth, mnMax).f
                    
                    let rotate = GLM.rotate(angle, 0.0, 0.0, 1.0)
                    
                    GLM.load(false, rotate * mv2)
                    
                    mpQuad!.draw()
                    
                    GLM.load(false, mv2)
                }
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, 0)
                
                glMatrixMode(GL_TEXTURE.ui)
                
                GLM.load(true, tm)
            }
            glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
            
            glEnable(GL_TEXTURE_2D.ui)
            do {
                glBindTexture(GL_TEXTURE_2D.ui, m_Texture[HUD.Meter.Legend])
                do {
                    mpQuad!.setIsInverted(true)
                    mpQuad!.setBounds(m_Bounds[1])
                    
                    mpQuad!.update()
                    mpQuad!.draw()
                }
                glBindTexture(GL_TEXTURE_2D.ui, 0)
                
                let nValue = GLuint(lrint(mnSmooth));
                let nTex: GLuint   = HUD.emplaceTextureWithLabel(nValue, &m_Hash);
                
                if nTex != 0 {
                    glBindTexture(GL_TEXTURE_2D.ui, nTex)
                    do {
                        mpQuad!.setIsInverted(true)
                        mpQuad!.setBounds(m_Bounds[2])
                        
                        mpQuad!.update();
                        mpQuad!.draw()
                    }
                    glBindTexture(GL_TEXTURE_2D.ui, 0)
                }
            }
            glDisable(GL_TEXTURE_2D.ui)
            
            glMatrixMode(GL_MODELVIEW.ui)
            
            GLM.load(true, mv1)
        }
        glDisable(GL_BLEND.ui)
    }
}
