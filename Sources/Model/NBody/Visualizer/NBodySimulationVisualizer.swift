//
//  NBodySimulationVisualizer.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: NBodySimulationVisualizer.h
     File: NBodySimulationVisualizer.mm
 Abstract:
A Visualizer mediator object for managing of rendering n-bodies to an OpenGL view.

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

extension NBody.Simulation {
    public class Visualizer {
        
        //MARK: -
        //MARK: Private - Enumerated Types
        
        private typealias Flags = (
            IsAcquired: Bool,
            IsResetting: Bool,
            IsRotating: Bool,
            IsEarthView: Bool
        )
        private typealias Properties = (
            StarSize: GLfloat,
            StarScale: GLfloat,
            TimeScale: GLfloat,
            RotationSpeed: GLfloat,
            RotationDelta: GLfloat,
            ViewTime: GLfloat,
            ViewZoom: GLfloat,
            ViewDistance: GLfloat,
            ViewZoomSpeed: GLfloat
        )
        private typealias Graphics = (
            BufferID: GLuint,
            BufferCount: GLsizei,
            BufferSize: GLsizeiptr,
            LocSampler2D: GLint,
            LocPointSize: GLint
        )
        typealias Params = NBody.Simulation.Params
        
        deinit {
            destruct()
        }
        
        private var m_Flag: Flags = (false, false, false, false)
        private var m_ViewRotation: CGPoint = CGPoint()
        private var m_Rotation: CGPoint = CGPoint()
        private var m_Frame: CGSize = CGSize()
        private var m_Bounds: [GLsizei] = [0, 0]
        private var m_Property: Properties = (0, 0, 0, 0, 0, 0, 0, 0, 0)
        private var m_Graphic: Graphics = (0, 0, 0, 0, 0)
        private var mnActiveDemo: Int = 0
        private var mpParams: [Params] = []
        private var mpProgram: GLU.Program!
        private var mpGausssian: GLU.Gaussian!
        private var mpTexture: GLU.Texture!
    }
}

//MARK: -
//MARK: Private - Utilities - Properties

extension NBody.Simulation.Visualizer {
    private func advance(nDemo: Int) {
        if nDemo < mpParams.count {
            let t = sinf(m_Property.ViewTime)
            let T = 1.0 - t
            
            m_Property.ViewDistance = t * mpParams[nDemo].mnViewDistance + T * m_Property.ViewZoom
            
            m_Rotation.x = (t * mpParams[nDemo].mnRotateX).g + T.g * m_ViewRotation.x
            m_Rotation.y = (t * mpParams[nDemo].mnRotateY).g + T.g * m_ViewRotation.y
        }
    }
    
    //MARK: -
    //MARK: Private - Utilities - Transformations
    
    public func projection() {
        glMatrixMode(GL_PROJECTION.ui)
        
        // DEPRECATED gluPerspective():
        //
        //    glLoadIdentity();
        //    gluPerspective(60, (GLfloat)mnWidth / (GLfloat)mnHeight, 0.1, 10000);
        
        let proj = GLM.projection(60, GLfloat(m_Frame.width), GLfloat(m_Frame.height), 1.0, 10000)
        
        GLM.load(true, proj)
    }
    
