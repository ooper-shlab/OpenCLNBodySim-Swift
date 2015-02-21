//
//  GLUQuad.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: GLUQuad.h
     File: GLUQuad.mm
 Abstract:
 Utility methods for managing a VBO based an OpenGL quad.

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

//MARK: -
//MARK: Private - Headers

import OpenGL.GL

//MARK: -
//MARK: Private - Data Structures

extension GLU {
    public class Quad {
        deinit {destruct()}
        
        var mbResize: Bool = false                 // Flag to indicate if quad size changed
        var mbUpdate: Bool = false                 // Flag to indicate if the tex coordinates changed
        var mbMapped: Bool = false                 // Flag to indicate if the vbo was mapped
        
        var mnBID: GLuint = 0                  // buffer identifier
        var mnCount: GLsizei = 0                // vertex count
        var mnSize: GLsizeiptr = 0                 // size of m_Vertices or texture coordinates
        var mnCapacity: GLsizeiptr = 0             // vertex size + texture coordinate siez
        
        var mnStride: GLsizei = 0              // vbo stride
        
        var mnTarget: GLenum = 0              // vbo target
        var mnUsage: GLenum = 0               // vbo usage
        var mnType: GLenum = 0                // vbo type
        var mnMode: GLenum = 0                // vbo mode
        
        var m_Bounds: CGRect = CGRect()               // vbo bounds;
        
        var mnAspect: GLfloat = 0             // Aspect ratio
        var mpData: UnsafeMutablePointer<GLfloat> = nil               // vbo data
        var m_Vertices: [GLfloat] = [0, 0, 0, 0, 0, 0, 0, 0]        // Quad vertices
        var m_TexCoords: [GLfloat] = [0, 0, 0, 0, 0, 0, 0, 0]       // Quad texture coordinates
        
        //MARK: -
        //MARK: Private - Macros
        
        private func BUFFER_OFFSET(i: Int) -> UnsafePointer<GLchar> {
            return (UnsafePointer.null().advancedBy(i))
        }
        
        //MARK: -
        //MARK: Private - Accessors
        
        private func acquireBounds(bounds: CGRect) -> Bool {
            var bSuccess = !CGRectIsEmpty(bounds)
            
            if bSuccess {
                self.mbResize = !CGRectEqualToRect(bounds, self.m_Bounds)
                
                if self.mbResize {
                    self.m_Bounds.origin.x = bounds.origin.x
                    self.m_Bounds.origin.y = bounds.origin.y
                    
                    self.m_Bounds.size.width  = bounds.size.width
                    self.m_Bounds.size.height = bounds.size.height
                    
                    self.mnAspect = GLfloat(self.m_Bounds.size.width / self.m_Bounds.size.height)
                }
            } else {
                self.m_Bounds.origin.x = 0.0
                self.m_Bounds.origin.y = 0.0
                
                self.m_Bounds.size.width  = 1920.0
                self.m_Bounds.size.height = 1080.0
                
                self.mnAspect = GLfloat(self.m_Bounds.size.width / self.m_Bounds.size.height)
            }
            
            return bSuccess && self.mbResize
        }
        
        private func setVertices(bounds: CGRect) -> Bool {
            let bSuccess = self.acquireBounds(bounds)
            
            if bSuccess {
                self.m_Vertices[0] = GLfloat(self.m_Bounds.origin.x)
                self.m_Vertices[1] = GLfloat(self.m_Bounds.origin.y)
                
                self.m_Vertices[2] = GLfloat(self.m_Bounds.origin.x + self.m_Bounds.size.width)
                self.m_Vertices[3] = GLfloat(self.m_Bounds.origin.y)
                
                self.m_Vertices[4] = GLfloat(self.m_Bounds.origin.x + self.m_Bounds.size.width)
                self.m_Vertices[5] = GLfloat(self.m_Bounds.origin.y + self.m_Bounds.size.height)
                
                self.m_Vertices[6] = GLfloat(self.m_Bounds.origin.x)
                self.m_Vertices[7] = GLfloat(self.m_Bounds.origin.y + self.m_Bounds.size.height)
            }
            
            return bSuccess
        }
        
        private func setTextCoords(bIsInverted: Bool) -> Bool {
            let nValue: GLfloat = bIsInverted ? 0.0 : 1.0
            
            self.mbUpdate = self.m_TexCoords[7] != nValue
            
            if self.mbUpdate {
                if bIsInverted {
                    self.m_TexCoords[0]  = 0.0
                    self.m_TexCoords[1]  = 1.0
                    
                    self.m_TexCoords[2]  = 1.0
                    self.m_TexCoords[3]  = 1.0
                    
                    self.m_TexCoords[4]  = 1.0
                    self.m_TexCoords[5]  = 0.0
                    
                    self.m_TexCoords[6]  = 0.0
                    self.m_TexCoords[7]  = 0.0
                } else {
                    self.m_TexCoords[0]  = 0.0
                    self.m_TexCoords[1]  = 0.0
                    
                    self.m_TexCoords[2]  = 1.0
                    self.m_TexCoords[3]  = 0.0
                    
                    self.m_TexCoords[4]  = 1.0
                    self.m_TexCoords[5]  = 1.0
                    
                    self.m_TexCoords[6]  = 0.0
                    self.m_TexCoords[7]  = 1.0
                }
            }
            
            return self.mbUpdate
        }
        
