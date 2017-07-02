//
//  NBodySimulationVisualizer.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
A Visualizer mediator object for managing of rendering n-particles to an OpenGL view.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import simd

extension NBody.Simulation {
    open class Visualizer {
        
        //MARK: -
        //MARK: Private - Enumerated Types
        
        fileprivate typealias Flags = (
            IsAcquired: Bool,
            IsResetting: Bool,
            IsRotating: Bool,
            IsEarthView: Bool
        )
        fileprivate typealias Properties = (
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
        fileprivate typealias Graphics = (
            BufferID: GLuint,
            BufferCount: GLsizei,
            BufferSize: GLsizeiptr,
            LocSampler2D: GLint,
            LocPointSize: GLint
        )
        
        deinit {
            destruct()
        }
        
        open var m_Center: Float3 = Float3()
        open var m_Up: Float3 = Float3()
        
        fileprivate var m_Flag: Flags = (false, false, false, false)
        
        fileprivate var m_Eye: Float3 = Float3()
        
        fileprivate var m_ModelView: Float4x4 = Float4x4()
        fileprivate var m_Projection: Float4x4 = Float4x4()
        
        fileprivate var m_ViewRotation: CGPoint = CGPoint()
        fileprivate var m_Rotation: CGPoint = CGPoint()
        fileprivate var m_Frame: CGSize = CGSize()
        
        fileprivate var m_Bounds: [GLsizei] = [0, 0]
        fileprivate var m_Property: Properties = (0, 0, 0, 0, 0, 0, 0, 0, 0)
        fileprivate var m_Graphic: Graphics = (0, 0, 0, 0, 0)
        fileprivate var mnActiveDemo: Int = 0
        fileprivate var mnCount: Int = 0
        
        fileprivate var mpProperties: [NBody.Simulation.Properties] = []
        
        fileprivate var mpProgram: GLU.Program!
        fileprivate var mpGausssian: GLU.Gaussian!
        fileprivate var mpTexture: GLU.Texture!
    }
}

//MARK: -
//MARK: Private - Utilities - Properties

extension NBody.Simulation.Visualizer {
    private func advance(_ nDemo: Int) {
        if nDemo < mnCount {
            let t = sinf(m_Property.ViewTime)
            let T = 1.0 - t
            
            m_Property.ViewDistance = t * mpProperties[nDemo].mnViewDistance + T * m_Property.ViewZoom
            
            m_Rotation.x = (t.g * mpProperties[nDemo].mnRotateX) + T.g * m_ViewRotation.x
            m_Rotation.y = (t.g * mpProperties[nDemo].mnRotateY) + T.g * m_ViewRotation.y
        }
    }
    
    //MARK: -
    //MARK: Private - Utilities - Transformations
    
    public func projection() {
        // DEPRECATED gluPerspective():
        //
        //    glLoadIdentity();
        //    gluPerspective(60, (GLfloat)mnWidth / (GLfloat)mnHeight, 0.1, 10000);
        
        m_Projection = GLM.projection(60, GLfloat(m_Frame.width), GLfloat(m_Frame.height), 1.0, 10000)
        
        glMatrixMode(GL_PROJECTION.ui)
        
        GLM.load(true, m_Projection)
    }
    
