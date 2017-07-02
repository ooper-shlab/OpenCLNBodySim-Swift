//
//  GLMTransforms.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility methods for linear transformations of projective geometry.
</abstract>
</codex>
 */

import simd
import OpenGL

extension GLM {
    
    //MARK: -
    //MARK: Private - Constants
    
    static let kIdentity: [GLfloat] = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    ]
    
    //MARK: -
    //MARK: Public - Transformations - Load
    //
    //simd::float4x4 GLMGetMatrix(const bool& transpose,
    //                            const GLenum& name)
    //{
    static func getMatrix(_ transpose: Bool, _ name: GLenum) -> Float4x4 {
        //    simd::float4x4 M = 0.0f;
        var M = Float4x4()
        //
        //    GLfloat m[16];
        var m: [GLfloat] = Array(repeating: 0, count: 16)
        //
        //    glGetFloatv(name, m);
        glGetFloatv(name, &m)
        //
        //    if(transpose)
        //    {
        if transpose {
            //        M.columns[0] = {m[0], m[1], m[2], m[3]};
            M[0] = Float4(m[0], m[1], m[2], m[3])
            //        M.columns[1] = {m[4], m[5], m[6], m[7]};
            M[1] = Float4(m[4], m[5], m[6], m[7])
            //        M.columns[2] = {m[8], m[9], m[10], m[11]};
            M[2] = Float4(m[8], m[9], m[10], m[11])
            //        M.columns[3] = {m[12], m[13], m[14], m[15]};
            M[3] = Float4(m[12], m[13], m[14], m[15])
            //    } // if
            //    else
            //    {
        } else {
            //        M.columns[0] = {m[0], m[4], m[8], m[12]};
            M[0] = Float4(m[0], m[4], m[8], m[12])
            //        M.columns[1] = {m[1], m[5], m[9], m[13]};
            M[1] = Float4(m[1], m[5], m[9], m[13])
            //        M.columns[2] = {m[2], m[6], m[10], m[14]};
            M[2] = Float4(m[2], m[6], m[10], m[14])
            //        M.columns[3] = {m[3], m[7], m[11], m[15]};
            M[3] = Float4(m[3], m[7], m[11], m[15])
            //    } // else
        }
        //
        //    return M;
        return M
        //} // GLMGetMatrix
    }
    //
    //simd::float4x4 GLM::modelview(const bool& transpose)
    //{
    static func modelview(_ transpose: Bool) -> Float4x4 {
        //    return GLMGetMatrix(transpose, GL_MODELVIEW_MATRIX);
        return getMatrix(transpose, GL_MODELVIEW_MATRIX.ui)
        //} // modelview
    }
    //
    //simd::float4x4 GLM::projection(const bool& transpose)
    //{
    static func projection(_ transpose: Bool) -> Float4x4 {
        //    return GLMGetMatrix(transpose, GL_PROJECTION_MATRIX);
        return getMatrix(transpose, GL_PROJECTION_MATRIX.ui)
        //} // projection
    }
    //
    //simd::float4x4 GLM::texture(const bool& transpose)
    //{
    static func texture(_ transpose: Bool) -> Float4x4 {
        //    return GLMGetMatrix(transpose, GL_TEXTURE_MATRIX);
        return getMatrix(transpose, GL_TEXTURE_MATRIX.ui)
        //} // texture
    }
    
    public static func load(_ transpose: Bool, _ M: Float4x4) {
        let m: [GLfloat]
        
        if transpose {
            m = [
                M[0,0],
                M[0,1],
                M[0,2],
                M[0,3],
                
                M[1,0],
                M[1,1],
                M[1,2],
                M[1,3],
                
                M[2,0],
                M[2,1],
                M[2,2],
                M[2,3],
                
                M[3,0],
                M[3,1],
                M[3,2],
                M[3,3],
            ]
        } else {
            m = [
                M[0,0],
                M[1,0],
                M[2,0],
                M[3,0],
                
                M[0,1],
                M[1,1],
                M[2,1],
                M[3,1],
                
                M[0,2],
                M[1,2],
                M[2,2],
                M[3,2],
                
                M[0,3],
                M[1,3],
                M[2,3],
                M[3,3],
            ]
        }
        
        glLoadMatrixf(m)
    }
    
    public static func identity(_ mode: GLenum) {
        glMatrixMode(mode)
        
        glLoadMatrixf(kIdentity)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Scale
    
    public static func scale(_ x: Float,
        _ y: Float,
        _ z: Float) -> Float4x4
    {
        let v = Float4(x, y, z, 1.0)
        
        return Float4x4(diagonal: v)
    }
    
    public static func scale(_ s: Float3) -> Float4x4 {
        let v = Float4(s.x, s.y, s.z, 1.0)
        
        return Float4x4(diagonal: v)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Translate
    
    public static func translate(_ t: Float3) -> Float4x4 {
        
        return Float4x4([
            Float4(1.0, 0.0, 0.0, 0.0),
            Float4(0.0, 1.0, 0.0, 0.0),
            Float4(0.0, 0.0, 1.0, 0.0),
            Float4(t.x, t.y, t.z, 1.0)
            ])
        
    }
    
    public static func translate(_ x: Float,
        _ y: Float,
        _ z: Float) -> Float4x4
    {
        
        return Float4x4([
            Float4(1, 0, 0, 0),
            Float4(0, 1, 0, 0),
            Float4(0, 0, 1, 0),
            Float4(x, y, z, 1)
            ])
        
    }
    
    //MARK: -
    //MARK: Public - Transformations - Rotate
    
    public static func rotate(_ angle: Float,
        _ r: Float3) -> Float4x4
    {
        let a = angle / 180.0
        var c: Float = 0.0
        var s: Float = 0.0
        
        // Computes the sine and cosine of pi times angle (measured in radians)
        // faster and gives exact results for angle = 90, 180, 270, etc.
        __sincospif(a, &s, &c)
        
        let k = 1.0 - c
        
        let u = normalize(r)
        let v = s * u
        let w = k * u
        
        let P = Float4(
            w.x * u.x + c,
            w.x * u.y - v.z,
            w.x * u.z + v.y,
            0.0)
        
        let Q = Float4(
            w.y * u.x + v.z,
            w.y * u.y + c,
            w.y * u.z - v.x,
            0.0)
        
        let R = Float4(
            w.z * u.x - v.y,
            w.z * u.y + v.x,
            w.z * u.z + c,
            0.0)
        
        let S = Float4(0.0, 0.0, 0.0, 1.0)
        
        return Float4x4([P, Q, R, S])
    }
    
    public static func rotate(_ r: Float4) -> Float4x4 {
        let R = Float3(r.x, r.y, r.z)
        
        return rotate(r.w, R)
    }
    
    public static func rotate(_ angle: Float,
        _ x: Float,
        _ y: Float,
        _ z: Float) -> Float4x4
    {
        let r = Float3(x, y, z)
        
        return rotate(angle, r)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Perspective
    
    public static func perspective(_ fovy: Float,
        _ aspect: Float,
        _ near: Float,
        _ far: Float) -> Float4x4
    {
        
        let a = GLM.kPiDiv360.f * fovy
        let f = 1.0 / tan(a)
        
        let sNear  = 2.0 * near
        let sDepth = 1.0 / (near - far)
        
        let P = Float4(f / aspect, 0, 0, 0)
        let Q = Float4(0, f, 0, 0)
        let R = Float4(0, 0, sDepth * (far + near), -1)
        let S = Float4(0, 0, 0, sNear * sDepth * far)
        
        return Float4x4([P, Q, R, S])
    }
    
    public static func perspective(_ fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4
    {
        let aspect = width / height
        
        return perspective(fovy, aspect, near, far)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Projection
    
    public static func projection(_ fovy: Float,
        _ aspect: Float,
        _ near: Float,
        _ far: Float) -> Float4x4
    {
        let sNear = 2.0 * near
        
        let a = GLM.kPiDiv360.f * fovy
        let f = near * tan(a)
        
        let left   = -f * aspect
        let right  =  f * aspect
        let bottom = -f
        let top    =  f
        
        let sWidth  = 1.0 / (right - left)
        let sHeight = 1.0 / (top - bottom)
        let sDepth  = 1.0 / (near - far)
        
        let P = Float4(sNear * sWidth, 0, 0, 0)
        let Q = Float4(0, sNear * sHeight, 0, 0)
        let R = Float4(0, 0, sDepth * (far + near), -1.0)
        let S = Float4(0, 0, sNear * sDepth * far, 0)
        
        return Float4x4([P, Q, R, S])
    }
    
    public static func projection(_ fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4
    {
        let aspect = width / height
        
        return projection(fovy, aspect, near, far)
    }
    
    //MARK: -
    //MARK: Public - Transformations - LookAt
    
    public static func lookAt(_ eye: Float3,
        _ center: Float3,
        _ up: Float3) -> Float4x4
    {
        let E = -eye
        let N = normalize(eye - center)
        let U = normalize(cross(up, N))
        let V = cross(N, U)
        
        let P = Float4(U.x, U.y, U.z, dot(U, E))
        
        let Q = Float4(V.x, V.y, V.z, dot(V, E))
        
        let R = Float4(N.x, N.y, N.z, dot(N, E))
        
        let S = Float4(0, 0, 0, 1)
        
        return Float4x4([P, Q, R, S])
    }
    
    public static func lookAt(_ pEye: [Float],
        _ pCenter: [Float],
        _ pUp: [Float]) -> Float4x4
    {
        let eye: Float3 = Float3(pEye[0], pEye[1], pEye[2])
        let center: Float3 = Float3(pCenter[0], pCenter[1], pCenter[2])
        let up: Float3 = Float3(pUp[0], pUp[1], pUp[2])
        
        return lookAt(eye, center, up)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Orthographic
    
    public static func ortho(_ left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let sWidth  = 1.0 / (right - left)
            let sHeight = 1.0 / (top   - bottom)
            let sDepth  = 1.0 / (far   - near)
            
            let P = Float4(2.0 * sWidth, 0, 0, 0)
            let Q = Float4(0, 2.0 * sHeight, 0, 0)
            let R = Float4(0, 0, -2.0 * sDepth, 0)
            let S = Float4(-sWidth  * (right + left),
                -sHeight * (top   + bottom),
                -sDepth  * (far   + near),
                1.0)
            
            return Float4x4([P, Q, R, S])
    }
    
    public static func ortho(_ left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float)
        -> Float4x4 {
            return ortho(left, right, bottom, top, 0.0, 1.0)
    }
    
    public static func ortho(_ origin: Float3,
        _ size: Float3) -> Float4x4
    {
        return ortho(origin.x, origin.y, origin.z, size.x, size.y, size.z)
    }
    
    //MARK: -
    //MARK: Public - Transformations - frustum
    
    public static func frustum(_ left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4
    {
        let sWidth  = 1.0 / (right - left)
        let sHeight = 1.0 / (top - bottom)
        let sDepth  = 1.0 / (near - far)
        let sNear   = 2.0 * near
        
        let P = Float4(sWidth  * sNear, 0, sWidth  * (right + left), 0)
        let Q = Float4(0, sHeight * sNear, sHeight * (top + bottom), 0)
        let R = Float4(0, 0, sDepth  * (far + near), sDepth  * sNear * far)
        let S = Float4(0, 0, 0, -1.0)
        
        return Float4x4([P, Q, R, S])
    }
    
    public static func frustum(_ fovy: Float,
        _ aspect: Float,
        _ near: Float,
        _ far: Float) -> Float4x4
    {
        let a = GLM.kPiDiv360.f * fovy
        let t = near * tan(a)
        
        var left: Float
        var right: Float
        var top: Float
        var bottom: Float
        
        if aspect >= 1.0 {
            right = aspect * t
            left = -right
            top = t
            bottom = -top
        } else {
            right = t
            left = -right
            top = t / aspect
            bottom = -top
        }
        
        return frustum(left, right, bottom, top, near, far)
    }
    
    public static func frustum(_ fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let aspect = width / height
            
            return frustum(fovy, aspect, near, far)
    }
}
