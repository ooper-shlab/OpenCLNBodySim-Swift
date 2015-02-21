//
//  GLUTexture.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: GLUTexture.h
     File: GLUTexture.mm
 Abstract:
 Utility methods for creating 2D OpenGL textures.

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
        -> GLuint {
            var texture: GLuint = 0
            
            glEnable(target)
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
            glDisable(target)
            
            return texture
    }
    
    //MARK: -
    //MARK: Public - Interfaces
    
    public convenience init(name pName: String,
        ext pExt: String,
        target nTarget: GLenum = GL_TEXTURE_2D.ui,
        mipmap bMipmap: Bool = true) {
            self.init()
            self.mpBitmap = CG.Bitmap(name: pName, ext: pExt)
            
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
        
        if mpBitmap != nil {
            
            mpBitmap = nil
        }
    }
    
    public convenience init(texture rTexture: GLU.Texture) {
        self.init()
        mnTarget  = rTexture.mnTarget
        mbMipmaps = rTexture.mbMipmaps
        mnWidth   = rTexture.mnWidth
        mnHeight  = rTexture.mnHeight
        mpBitmap  = CG.Bitmap(bitmap: rTexture.mpBitmap)
        
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