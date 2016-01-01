//
//  NBodySimulationDataURDP.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
 <codex>
 <abstract>
 Functor for generating random packed-data sets for the cpu or gpu bound simulator using uniform random distribution.
 </abstract>
 </codex>
 */

import Foundation
import OpenGL.GL
import simd

//MARK: -
//MARK: Private - Namespace

extension NBody.Simulation.Data {
    class URDP: URDB {
        
        private var mnCount: GLfloat = 0.0
        private var mnBCScale: GLfloat = 0.0
        private var mnTCScale: GLfloat = 0.0
        private var mnVCScale: GLfloat = 0.0
        
        //MARK: -
        //MARK: Private - Constants
        
        private let kBodyCountScale: GLfloat = 1.0 / 16384.0
        
        //MARK: -
        //MARK: Private - Utilities
        
        private func configExpand(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
            let pscale  = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = pscale * m_Scale[1]
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].rand()
                let velocity = vscale * position
                
                pPosition[i] = Float4(position.x, position.y, position.z, 1.0)
                
                pVelocity[i] = Float4(velocity.x, velocity.y, velocity.z, 1.0)
            }
        }
        
        private func configRandom(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = m_Scale[1] * pscale
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let p = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                pPosition[i] = pscale * Float4(p.x, p.y, p.z, 1.0/* mass */)
                
                let v = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                pVelocity[i] = vscale * Float4(v.x, v.y, v.z, 1.0/* inverse mass*/)
            }
        }
        
        private func configShell(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
            let pscale = m_Scale[0]
            let vscale = pscale * m_Scale[1]
            let inner  = 2.5 * pscale
            let outer  = 4.0 * pscale
            let length = outer - inner
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let nrpos    = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                let rpos     = self.mpGenerator[NBody.RandIntervalLenIs.One].rand()
                let position = nrpos * (inner + (length * rpos))
                
                pPosition[i] = Float4(position.x, position.y, position.z, self.mnTCScale)
                
                var axis = self.m_Axis
                
                let scalar = dot(nrpos, axis)
                
                if (1.0 - scalar) < 1e-6 {
                    (axis.x, axis.y) = (nrpos.y, nrpos.x)
                    
                    axis = normalize(axis)
                }
                
                let velocity = vscale * cross(position, axis)
                
                pVelocity[i] = Float4(velocity.x, velocity.y, velocity.z, self.mnVCScale)
            }
        }
        
        private func configMWM31(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
            let df = Galaxy(mnParticles)
            
            if df.rows != 0 {
                // The Milky-Way (MW) seems to be on a collision course with our
                // neighbour spiral galaxy Andromeda (M31)
                
                let pscale = m_Scale[0]
                let vscale = pscale * m_Scale[1]
                let mscale = pscale * pscale * pscale
                
                //var numPoints = 0   //### not used
                
                var mass: GLfloat = 0.0
                
                var position: Float3 = Float3()
                var velocity: Float3 = Float3()
                
                var i = 0
                
                while !df.eof {
                    //numPoints++
                    
                    let vec = df.floats()
                    
                    mass = vec[0] * mscale
                    
                    position = Float3(vec[1], vec[2], vec[3])
                    
                    let p = pscale * position
                    pPosition[i] = Float4(p.x, p.y, p.z, mass)
                    
                    velocity = Float3(vec[4], vec[5], vec[6])
                    
                    let v = vscale * velocity
                    pVelocity[i] = Float4(v.x, v.y, v.z, 1.0 / mass)
                    
                    ++i //### was missing
                }
            }
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        override init(_ rProperties: NBody.Simulation.Properties) {
            super.init(rProperties)
            mnCount   = GLfloat(mnParticles)
            mnBCScale = mnCount / 1024.0
            mnTCScale = 16384.0 / mnCount
            mnVCScale = kBodyCountScale * mnCount
        }
        
        func setTo(pInPosition: UnsafeMutablePointer<GLfloat>,
            _ pInVelocity: UnsafeMutablePointer<GLfloat>) -> Bool
        {
            guard pInPosition != nil && pInVelocity != nil else {return false}
            
            let pPosition = UnsafeMutablePointer<Float4>(pInPosition)
            let pVelocity = UnsafeMutablePointer<Float4>(pInVelocity)
            
            switch mnConfig {
            case .Shell:
                configShell(pPosition, pVelocity)
                
            case .MWM31:
                configMWM31(pPosition, pVelocity)
                
            case .Expand:
                configExpand(pPosition, pVelocity)
                
            case .Random:
                configRandom(pPosition, pVelocity)
            }
            
            return true
        }
    }
}
