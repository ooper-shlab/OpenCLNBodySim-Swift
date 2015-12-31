//
//  GLUGaussian.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility methods for creating a Gaussian texture.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import simd

extension GLU {
    public class Gaussian {
        
        deinit {destruct()}
        
        private var mnTexture: GLuint = 0
        private var mnTexRes: GLuint = 0
        private var mnTarget: GLenum = 0
        
        private static func initImage(nTexRes: GLuint,
            _ queue_x: dispatch_queue_t,
            _ queue_y: dispatch_queue_t,
            _ pImage: UnsafeMutablePointer<GLubyte>)
        {
            let nDelta = 2.0 / Float(nTexRes)
            
            var i = 0
            var j = 0
            
            var w = Float2(-1.0)
            
            dispatch_apply(nTexRes.l, queue_y) {y in
                w.y += nDelta
                
                dispatch_apply(nTexRes.l, queue_x) {x in
                    w.x += nDelta
                    
                    let d = length(w)
                    var t: Float = 1.0
                    
                    t = CM.isLT(d, t) ? d : 1.0
                    
                    // Hermite interpolation where u = {1, 0} and v = {0, 0}
                    pImage[j] = GLubyte(255.0 * ((2.0 * t - 3.0) * t * t + 1.0))
                    
                    i += 2
                    
                    j++
                }
                
                w.x = -1.0
            }
        }
        
        private class func createImage(nTexRes: GLuint) -> [GLubyte] {
            var pImage: [GLubyte] = []
            
            let queue = CF.Queue()
            
            let queue_y = queue.createQueue("com.apple.glu.gaussian.ycoord")
            
            let queue_x = queue.createQueue("com.apple.glu.gaussian.xcoord")
            
            initImage(nTexRes, queue_x, queue_y, &pImage)
            
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
        
        public init(_ nTexRes: GLuint) {
            mnTarget = GL_TEXTURE_2D.ui
            mnTexRes = nTexRes
            mnTexture = GLU.Gaussian.createTexture(mnTexRes.i)
        }
        
        private func destruct() {
            if mnTexture != 0 {
                glDeleteTextures(1, &mnTexture)
                
            }
        }
        
        public init(_ rTexture: Gaussian) {
            mnTarget = GL_TEXTURE_2D.ui
            mnTexRes = (rTexture.mnTexRes != 0) ? rTexture.mnTexRes : 64
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