    private func lookAt(pPosition: UnsafePointer<GLfloat>) {
        glMatrixMode(GL_MODELVIEW.ui)
        
        // DEPRECATED gluLookAt():
        //
        //    glLoadIdentity();
        //
        //    if(mnActiveDemo == 0 && m_Flag[eNBodyIsEarthView])
        //    {
        //        GLfloat *pEye = pPosition + 3472;
        //        gluLookAt(pEye[0], pEye[1], pEye[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
        //    }
        //    else
        //    {
        //        gluLookAt(-m_Property[eNBodyViewDistance], 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
        //    }
        
        var eye: Float3 = (0.0, 0.0, 0.0)
        let center: Float3 = (0.0, 0.0, 0.0)
        let up: Float3 = (0.0, 1.0, 0.0)
        
        if mnActiveDemo == 0 && m_Flag.IsEarthView {
            
            eye = (pPosition[3472], pPosition[3473], pPosition[3474])
        } else {
            eye = (-m_Property.ViewDistance, 0.0, 0.0)
        }
        
        let mv = GLM.lookAt(eye, center, up)
        
        GLM.load(false, mv)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Updating
    
    private func update() {
        if m_Rotation.x > 180 || m_Rotation.y > 180 {
            while m_Rotation.x > 180 {
                m_Rotation.x -= 360
            }
            
            while m_Rotation.y > 180 {
                m_Rotation.y -= 360
            }
        }
        
        if m_Rotation.x < -180 || m_Rotation.y < -180 {
            while m_Rotation.x < -180 {
                m_Rotation.x += 360
            }
            
            while m_Rotation.y < -180 {
                m_Rotation.y += 360
            }
        }
        
        if m_Flag.IsRotating {
            // (cos(0 to pi) + 1) * 0.5f
            m_Property.RotationSpeed += m_Property.RotationDelta
            
            if m_Property.RotationSpeed > GLM.kPi.f {
                m_Property.RotationSpeed = GLM.kPi.f
            }
        } else {
            m_Property.RotationSpeed -= m_Property.RotationDelta
            
            if m_Property.RotationSpeed < 0.0 {
                m_Property.RotationSpeed = 0.0
            }
        }
        
        if m_Flag.IsResetting {
            m_Property.ViewTime += 0.02
            
            if m_Property.ViewTime >= GLM.kHalfPi.f {
                m_Property.RotationSpeed = 0.0
                
                reset(mnActiveDemo)
                
                m_Flag.IsResetting = false
            } else {
                advance(mnActiveDemo)
            }
        }
    }
    
    //MARK: -
    //MARK: Private - Utilities - Rendering
    
    private func render(pPosition: UnsafePointer<GLfloat>) {
        glViewport(0, 0, m_Bounds[0], m_Bounds[1])
        
        glBlendFunc(GL_ONE.ui, GL_ONE.ui)
        glEnable(GL_BLEND.ui)
        
        mpProgram.enable()
        glActiveTexture(GL_TEXTURE0.ui)
        
        glEnableClientState(GL_VERTEX_ARRAY.ui)
        glBindBuffer(GL_ARRAY_BUFFER.ui, m_Graphic.BufferID)
        glBufferSubData(GL_ARRAY_BUFFER.ui, 0, m_Graphic.BufferSize, pPosition)
        glVertexPointer(4, GL_FLOAT.ui, 0, nil)
        glBindBuffer(GL_ARRAY_BUFFER.ui, 0)
        
        glPushMatrix()
        if !m_Flag.IsResetting {
            let rotFactor = 1.0 - 0.5 * (1.0 + cosf(m_Property.RotationSpeed))
            
            m_Rotation.x += 1.6 * m_Property.TimeScale.g * rotFactor.g
            m_Rotation.y += 0.8 * m_Property.TimeScale.g * rotFactor.g
        }
        
        if mnActiveDemo != 0 || !m_Flag.IsEarthView {
            glRotatef(m_Rotation.y.f, 1, 0, 0)
            glRotatef(m_Rotation.x.f, 0, 1, 0)
        }
        
        glUniform1f(m_Graphic.LocPointSize,
            m_Property.StarSize * mpParams[mnActiveDemo].mnPointSize)
        
        mpTexture.enable()
        
        // white stars
        glColor3f(0.8, 0.8, 0.8)
        glDrawArrays(GL_POINTS.ui, 0, m_Graphic.BufferCount / 8)
        
        // blue stars
        glColor3f(0.4, 0.6, 1.0)
        glDrawArrays(GL_POINTS.ui, m_Graphic.BufferCount / 8, m_Graphic.BufferCount / 4)
        
        // red stars
        glColor3f(1.0, 0.6, 0.6)
        glDrawArrays(GL_POINTS.ui, m_Graphic.BufferCount / 12, m_Graphic.BufferCount / 4)
        mpGausssian.enable()
        if mnActiveDemo != 0 {
            glUniform1f(m_Graphic.LocPointSize,
                300 * mpParams[mnActiveDemo].mnPointSize)
            
            // purple clouds
            glColor3f(0.032, 0.01, 0.026)
            glDrawArrays(GL_POINTS.ui, 0, 64)
            
            // blue clouds
            glColor3f(0.018, 0.01, 0.032)
            glDrawArrays(GL_POINTS.ui, 64, 64)
        } else {
            glUniform1f(m_Graphic.LocPointSize, 300)
            
            let step = m_Graphic.BufferCount / 24
            
            // pink
            glColor3f(0.04, 0.015, 0.025)
            
            for var i: GLsizei = 0; i < m_Graphic.BufferCount / 84; i += step {
                glDrawArrays(GL_POINTS.ui, i, 1)
            }
            
            // blue
            glColor3f(0.04, 0.001, 0.08)
            
            for var i: GLsizei = 64; i < m_Graphic.BufferCount / 84; i += step {
                glDrawArrays(GL_POINTS.ui, i, 1)
            }
        }
        
        glBindTexture(GL_TEXTURE_2D.ui, 0)
        
        glColor3f(1.0, 1.0, 1.0)
        glPopMatrix()
        glDisableClientState(GL_VERTEX_ARRAY.ui)
        mpProgram.disable()
        glDisable(GL_BLEND.ui)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Assets
    
    private func buffer(nCount: Int) -> Bool {
        m_Graphic.BufferID = 0
        m_Graphic.BufferCount = GLsizei(nCount)
        m_Graphic.BufferSize  = 4 * GLsizeiptr(m_Graphic.BufferCount) * GLM.Size.kFloat
        
        glEnableClientState(GL_VERTEX_ARRAY.ui)
        
        glGenBuffers(1, &m_Graphic.BufferID)
        
        if m_Graphic.BufferID != 0 {
            glBindBuffer(GL_ARRAY_BUFFER.ui, m_Graphic.BufferID)
            glBufferData(GL_ARRAY_BUFFER.ui, m_Graphic.BufferSize, nil, GL_DYNAMIC_DRAW_ARB.ui)
            glVertexPointer(4, GL_FLOAT.ui, 0, nil)
            glBindBuffer(GL_ARRAY_BUFFER.ui, 0)
        }
        glDisableClientState(GL_VERTEX_ARRAY.ui)
        
        return m_Graphic.BufferID != 0
    }
    
    private func textures(pName: String, _ pExt: String, _ texRes: GLint = 32) -> Bool {
        mpTexture = GLU.Texture(name: pName, ext: pExt)
        
        mpGausssian = GLU.Gaussian(texRes: GLuint(texRes))
        
        return mpTexture.texture != 0 && mpGausssian.texture != 0
    }
    
    private func program(pName: String) -> Bool {
        mpProgram = GLU.Program(name: pName, inType: GL_POINTS.ui, outType: GL_TRIANGLE_STRIP.ui, outVert: 4)
        
        let nPID = mpProgram.program
        
        if nPID != 0 {
            mpProgram.enable()
            m_Graphic.LocSampler2D = glGetUniformLocation(nPID, "splatTexture")
            m_Graphic.LocPointSize = glGetUniformLocation(nPID, "pointSize")
            
            glUniform1i(m_Graphic.LocSampler2D, 0)
            mpProgram.disable()
        }
        
        return nPID != 0
    }
    
    private func acquire(nCount: Int) -> Bool {
        var bSuccess = nCount > 0
        
        if bSuccess {
            bSuccess = buffer(nCount)
                && textures("star", "png")
                && program("nbody")
        }
        
        return bSuccess
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(bodies nBodies: Int) {
        self.init()
        m_Flag.IsAcquired = acquire(nBodies)
        
        if m_Flag.IsAcquired {
            m_Property.RotationDelta = NBody.Defaults.kRotationDelta
            m_Property.ViewDistance = NBody.Defaults.kViewDistance
            m_Property.ViewZoomSpeed = NBody.Defaults.kScrollZoomSpeed
            m_Property.TimeScale = NBody.Scale.kTime
            m_Property.StarScale = NBody.Star.kScale
            m_Property.StarSize = NBody.Star.kSize * m_Property.StarScale
            m_Property.RotationSpeed = 0.0
            m_Property.ViewTime = 0.0
            m_Property.ViewZoom = 0.0
            
            m_Flag.IsResetting = false
            m_Flag.IsRotating = false
            m_Flag.IsEarthView = false
            
            m_Frame.width    = NBody.Window.kWidth.g
            m_Frame.height   = NBody.Window.kHeight.g
            m_Bounds[0]      = GLsizei(m_Frame.width + 0.5)
            m_Bounds[1]      = GLsizei(m_Frame.height + 0.5)
            mpParams         = NBody.Simulation.Demo.kParams
            mnActiveDemo     = 0
            m_Rotation.x     = 0.0
            m_Rotation.y     = 0.0
            m_ViewRotation.x = 0.0
            m_ViewRotation.y = 0.0
        }
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    private func destruct() {
        if m_Graphic.BufferID != 0 {
            
            glDeleteBuffers(1, &m_Graphic.BufferID);
            
            m_Graphic.BufferID = 0
        }
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public func reset(nDemo: Int) {
        if nDemo < mpParams.count {
            mnActiveDemo = nDemo
            
            m_Property.ViewDistance = mpParams[nDemo].mnViewDistance
            
            m_Rotation.x = mpParams[nDemo].mnRotateX.g
            m_Rotation.y = mpParams[nDemo].mnRotateY.g
        }
    }
    
    public func draw(pPosition: UnsafePointer<GLfloat>) {
        update()
        
        projection()
        lookAt(pPosition)
        
        render(pPosition)
    }
    
    public func stopRotation() {
        m_Flag.IsRotating = false
    }
    
    public func toggleRotation() {
        m_Flag.IsRotating = !m_Flag.IsRotating
    }
    
    public func toggleEarthView() {
        m_Flag.IsEarthView = !m_Flag.IsEarthView
    }
    
    //MARK: -
    //MARK: Public - Query
    
    public var isValid: Bool {
        return m_Flag.IsAcquired
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public func setIsResetting(bReset: Bool) {
        m_Flag.IsResetting = bReset
    }
    
    public func setShowEarthView(bShowView: Bool) {
        m_Flag.IsEarthView = bShowView
    }
    
    public func setFrame(rFrame: CGSize) {
        if rFrame.width >= NBody.Window.kWidth.g && rFrame.height >= NBody.Window.kHeight.g {
            m_Frame = rFrame
            m_Bounds[0] = GLsizei(m_Frame.width + 0.5)
            m_Bounds[1] = GLsizei(m_Frame.height + 0.5)
        }
    }
    
    public func setParams(params: [NBody.Simulation.Params]) -> Bool {
        var bSuccess = m_Flag.IsAcquired
        
        if bSuccess {
            
            mpParams = params
        }
        
        return bSuccess
    }
    
    public func setRotation(rRotation: CGPoint) {
        m_Rotation = rRotation
    }
    
    public func setRotationChange(nDelta: GLfloat) {
        m_Property.RotationDelta = nDelta
    }
    
    public func setRotationSpeed(nSpeed: GLfloat) {
        m_Property.RotationSpeed = nSpeed
    }
    
    public func setStarScale(nScale: GLfloat) {
        if nScale > 0.0 {
            m_Property.StarScale = nScale
        }
    }
    
    public func setStarSize(nSize: GLfloat) {
        if nSize > 0.0 {
            m_Property.StarSize = m_Property.StarScale * nSize
        }
    }
    
    public func setTimeScale(nScale: GLfloat) {
        m_Property.TimeScale = nScale
    }
    
    public func setViewDistance(nDelta: GLfloat) {
        m_Property.ViewDistance = m_Property.ViewDistance + nDelta * m_Property.ViewZoomSpeed
        
        if m_Property.ViewDistance < 1.0 {
            m_Property.ViewDistance = 1.0
        }
    }
    
    public func setViewTime(nResetTime: GLfloat) {
        m_Property.ViewTime = nResetTime
    }
    
    public func setViewRotation(rRotation: CGPoint) {
        m_ViewRotation = rRotation
    }
    
    public func setViewZoom(nZoom: GLfloat) {
        m_Property.ViewZoom = nZoom
    }
    
    public func setViewZoomSpeed(nSpeed: GLfloat) {
        m_Property.ViewZoomSpeed = nSpeed
    }
}