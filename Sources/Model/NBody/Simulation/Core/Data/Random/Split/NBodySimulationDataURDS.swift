//
//  NBodySimulationDataURDS.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
 <codex>
 <abstract>
 Functor for generating random split-data sets for the cpu or gpu bound simulator using uniform random distribution.
 </abstract>
 </codex>
 */

import Foundation
import OpenGL
import simd

//MARK: -
//MARK: Private - Namespace

extension NBody.Simulation.Data {
    class URDS: URDB {
        
        private var mnCount: GLfloat = 0.0
        private var mnBCScale: GLfloat = 0.0
        
        private var mpMass: UnsafeMutablePointer<GLfloat> = nil
        private var mpPosition: [UnsafeMutablePointer<GLfloat>] = Array(count: 3, repeatedValue: nil)
        private var mpVelocity: [UnsafeMutablePointer<GLfloat>] = Array(count: 3, repeatedValue: nil)
        
        //MARK: -
        //MARK: Private - Utilities
        
        private func configExpand() {
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = pscale * m_Scale[1]
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].rand()
                let velocity = vscale * position
                
                self.mpPosition[Axis.X.rawValue][i] = position.x
                self.mpPosition[Axis.Y.rawValue][i] = position.y
                self.mpPosition[Axis.Z.rawValue][i] = position.z
                
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
                
                self.mpMass[i] = 1.0
            }
        }
        
        private func configRandom() {
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = m_Scale[1] * pscale
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                let velocity = vscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                
                self.mpPosition[Axis.X.rawValue][i] = position.x
                self.mpPosition[Axis.Y.rawValue][i] = position.y
                self.mpPosition[Axis.Z.rawValue][i] = position.z
                
                self.mpMass[i] = 1.0 // mass
                
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
            }
        }
        
        private func configShell() {
            let pscale = m_Scale[0]
            let vscale = pscale * m_Scale[1]
            let inner  = 2.5 * pscale
            let outer  = 4.0 * pscale
            let length = outer - inner
            
            dispatch_apply(mnParticles, m_DQueue) {i in
                let nrpos    = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                let rpos     = self.mpGenerator[NBody.RandIntervalLenIs.One].rand()
                let position = nrpos * (inner + (length * rpos))
                
                self.mpPosition[Axis.X.rawValue][i] = position.x
                self.mpPosition[Axis.Y.rawValue][i] = position.y
                self.mpPosition[Axis.Z.rawValue][i] = position.z
                
                self.mpMass[i] = 1.0
                
                var axis = self.m_Axis
                
                let scalar = dot(nrpos, axis)
                
                if 1.0 - scalar < 1.0e-6 {
                    (axis.x,axis.y) = (nrpos.y, nrpos.x)
                    
                    axis = normalize(axis)
                }
                
                var velocity = Float3(
                    self.mpPosition[Axis.X.rawValue][i],
                    self.mpPosition[Axis.Y.rawValue][i],
                    self.mpPosition[Axis.Z.rawValue][i]
                )
                
                velocity = vscale * cross(velocity, axis)
                
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
            }
        }
        
        private func configMWM31() {
            let galaxy = NBody.Simulation.Data.Galaxy(mnParticles)
            
            if galaxy.rows != 0 {
                // The Milky-Way (MW) seems to be on a collision course with our
                // neighbour spiral galaxy Andromeda (M31)
                
                let pscale = m_Scale[0]
                let vscale = pscale * m_Scale[1]
                let mscale = pscale * pscale * pscale
                
                //var numPoints = 0   //### not used
                
                var position: Float3 = Float3()
                var velocity: Float3 = Float3()
                
                var i = 0
                
                while !galaxy.eof {
                    //numPoints++
                    
                    let vec = galaxy.floats()
                    
                    mpMass[i] = mscale * vec[0]
                    
                    position  = Float3(vec[1], vec[2], vec[3])
                    position *= pscale
                    
                    mpPosition[Axis.X.rawValue][i] = position.x
                    mpPosition[Axis.Y.rawValue][i] = position.y
                    mpPosition[Axis.Z.rawValue][i] = position.z
                    
                    velocity  = Float3(vec[4], vec[5], vec[6])
                    velocity *= vscale
                    
                    mpVelocity[Axis.X.rawValue][i] = velocity.x
                    mpVelocity[Axis.Y.rawValue][i] = velocity.y
                    mpVelocity[Axis.Z.rawValue][i] = velocity.z
                    
                    i++
                }
            }
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        override init(_ rProperties: NBody.Simulation.Properties) {
            super.init(rProperties)
            mnCount   = GLfloat(mnParticles)
            mnBCScale = mnCount / 1024.0
        }
        
        func setTo(pSplit: Split) -> Bool {
            
            mpMass = pSplit.mass()
            
            mpPosition[Axis.X.rawValue] = pSplit.position(.X)
            mpPosition[Axis.Y.rawValue] = pSplit.position(.Y)
            mpPosition[Axis.Z.rawValue] = pSplit.position(.Z)
            
            mpVelocity[Axis.X.rawValue] = pSplit.velocity(.X)
            mpVelocity[Axis.Y.rawValue] = pSplit.velocity(.Y)
            mpVelocity[Axis.Z.rawValue] = pSplit.velocity(.Z)
            
            switch mnConfig {
            case .Shell:
                configShell()
                
            case .MWM31:
                configMWM31()
                
            case .Expand:
                configExpand()
                
            case .Random:
                configRandom()
            }
            
            return true
        }
    }
}
