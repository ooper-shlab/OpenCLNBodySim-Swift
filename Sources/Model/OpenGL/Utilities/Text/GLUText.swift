//
//  GLUText.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
<codex>
<abstract>
Utility methods for generating OpenGL texture from a string.
</abstract>
</codex>
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
        private var m_Range: CFRange = CFRange()
        
        //MARK: -
        //MARK: Private - Constants
        
        private final let kGLUTextBPC: GLuint = 8
        private final let kGLUTextSPP: GLuint = 4
        
        private final let kGLUTextBitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        //MARK: -
        //MARK: Private - Utilities - Constructors - Contexts
        
        private func create(nWidth: GLsizei,
            _ nHeight: GLsizei) -> CGContext?
        {
            var pContext: CGContext? = nil
            
            if nWidth * nHeight != 0 {
                let pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
                
                if pColorspace != nil {
                    let bpp = nWidth.l * kGLUTextSPP.l
                    
                    pContext = CGBitmapContextCreate(nil,
                        nWidth.l,
                        nHeight.l,
                        kGLUTextBPC.l,
                        bpp,
                        pColorspace,
                        kGLUTextBitmapInfo.rawValue)
                    
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
        
        private func create(rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment) -> GLuint
        {
            var nTexture: GLuint = 0
            
            let pFrame = CT.Frame(rText, rFont, nFontSize, rOrigin, nTextAlign)
            
            m_Bounds = pFrame.bounds
            m_Range  = pFrame.range
            
            let pContext = create(m_Bounds.size)
            
            if pContext != nil {
                pFrame.draw(pContext)
                
                nTexture = create(pContext!)
                
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
            -> GLuint
        {
            var nTexture: GLuint = 0
            
            let pFrame = CT.Frame(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign)
            
            m_Bounds = pFrame.bounds
            m_Range = pFrame.range
            
            let pContext = create(nWidth, nHeight)
            
            if pContext != nil {
                pFrame.draw(pContext)
                
                nTexture = create(pContext!)
                
            } else {
                NSLog(">> ERROR: Failed creating Core-Text frame object")
            }
            
            return nTexture
        }
        
        //MARK: -
        //MARK: Public - Constructors
        
        // Create a texture with bounds derived from the text size.
        public init(_ rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment = .Center)
        {
            mnTexture = create(rText, rFont, nFontSize, rOrigin, nTextAlign)
        }
        
        // Create a texture with bounds derived from the input width and height.
        public init(_ rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment = .Center)
        {
            mnTexture = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        // Create a texture with bounds derived from the text size using
        // helvetica bold or helvetica bold oblique font.
        public init(_ rText: String,
            _ nFontSize: CGFloat,
            _ bIsItalic: Bool,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment = .Center)
        {
            let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
            
            mnTexture = create(rText, font, nFontSize, rOrigin, nTextAlign)
        }
        
        // Create a texture with bounds derived from input width and height,
        // and using helvetica bold or helvetica bold oblique font.
        public init(_ rText: String,
            _ nFontSize: CGFloat,
            _ bIsItalic: Bool,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment = .Center)
        {
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