    private func lookAt(_ pPosition: UnsafePointer<GLfloat>) {
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
        
        if mnActiveDemo == 0 && m_Flag.IsEarthView {
            let pEye = pPosition + 3472;
            
            m_Eye = Float3(pEye[0], pEye[1], pEye[2])
        } else {
            m_Eye = Float3(-m_Property.ViewDistance, 0.0, 0.0)
        }
        
        m_ModelView = GLM.lookAt(m_Eye, m_Center, m_Up)
        
        glMatrixMode(GL_MODELVIEW.ui)
        
        GLM.load(false, m_ModelView)
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
    
    private func render(_ pPosition: UnsafePointer<GLfloat>) {
        glViewport(0, 0, m_Bounds[0], m_Bounds[1])
        
        glBlendFunc(GL_ONE.ui, GL_ONE.ui)
        glEnable(GL_BLEND.ui)
        do {
            mpProgram.enable()
            do {
                glActiveTexture(GL_TEXTURE0.ui)
                
                glEnableClientState(GL_VERTEX_ARRAY.ui)
                do {
                    glBindBuffer(GL_ARRAY_BUFFER.ui, m_Graphic.BufferID)
                    do {
                        glBufferSubData(GL_ARRAY_BUFFER.ui, 0, m_Graphic.BufferSize, pPosition)
                        glVertexPointer(4, GL_FLOAT.ui, 0, nil)
                    }
                    glBindBuffer(GL_ARRAY_BUFFER.ui, 0)
                    
                    if !m_Flag.IsResetting {
                        let rotFactor = 1.0 - 0.5 * (1.0 + cosf(m_Property.RotationSpeed))
                        
                        m_Rotation.x += 1.6 * m_Property.TimeScale.g * rotFactor.g
                        m_Rotation.y += 0.8 * m_Property.TimeScale.g * rotFactor.g
                    }
                    
                    if mnActiveDemo != 0 || !m_Flag.IsEarthView {
                        let r1 = GLM.rotate(m_Rotation.y.f, 1.0, 0.0, 0.0)
                        let r2 = GLM.rotate(m_Rotation.x.f, 0.0, 1.0, 0.0)
                        
                        GLM.load(false, r2 * r1 * m_ModelView)
                    }
                    
                    glUniform1f(m_Graphic.LocPointSize,
                        m_Property.StarSize * mpProperties[mnActiveDemo].mnPointSize)
                    
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
                            300 * mpProperties[mnActiveDemo].mnPointSize)
                        
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
                        
                        for i in stride(from: (0 as GLsizei), to: m_Graphic.BufferCount / 84, by: Int(step)) {
                            glDrawArrays(GL_POINTS.ui, i, 1)
                        }
                        
                        // blue
                        glColor3f(0.04, 0.001, 0.08)
                        
                        for i in stride(from: (64 as GLsizei), to: m_Graphic.BufferCount / 84, by: Int(step)) {
                            glDrawArrays(GL_POINTS.ui, i, 1)
                        }
                    }
                    
                    glBindTexture(GL_TEXTURE_2D.ui, 0)
                    
                    glColor3f(1.0, 1.0, 1.0)
                }
                glDisableClientState(GL_VERTEX_ARRAY.ui)
            }
            mpProgram.disable()
        }
        glDisable(GL_BLEND.ui)
    }
    
    //MARK: -
    //MARK: Private - Utilities - Assets
    
    private func buffer(_ nCount: Int) -> Bool {
        m_Graphic.BufferID = 0
        m_Graphic.BufferCount = GLsizei(nCount)
        m_Graphic.BufferSize  = 4 * GLsizeiptr(m_Graphic.BufferCount) * GLM.Size.kFloat
        
        glEnableClientState(GL_VERTEX_ARRAY.ui)
        
        glGenBuffers(1, &m_Graphic.BufferID)
        do {
            if m_Graphic.BufferID != 0 {
                glBindBuffer(GL_ARRAY_BUFFER.ui, m_Graphic.BufferID)
                do {
                    glBufferData(GL_ARRAY_BUFFER.ui, m_Graphic.BufferSize, nil, GL_DYNAMIC_DRAW.ui)
                    glVertexPointer(4, GL_FLOAT.ui, 0, nil)
                }
                glBindBuffer(GL_ARRAY_BUFFER.ui, 0)
            }
            glDisableClientState(GL_VERTEX_ARRAY.ui)
        }
        return m_Graphic.BufferID != 0
    }
    
    private func textures(_ pName: String, _ pExt: String, _ texRes: Int = 32) -> Bool {
        mpTexture = GLU.Texture(pName, pExt)
        
        mpGausssian = GLU.Gaussian(texRes)
        
        return mpTexture.texture != 0 && mpGausssian.texture != 0
    }
    
    private func program(_ pName: String) -> Bool {
        mpProgram = GLU.Program(name: pName, inType: GL_POINTS.ui, outType: GL_TRIANGLE_STRIP.ui, outVert: 4)
        
        let nPID = mpProgram.program
        
        if nPID != 0 {
            mpProgram.enable()
            do {
                m_Graphic.LocSampler2D = glGetUniformLocation(nPID, "splatTexture")
                m_Graphic.LocPointSize = glGetUniformLocation(nPID, "pointSize")
                
                glUniform1i(m_Graphic.LocSampler2D, 0)
            }
            mpProgram.disable()
        }
        
        return nPID != 0
    }
    