        //MARK: -
        //MARK: Private - Constructor
        
        private var usage: GLenum {
            get {return self.mnUsage}
            set {
                switch newValue {
                case GL_STREAM_DRAW.ui,
                GL_STATIC_DRAW.ui,
                GL_DYNAMIC_DRAW.ui:
                    self.mnUsage = newValue
                    
                default:
                    self.mnUsage = GL_STATIC_DRAW.ui
                }
            }
        }
        
        private func setDefaults() {
            
            self.mnCount = 4
            self.mnSize = 8 * GLM.Size.kFloat
            self.mnCapacity = 2 * self.mnSize
            self.mnType = GL_FLOAT.ui
            self.mnMode = GL_QUADS.ui
            self.mnTarget = GL_ARRAY_BUFFER.ui
            
            self.m_TexCoords[7] = 2.0
        }
        
        private init(_ nUsage: GLenum) {
            
            self.setDefaults()
            self.usage = nUsage
            
        }
        
        //MARK: -
        //MARK: Private - Destructors
        
        private func deleteVertexBuffer() {
            if mnBID != 0 {
                glDeleteBuffers(1, &mnBID)
            }
        }
        
        private func destruct() {
            deleteVertexBuffer()
        }
        
        //MARK: -
        //MARK: Private - Utilities - Acquire
        
        private func acquireBuffer() -> Bool {
            if mnBID == 0 {
                glGenBuffers(1, &mnBID)
                
                if mnBID != 0 {
                    glBindBuffer(mnTarget, mnBID)
                    glBufferData(mnTarget, mnCapacity, nil, mnUsage)
                    
                    glBufferSubData(mnTarget, 0, mnSize, m_Vertices)
                    glBufferSubData(mnTarget, mnSize, mnSize, m_TexCoords)
                    glBindBuffer(mnTarget, 0)
                }
            }
            
            return mnBID != 0
        }
        
        //MARK: -
        //MARK: Private - Utilities - Map/Unmap
        
        private func mapBuffer() -> Bool {
            if mbResize && !mbMapped {
                glBindBuffer(mnTarget, mnBID)
                
                glBufferData(mnTarget, mnCapacity, nil, mnUsage)
                
                mpData = UnsafeMutablePointer(glMapBuffer(mnTarget, GL_WRITE_ONLY.ui))
                
                mbMapped = mpData != nil
            }
            
            return mbMapped
        }
        
        private func unmapBuffer() -> Bool {
            var bSuccess = mbResize && mbMapped
            
            if bSuccess {
                bSuccess = glUnmapBuffer(mnTarget) != GL_FALSE.ub
                
                glBindBuffer(mnTarget, 0)
                
                mbMapped = false
            }
            
            return bSuccess
        }
        
        //MARK: -
        //MARK: Private - Utilities - Update
        
        private func updateBuffer() {
            glBindBuffer(mnTarget, mnBID)
            
            if mbResize {
                glBufferSubData(mnTarget, 0, mnSize, m_Vertices)
            }
            
            if mbUpdate {
                glBufferSubData(mnTarget, mnSize, mnSize, m_TexCoords)
            }
        }
        
        //MARK: -
        //MARK: Private - Utilities - Draw
        
        private func drawArrays() {
            glBindBuffer(mnTarget, mnBID)
            glEnableClientState(GL_TEXTURE_COORD_ARRAY.ui)
            glEnableClientState(GL_VERTEX_ARRAY.ui)
            
            glVertexPointer(2, mnType, mnStride, BUFFER_OFFSET(0))
            glTexCoordPointer(2, mnType, mnStride, BUFFER_OFFSET(mnSize))
            
            glDrawArrays(mnMode, 0, mnCount)
            
            glDisableClientState(GL_VERTEX_ARRAY.ui)
            glDisableClientState(GL_TEXTURE_COORD_ARRAY.ui)
            glBindBuffer(mnTarget, 0)
        }
        
        //MARK: -
        //MARK: Public - Constructor
        
        // Construct a quad with a usage enumerated type
        public convenience init(usage nUsage: GLenum) {
            self.init(nUsage)
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        // Is the quad finalized?
        public var isFinalized: Bool {
            return mnBID != 0
        }
        
        // Set the quad to be inverted
        public func setIsInverted(bIsInverted: Bool) -> Bool {
            return setTextCoords(bIsInverted)
        }
        
        // Set the quad bounds
        public func setBounds(bounds: CGRect) -> Bool {
            return setVertices(bounds)
        }
        
        //MARK: -
        //MARK: Public - Updating
        
        // Finalize and acquire a vbo for the quad
        public func finalize() -> Bool {
            return acquireBuffer();
        }
        
        // Update the quad if either the bounds changed or
        // the inverted flag was changed
        public func update() {
            updateBuffer()
        }
        
        //MARK: -
        //MARK: Public - Map/Unmap
        
        // Map to get the base address of the quad's vbo
        public func map() -> Bool {
            return mapBuffer()
        }
        
        // Unmap to invalidate the base address of the quad's vbo
        public func unmap() -> Bool {
            return unmapBuffer()
        }
        
        // Get the base address of the quad's vbo
        public var buffer: UnsafeMutablePointer<GLfloat> {
            return mpData
        }
        
        //MARK: -
        //MARK: Public - Drawing
        
        // Draw the quad
        public func draw() {
            drawArrays()
        }
    }
}