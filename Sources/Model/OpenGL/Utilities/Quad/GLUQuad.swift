//
//  GLUQuad.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility methods for managing a VBO based an OpenGL quad.
</abstract>
</codex>
 */

import Cocoa

//MARK: -
//MARK: Private - Headers

import OpenGL.GL

//MARK: -
//MARK: Private - Data Structures

extension GLU {
    open class Quad {
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
        var mpData: UnsafeMutablePointer<GLfloat>? = nil               // vbo data
        var m_Vertices: [GLfloat] = [0, 0, 0, 0, 0, 0, 0, 0]        // Quad vertices
        var m_TexCoords: [GLfloat] = [0, 0, 0, 0, 0, 0, 0, 0]       // Quad texture coordinates
        
        //MARK: -
        //MARK: Private - Macros
        
        private func BUFFER_OFFSET(_ i: Int) -> UnsafePointer<GLchar>? {
            return UnsafePointer(bitPattern: i)
        }
        
        //MARK: -
        //MARK: Private - Accessors
        
        private func acquireBounds(_ bounds: CGRect) -> Bool {
            let bSuccess = !bounds.isEmpty
            
            if bSuccess {
                self.mbResize = !bounds.equalTo(self.m_Bounds)
                
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
        
        private func setVertices(_ bounds: CGRect) -> Bool {
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
        
        private func setTextCoords(_ bIsInverted: Bool) -> Bool {
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
                    do {
                        glBufferData(mnTarget, mnCapacity, nil, mnUsage)
                        
                        glBufferSubData(mnTarget, 0, mnSize, m_Vertices)
                        glBufferSubData(mnTarget, mnSize, mnSize, m_TexCoords)
                    }
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
                
                mpData = glMapBuffer(mnTarget, GL_WRITE_ONLY.ui).assumingMemoryBound(to: GLfloat.self)
                
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
            do {
                glEnableClientState(GL_TEXTURE_COORD_ARRAY.ui)
                glEnableClientState(GL_VERTEX_ARRAY.ui)
                
                glVertexPointer(2, mnType, mnStride, BUFFER_OFFSET(0))
                glTexCoordPointer(2, mnType, mnStride, BUFFER_OFFSET(mnSize))
                
                glDrawArrays(mnMode, 0, mnCount)
                
                glDisableClientState(GL_VERTEX_ARRAY.ui)
                glDisableClientState(GL_TEXTURE_COORD_ARRAY.ui)
            }
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
        open var isFinalized: Bool {
            return mnBID != 0
        }
        
        // Set the quad to be inverted
        @discardableResult
        open func setIsInverted(_ bIsInverted: Bool) -> Bool {
            return setTextCoords(bIsInverted)
        }
        
        // Set the quad bounds
        @discardableResult
        open func setBounds(_ bounds: CGRect) -> Bool {
            return setVertices(bounds)
        }
        
        //MARK: -
        //MARK: Public - Updating
        
        // Finalize and acquire a vbo for the quad
        @discardableResult
        open func finalize() -> Bool {
            return acquireBuffer();
        }
        
        // Update the quad if either the bounds changed or
        // the inverted flag was changed
        open func update() {
            updateBuffer()
        }
        
        //MARK: -
        //MARK: Public - Map/Unmap
        
        // Map to get the base address of the quad's vbo
        open func map() -> Bool {
            return mapBuffer()
        }
        
        // Unmap to invalidate the base address of the quad's vbo
        open func unmap() -> Bool {
            return unmapBuffer()
        }
        
        // Get the base address of the quad's vbo
        open var buffer: UnsafeMutablePointer<GLfloat> {
            return mpData!
        }
        
        //MARK: -
        //MARK: Public - Drawing
        
        // Draw the quad
        open func draw() {
            drawArrays()
        }
    }
}
