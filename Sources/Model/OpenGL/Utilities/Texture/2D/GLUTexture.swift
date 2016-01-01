//
//  GLUTexture.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility methods for creating 2D OpenGL textures.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension GLU {
    public class Texture {
        
        deinit {
            self.destruct()
        }
        
        private var mbMipmaps: Bool = false
        private var mnTexture: GLuint = 0
        private var mnTarget: GLenum = 0
        private var mnWidth: GLsizei = 0
        private var mnHeight: GLsizei = 0
        private var mpBitmap: CG.Bitmap? = nil
    }
}


//MARK: -
//MARK: Private - Headers

import OpenGL.GL

//MARK: -
//MARK: Private - Utilities - Constructors

extension GLU.Texture {
    private class func create(target: GLenum,
        _ width: GLsizei,
        _ height: GLsizei,
        _ mipmap: Bool,
        _ pData: UnsafeMutablePointer<Void>)
        -> GLuint
    {
        var texture: GLuint = 0
        
        glEnable(target)
        do {
            glGenTextures(1, &texture)
            
            if texture != 0 {
                glBindTexture(target, texture)
                
                if mipmap {
                    glTexParameteri(target, GL_GENERATE_MIPMAP.ui, GL_TRUE)
                    glTexParameteri(target, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR_MIPMAP_LINEAR)
                } else {
                    glTexParameteri(target, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
                }
                
                glTexParameteri(target, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
                glTexParameteri(target, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
                glTexParameteri(target, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
                
                glTexImage2D(target,
                    0,
                    GL_RGBA,
                    GLsizei(width),
                    GLsizei(height),
                    0,
                    GL_RGBA.ui,
                    GL_UNSIGNED_BYTE.ui,
                    pData)
            }
        }
        glDisable(target)
        
        return texture
    }
    
    //MARK: -
    //MARK: Public - Interfaces
    
    public convenience init(_ pName: String,
        _ pExt: String,
        _ nTarget: GLenum = GL_TEXTURE_2D.ui,
        _ bMipmap: Bool = true) {
            self.init()
            self.mpBitmap = CG.Bitmap(pName, pExt)
            
            let pData = mpBitmap!.data
            
            self.mbMipmaps = bMipmap
            self.mnTarget = nTarget
            self.mnWidth   = GLsizei(mpBitmap!.width)
            self.mnHeight  = GLsizei(mpBitmap!.height)
            self.mnTexture = GLU.Texture.create(mnTarget, mnWidth, mnHeight, mbMipmaps, pData)
    }
    
    private func destruct() {
        if mnTexture != 0 {
            glDeleteTextures(1, &mnTexture)
            
            mnTexture = 0
        }
    }
    
    public convenience init(_ rTexture: GLU.Texture) {
        self.init()
        mnTarget  = rTexture.mnTarget
        mbMipmaps = rTexture.mbMipmaps
        mnWidth   = rTexture.mnWidth
        mnHeight  = rTexture.mnHeight
        mpBitmap  = CG.Bitmap(rTexture.mpBitmap)
        
        let pData = self.mpBitmap!.data
        
        mnTexture = GLU.Texture.create(mnTarget, mnWidth, mnHeight, mbMipmaps, pData)
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