    private func acquire(_ rProperties: NBody.Simulation.Properties?) -> Bool {
        var bSuccess = rProperties?.mnParticles ?? 0 > 0
        
        if bSuccess {
            bSuccess = buffer(rProperties!.mnParticles)
                && textures("star", "png")
                && program("nbody")
        }
        
        return bSuccess
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(_ rProperties: NBody.Simulation.Properties?) {
        self.init()
        m_Flag.IsAcquired = acquire(rProperties)
        
        if m_Flag.IsAcquired {
            m_Property.RotationDelta = NBody.Defaults.kRotationDelta.f
            m_Property.ViewDistance = NBody.Defaults.kViewDistance.f
            m_Property.ViewZoomSpeed = NBody.Defaults.kScrollZoomSpeed.f
            m_Property.TimeScale = NBody.Scale.kTime.f
            m_Property.StarScale = NBody.Star.kScale.f
            m_Property.StarSize = NBody.Star.kSize.f * m_Property.StarScale
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
            mnCount          = rProperties!.mnDemos;
            mpProperties     = NBody.Simulation.Properties.create()
            mnActiveDemo     = 0
            m_Rotation.x     = 0.0
            m_Rotation.y     = 0.0
            m_ViewRotation.x = 0.0
            m_ViewRotation.y = 0.0
            
            m_ModelView  = Float4x4(0.0);
            m_Projection = Float4x4(0.0);
            
            m_Eye    = Float3(0.0);
            m_Center = Float3(0.0);
            m_Up     = Float3(0.0, 1.0, 0.0)
        }
    }
    
    //MARK: -
    //MARK: Public - Destructor
    
    fileprivate func destruct() {
        if m_Graphic.BufferID != 0 {
            
            glDeleteBuffers(1, &m_Graphic.BufferID);
            
            m_Graphic.BufferID = 0
        }
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public func reset(_ nDemo: Int) {
        if nDemo < mnCount && !mpProperties.isEmpty {
            mnActiveDemo = nDemo
            
            m_Property.ViewDistance = mpProperties[nDemo].mnViewDistance
            
            m_Rotation.x = mpProperties[nDemo].mnRotateX
            m_Rotation.y = mpProperties[nDemo].mnRotateY
        }
    }
    
    public func draw(_ pPosition: UnsafePointer<GLfloat>?) {
        if pPosition != nil {
            update()
            
            projection()
            lookAt(pPosition!)
            
            render(pPosition!)
        }
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
    
    public var valid: Bool {
        return m_Flag.IsAcquired
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public var eye: Float3 {
        return m_Eye
    }
    
    public func setIsResetting(_ bReset: Bool) {
        m_Flag.IsResetting = bReset
    }
    
    public func setShowEarthView(_ bShowView: Bool) {
        m_Flag.IsEarthView = bShowView
    }
    
    public func setFrame(_ rFrame: CGSize) {
        if rFrame.width >= NBody.Window.kWidth.g && rFrame.height >= NBody.Window.kHeight.g {
            m_Frame = rFrame
            m_Bounds[0] = GLsizei(m_Frame.width + 0.5)
            m_Bounds[1] = GLsizei(m_Frame.height + 0.5)
        }
    }
    
    public func setProperties(_ nPropertiesCount: Int,
        _ Properties: [NBody.Simulation.Properties]) -> Bool {
            var bSuccess = m_Flag.IsAcquired
            
            if bSuccess {
                let pDecriptorDst = NBody.Simulation.Properties.create(nPropertiesCount)
                
                bSuccess = !pDecriptorDst.isEmpty
                
                if bSuccess {
                    mpProperties = pDecriptorDst
                    mnCount = nPropertiesCount
                }
            }
            
            return bSuccess
    }
    
    public func setRotation(_ rRotation: CGPoint) {
        m_Rotation = rRotation
    }
    
    public func setRotationChange(_ nDelta: GLfloat) {
        m_Property.RotationDelta = nDelta
    }
    
    public func setRotationSpeed(_ nSpeed: GLfloat) {
        m_Property.RotationSpeed = nSpeed
    }
    
    public func setStarScale(_ nScale: GLfloat) {
        if nScale > 0.0 {
            m_Property.StarScale = nScale
        }
    }
    
    public func setStarSize(_ nSize: GLfloat) {
        if nSize > 0.0 {
            m_Property.StarSize = m_Property.StarScale * nSize
        }
    }
    
    public func setTimeScale(_ nScale: GLfloat) {
        m_Property.TimeScale = nScale
    }
    
    public func setViewDistance(_ nDelta: GLfloat) {
        m_Property.ViewDistance = m_Property.ViewDistance + nDelta * m_Property.ViewZoomSpeed
        
        if m_Property.ViewDistance < 1.0 {
            m_Property.ViewDistance = 1.0
        }
    }
    
    public func setViewTime(_ nResetTime: GLfloat) {
        m_Property.ViewTime = nResetTime
    }
    
    public func setViewRotation(_ rRotation: CGPoint) {
        m_ViewRotation = rRotation
    }
    
    public func setViewZoom(_ nZoom: GLfloat) {
        m_Property.ViewZoom = nZoom
    }
    
    public func setViewZoomSpeed(_ nSpeed: GLfloat) {
        m_Property.ViewZoomSpeed = nSpeed
    }
}
