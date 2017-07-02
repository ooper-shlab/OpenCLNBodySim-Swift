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
    open class Gaussian {
        
        deinit {destruct()}
        
        private var mnTexture: GLuint = 0
        private var mnTexRes: GLuint = 0
        private var mnTarget: GLenum = 0
        
        private static func initImage(_ nTexRes: Int,
//            _ queue_x: DispatchQueue,
//            _ queue_y: DispatchQueue,
            _ pImage: UnsafeMutablePointer<GLubyte>)
        {
            let nDelta = 2.0 / Float(nTexRes)
            
            var i = 0
            var j = 0
            
            var w = Float2(-1.0)
            
            DispatchQueue.concurrentPerform(iterations: nTexRes) {y in
                w.y += nDelta
                
                DispatchQueue.concurrentPerform(iterations: nTexRes) {x in
                    w.x += nDelta
                    
                    let d = length(w)
                    var t: Float = 1.0
                    
                    t = CM.isLT(d, t) ? d : 1.0
                    
                    // Hermite interpolation where u = {1, 0} and v = {0, 0}
                    pImage[j] = GLubyte(255.0 * ((2.0 * t - 3.0) * t * t + 1.0))
                    
                    i += 2
                    
                    j += 1
                }
                
                w.x = -1.0
            }
        }
        
        private class func createImage(_ nTexRes: Int) -> [GLubyte] {
            var pImage: [GLubyte] = Array(repeating: 0, count: nTexRes * nTexRes)
            
//            let queue = CF.Queue()
//            
//            let queue_y = queue.createQueue("com.apple.glu.gaussian.ycoord")
//            
//            let queue_x = queue.createQueue("com.apple.glu.gaussian.xcoord")
            
            initImage(nTexRes, /*queue_x, queue_y,*/ &pImage)
            
            return pImage
        }
        
        //MARK: -
        //MARK: Private - Utilities - Constructors
        
        private class func createTexture(_ nTexRes: Int) -> GLuint {
            var texture: GLuint = 0
            
            let pImage = createImage(nTexRes)
            
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
                        nTexRes.i,
                        nTexRes.i,
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
        
        public init(_ nTexRes: Int) {
            mnTarget = GL_TEXTURE_2D.ui
            mnTexRes = nTexRes.ui
            mnTexture = GLU.Gaussian.createTexture(mnTexRes.l)
        }
        
        private func destruct() {
            if mnTexture != 0 {
                glDeleteTextures(1, &mnTexture)
                
                mnTexture = 0
            }
        }
        
        public init(_ rTexture: Gaussian) {
            mnTarget = GL_TEXTURE_2D.ui
            mnTexRes = (rTexture.mnTexRes != 0) ? rTexture.mnTexRes : 64
            mnTexture = GLU.Gaussian.createTexture(mnTexRes.l)
        }
        
        open func enable() {
            glBindTexture(mnTarget, mnTexture)
        }
        
        open func disable() {
            glBindTexture(mnTarget, 0)
        }
        
        open var texture: GLuint {
            return mnTexture
        }
        
        open var target: GLenum {
            return mnTarget
        }
    }
}
