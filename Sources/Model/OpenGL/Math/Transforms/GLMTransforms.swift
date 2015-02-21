//
//  GLMTransforms.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: GLMTransforms.h
     File: GLMTransforms.mm
 Abstract:
 Utility methods for linear transformations of projective geometry.

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

//import simd
import OpenGL

public typealias Float3 = (x: Float, y: Float, z: Float)
public typealias Float4 = (x: Float, y: Float, z: Float, w: Float)
public typealias Float4x4 = (x: Float4, y: Float4, z: Float4, w: Float4)
func * (r: Float, v: Float3) -> Float3 {
    return (r*v.x, r*v.y, r*v.z)
}
func * (r: Float, v: Float4) -> Float4 {
    return (r*v.x, r*v.y, r*v.z, r*v.w)
}
func * (v: Float3, r: Float) -> Float3 {
    return (r*v.x, r*v.y, r*v.z)
}
func * (v: Float4, r: Float) -> Float4 {
    return (r*v.x, r*v.y, r*v.z, r*v.w)
}
func *= (inout v: Float3, r: Float) {
    v = v * r
}
func *= (inout v: Float4, r: Float) {
    v = v * r
}
func *= (inout u: Float3, v: Float3) {
    u = (u.x*v.x, u.y*v.y, u.z*v.z)
}
func *= (inout u: Float4, v: Float4) {
    u = (u.x*v.x, u.y*v.y, u.z*v.z, u.w*v.w)
}
func / (v: Float3, r: Float) -> Float3 {
    return (v.x/r, v.y/r, v.z/r)
}
func / (v: Float4, r: Float) -> Float4 {
    return (v.x/r, v.y/r, v.z/r, v.w/r)
}
prefix func - (v: Float3) -> Float3 {
    return (-v.x, -v.y, -v.z)
}
prefix func - (v: Float4) -> Float4 {
    return (-v.x, -v.y, -v.z, -v.w)
}
func - (u: Float3, v: Float3) -> Float3 {
    return (u.x-v.x, u.y-v.y, u.z-v.z)
}
func - (u: Float4, v: Float4) -> Float4 {
    return (u.x-v.x, u.y-v.y, u.z-v.z, u.w-v.w)
}
func + (u: Float3, v: Float3) -> Float3 {
    return (u.x+v.x, u.y+v.y, u.z+v.z)
}
func + (u: Float4, v: Float4) -> Float4 {
    return (u.x+v.x, u.y+v.y, u.z+v.z, u.w+v.w)
}
func += (inout u: Float3, v: Float3) {
    u = (u.x+v.x, u.y+v.y, u.z+v.z)
}
func += (inout u: Float4, v: Float4) {
    u = (u.x+v.x, u.y+v.y, u.z+v.z, u.w+v.w)
}
func += (inout u: Float3, r: Float) {
    u = (u.x+r, u.y+r, u.z+r)
}
func += (inout u: Float4, r: Float) {
    u = (u.x+r, u.y+r, u.z+r, u.w+r)
}
extension GLM {
    public static func length(v: Float4) -> Float {
        return sqrtf(dot(v, v))
    }
    public static func length(v: Float3) -> Float {
        return sqrtf(dot(v, v))
    }
    public static func normalize(v: Float4) -> Float4 {
        let s = length(v)
        if s == 0.0 {
            return v
        }
        return v/s
    }
    public static func normalize(v: Float3) -> Float3 {
        let s = length(v)
        if s == 0.0 {
            return v
        }
        return v/s
    }
    public static func cross(a: Float3, _ b: Float3) -> Float3 {
        return (a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x)
    }
    public static func dot(u: Float3, _ v: Float3) -> Float {
        return u.x*v.x + u.y*v.y + u.z*v.z
    }
    public static func dot(u: Float4, _ v: Float4) -> Float {
        return u.x*v.x + u.y*v.y + u.z*v.z + u.w*v.w
    }
    public static func length_squared(v: Float3) -> Float {
        return dot(v, v)
    }
    public static func length_squared(v: Float4) -> Float {
        return dot(v, v)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Load
    
    public static func load(transpose: Bool, _ M: Float4x4) {
        
        if transpose {
            //var m = M
            var m: [GLfloat] = [
                M.x.x, M.x.y, M.x.z, M.x.w,
                
                M.y.x, M.y.y, M.y.z, M.y.w,
                
                M.z.x, M.z.y, M.z.z, M.z.w,
                
                M.w.x, M.w.y, M.w.z, M.w.w,
            ]
            glLoadMatrixf(m)
        } else {
            var m: [GLfloat] = [
                M.x.x, M.y.x, M.z.x, M.w.x,
                
                M.x.y, M.y.y, M.z.y, M.w.y,
                
                M.x.z, M.y.z, M.z.z, M.w.z,
                
                M.x.w, M.y.w, M.z.w, M.w.w,
            ]
            glLoadMatrixf(m)
        }
        
    }
    
    //MARK: -
    //MARK: Public - Transformations - Scale
    
    public static func scale(x: Float, y: Float, z: Float) -> Float4x4 {
        
        return (
            (x, 0, 0, 0),
            (0, y, 0, 0),
            (0, 0, z, 0),
            (0, 0, 0, 1)
        )
    }
    
    public static func scale(s: Float3) -> Float4x4 {
        
        return (
            (s.x, 0.0, 0.0, 0.0),
            (0.0, s.y, 0.0, 0.0),
            (0.0, 0.0, s.z, 0.0),
            (0.0, 0.0, 0.0, 1.0)
        )
    }
    
    //MARK: -
    //MARK: Public - Transformations - Translate
    
    public static func translate(t: Float3) -> Float4x4 {
        
        return (
            (1.0, 0.0, 0.0, 0.0),
            (0.0, 1.0, 0.0, 0.0),
            (0.0, 0.0, 1.0, 0.0),
            (t.x, t.y, t.z, 1.0)
        )
        
    }
    
    public static func translate(x: Float, y: Float, z: Float) -> Float4x4 {
        
        return (
            (1, 0, 0, 0),
            (0, 1, 0, 0),
            (0, 0, 1, 0),
            (x, y, z, 1)
        )
        
    }
    
    //MARK: -
    //MARK: Public - Transformations - Rotate
    
    public static func rotate(angle: Float, _ r: Float3) -> Float4x4 {
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
        
        let P: Float4 = (
            w.x * u.x + c,
            w.x * u.y - v.z,
            w.x * u.z + v.y,
            0)
        
        let Q: Float4 = (
            w.y * u.x + v.z,
            w.y * u.y + c,
            w.y * u.z - v.x,
            0)
        
        let R: Float4 = (
            w.z * u.x - v.y,
            w.z * u.y + v.x,
            w.z * u.z + c,
            0)
        
        let S: Float4 = (0, 0, 0, 0)
        
        return (P, Q, R, S)
    }
    
    public static func rotate(r: Float4) -> Float4x4 {
        let R: Float3 = (r.x, r.y, r.z)
        
        return rotate(r.w, R)
    }
    
    public static func rotate(angle: Float, _ x: Float, _ y: Float, _ z: Float) -> Float4x4 {
        
        return rotate(angle, (x, y, z))
    }
    
    //MARK: -
    //MARK: Public - Transformations - Perspective
    
    public static func perspective(fovy: Float, _ aspect: Float, _ near: Float, _ far: Float) -> Float4x4 {
        
        let a = GLM.kPiDiv360.f * fovy
        let f = 1.0 / tan(a)
        
        let sNear  = 2.0 * near
        let sDepth = 1.0 / (near - far)
        
        let P: Float4 = (f / aspect, 0, 0, 0)
        let Q: Float4 = (0, f, 0, 0)
        let R: Float4 = (0, 0, sDepth * (far + near), -1)
        let S: Float4 = (0, 0, 0, sNear * sDepth * far)
        
        return (P, Q, R, S)
    }
    
    public static func perspective(fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let aspect = width / height
            
            return perspective(fovy, aspect, near, far)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Projection
    
    public static func projection(fovy: Float, _ aspect: Float, _ near: Float, _ far: Float) -> Float4x4 {
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
        
        let P: Float4 = (sNear * sWidth, 0, 0, 0)
        let Q: Float4 = (0, sNear * sHeight, 0, 0)
        let R: Float4 = (0, 0, sDepth * (far + near), -1)
        let S: Float4 = (0, 0, sNear * sDepth * far, 0)
        
        return (P, Q, R, S)
    }
    
    public static func projection(fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let aspect = width / height
            
            return projection(fovy, aspect, near, far)
    }
    
    //MARK: -
    //MARK: Public - Transformations - LookAt
    
    public static func lookAt(eye: Float3, _ center: Float3, _ up: Float3) -> Float4x4 {
        let E = -1 * eye
        let N = normalize(eye - center)
        let U = normalize(cross(up, N))
        let V = cross(N, U)
        
        let P: Float4 = (U.x, U.y, U.z, dot(U, E))
        
        let Q: Float4 = (V.x, V.y, V.z, dot(V, E))
        
        let R: Float4 = (N.x, N.y, N.z, dot(N, E))
        
        let S: Float4 = (0, 0, 0, 1)
        
        return (P, Q, R, S)
    }
    
    public static func lookAt(pEye: [Float], _ pCenter: [Float], _ pUp: [Float]) -> Float4x4 {
        let eye: Float3 = (pEye[0], pEye[1], pEye[2])
        let center: Float3 = (pCenter[0], pCenter[1], pCenter[2])
        let up: Float3 = (pUp[0], pUp[1], pUp[2])
        
        return lookAt(eye, center, up)
    }
    
    //MARK: -
    //MARK: Public - Transformations - Orthographic
    
    public static func ortho(left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let sWidth  = 1.0 / (right - left)
            let sHeight = 1.0 / (top   - bottom)
            let sDepth  = 1.0 / (far   - near)
            
            let P: Float4 = (2.0 * sWidth, 0, 0, 0)
            let Q: Float4 = (0, 2.0 * sHeight, 0, 0)
            let R: Float4 = (0, 0, -2.0 * sDepth, 0)
            let S: Float4 = (-sWidth  * (right + left),
                -sHeight * (top   + bottom),
                -sDepth  * (far   + near),
                1.0)
            
            return (P, Q, R, S)
    }
    
    public static func ortho(left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float)
        -> Float4x4 {
            return ortho(left, right, bottom, top, 0, 1)
    }
    
    public static func ortho(origin: Float3,
        _ size: Float3) -> Float4x4 {
            return ortho(origin.x, origin.y, origin.z, size.x, size.y, size.z)
    }
    
    //MARK: -
    //MARK: Public - Transformations - frustum
    
    public static func frustum(left: Float,
        _ right: Float,
        _ bottom: Float,
        _ top: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let sWidth  = 1.0 / (right - left)
            let sHeight = 1.0 / (top - bottom)
            let sDepth  = 1.0 / (near - far)
            let sNear   = 2.0 * near
            
            let P: Float4 = (sWidth  * sNear, 0, sWidth  * (right + left), 0)
            let Q: Float4 = (0, sHeight * sNear, sHeight * (top + bottom), 0)
            let R: Float4 = (0, 0, sDepth  * (far + near), sDepth  * sNear * far)
            let S: Float4 = (0, 0, 0, 1)
            
            return (P, Q, R, S)
    }
    
    public static func frustum(fovy: Float, _ aspect: Float, _ near: Float, _ far: Float) -> Float4x4 {
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
    
    public static func frustum(fovy: Float,
        _ width: Float,
        _ height: Float,
        _ near: Float,
        _ far: Float)
        -> Float4x4 {
            let aspect = width / height
            
            return frustum(fovy, aspect, near, far)
    }
}