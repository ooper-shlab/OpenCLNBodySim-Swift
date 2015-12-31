//
//  HUDButton.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility class for generating a button in an OpenGL view.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension HUD {
    public struct Button {
        public typealias Label = String
        public typealias Position = CGPoint
        public typealias Bounds = CGRect
        
        //MARK: -
        //MARK: Private - Enumerated Types
        
        enum Tracking {
            case Nothing
            case Pressed
            case Unpressed
        }
        
        public class Image {
            
            deinit {destruct()}
            
            private var mbIsItalic: Bool = false
            private var m_Texture: [GLuint] = [0, 0]
            private var mnSize: GLdouble = 0
            private var mnWidth: GLsizei = 0
            private var mnHeight: GLsizei = 0
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
        _ ovalWidth: GLdouble,
        _ ovalHeight: GLdouble)
    {
        
        if ovalWidth == 0.0 || ovalHeight == 0.0 {
            CGContextAddRect(context, rect)
            
            return
        }
        
        CGContextSaveGState(context)
        do {
            CGContextTranslateCTM(context,
                CGRectGetMinX(rect),
                CGRectGetMinY(rect))
            
            CGContextScaleCTM(context, CGFloat(ovalWidth), CGFloat(ovalHeight))
            
            let width  = CGRectGetWidth(rect)  / CGFloat(ovalWidth)
            let height = CGRectGetHeight(rect) / CGFloat(ovalHeight)
            
            let hWidth  = 0.5 * width;
            let hHeight = 0.5 * height;
            
            CGContextMoveToPoint(context, width, hHeight)
            
            CGContextAddArcToPoint(context, width, height, hWidth,  height, 1.0)
            CGContextAddArcToPoint(context, 0.0, height,   0.0, hHeight, 1.0)
            CGContextAddArcToPoint(context, 0.0,   0.0, hWidth,    0.0, 1.0)
            CGContextAddArcToPoint(context, width,   0.0,  width, hHeight, 1.0)
            
            CGContextClosePath(context)
        }
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
                    
                    let cx = GLdouble(HUD.CenterX) * GLdouble(rSize.width)
                    let cy = GLdouble(HUD.CenterY) * GLdouble(rSize.height)
                    let sx = 0.05 * GLdouble(rSize.width)
                    let sy = 0.5  * GLdouble(rSize.height) - 32.0
                    
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
                    do {
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
                                [])
                            
                            CGContextDrawLinearGradient(pContext,
                                pGradient,
                                CGPointMake(CGFloat(cx), CGFloat(cy) - 32.0),
                                CGPointMake(CGFloat(cx), CGFloat(cy) - 16.0),
                                [])
                            
                        }
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
    public convenience init(_ frame: HUD.Button.Bounds,
        _ size: CGFloat)
    {
        self.init()
        
        if !CGRectIsEmpty(frame) {
            mbIsItalic   = false
            mnSize       = (size > 12.0) ? size.d : 24.0
            m_Label      = ""
            mnWidth      = GLsizei(frame.size.width  + 0.5)
            mnHeight     = GLsizei(frame.size.height + 0.5)
            m_Texture[0] = HUD.Button.createTexture(frame.size)
            m_Texture[1] = 0;
            mpText       = nil
            mpQuad       = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
        }
    }
    
    public convenience init(_ frame: HUD.Button.Bounds,
        _ size: CGFloat,
        _ italic: Bool,
        _ label: String)
    {
        self.init()
        if !CGRectIsEmpty(frame) {
            mnWidth      = GLsizei(frame.size.width  + 0.5)
            mnHeight     = GLsizei(frame.size.height + 0.5)
            mbIsItalic   = italic
            mnSize       = (size > 12.0) ? size.d : 24.0
            m_Label      = label
            mpQuad       = GLU.Quad(usage: GL_DYNAMIC_DRAW.ui)
            m_Texture[0] = HUD.Button.createTexture(frame.size)

            mpText       = GLU.Text(m_Label, mnSize.g, mbIsItalic, mnWidth, mnHeight)
            
            if mpText != nil {
                m_Texture[1] = mpText.texture
            }
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
            let pText = GLU.Text(m_Label, mnSize.g, mbIsItalic, mnWidth, mnHeight)
            
            m_Label = label
            mpText = pText
            m_Texture[1] = mpText.texture
        }
        
        return m_Texture[1] != 0
    }
    
    public func draw(selected: Bool,
        _ position: HUD.Button.Position,
        _ bounds: HUD.Button.Bounds)
    {
        glBlendFunc(GL_ONE.ui, GL_ONE_MINUS_SRC_ALPHA.ui)
        glEnable(GL_BLEND.ui)
        do {
            glMatrixMode(GL_MODELVIEW.ui)
            
            GLM.load(true, GLM.translate(position.x.f, position.y.f, 0.0))
            
            glColor3f(1.0, 1.0, 1.0)
            
            glEnable(GL_TEXTURE_RECTANGLE_ARB.ui)
            do {
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, m_Texture[0])
                do {
                    glMatrixMode(GL_TEXTURE.ui)
                    
                    let tm = GLM.texture(true)
                    
                    GLM.load(true, GLM.scale(bounds.size.width.f, bounds.size.height.f, 1.0));
                    
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
                    
                    //GLU::QuadDraw(mpQuad);
                    mpQuad.draw()
                    
                    GLM.load(true, tm);
                }
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB.ui, 0)
            }
            glDisable(GL_TEXTURE_RECTANGLE_ARB.ui)
            
            glEnable(GL_TEXTURE_2D.ui)
            do {
                glBindTexture(GL_TEXTURE_2D.ui, m_Texture[1])
                do {
                    if selected {
                        glColor3f(0.4, 0.7, 1.0)
                    } else {
                        glColor3f(0.85, 0.2, 0.2)
                    }
                    
                    glMatrixMode(GL_MODELVIEW.ui)
                    
                    GLM.load(true, GLM.translate(0.0, -10.0, 0.0))
                    
                    //GLU::QuadSetIsInverted(true, mpQuad);
                    mpQuad.setIsInverted(true)
                    //GLU::QuadSetBounds(bounds, mpQuad);
                    mpQuad.setBounds(bounds)
                    
                    mpQuad.update()
                    mpQuad.draw()
                    
                    GLM.load(true, GLM.translate(0.0, 10.0, 0.0))
                    
                    glColor3f(1.0, 1.0, 1.0)
                }
                glBindTexture(GL_TEXTURE_2D.ui, 0)
            }
            glDisable(GL_TEXTURE_2D.ui)
        }
        glDisable(GL_BLEND.ui)
    }
}