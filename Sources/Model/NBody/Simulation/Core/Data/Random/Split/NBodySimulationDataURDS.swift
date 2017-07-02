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
        
        private var mpMass: UnsafeMutablePointer<GLfloat>? = nil
        private var mpPosition: [UnsafeMutablePointer<GLfloat>] = []
        private var mpVelocity: [UnsafeMutablePointer<GLfloat>] = []
        
        //MARK: -
        //MARK: Private - Utilities
        
        private func configExpand() {
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = pscale * m_Scale[1]
            
            DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].rand()
                let velocity = vscale * position
                
                self.mpPosition[Axis.x.rawValue][i] = position.x
                self.mpPosition[Axis.y.rawValue][i] = position.y
                self.mpPosition[Axis.z.rawValue][i] = position.z
                
                self.mpVelocity[Axis.x.rawValue][i] = velocity.x
                self.mpVelocity[Axis.y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.z.rawValue][i] = velocity.z
                
                self.mpMass?[i] = 1.0
            }
        }
        
        private func configRandom() {
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
            let vscale = m_Scale[1] * pscale
            
            DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                let velocity = vscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                
                self.mpPosition[Axis.x.rawValue][i] = position.x
                self.mpPosition[Axis.y.rawValue][i] = position.y
                self.mpPosition[Axis.z.rawValue][i] = position.z
                
                self.mpMass?[i] = 1.0 // mass
                
                self.mpVelocity[Axis.x.rawValue][i] = velocity.x
                self.mpVelocity[Axis.y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.z.rawValue][i] = velocity.z
            }
        }
        
        private func configShell() {
            let pscale = m_Scale[0]
            let vscale = pscale * m_Scale[1]
            let inner  = 2.5 * pscale
            let outer  = 4.0 * pscale
            let length = outer - inner
            
            DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
                let nrpos    = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
                let rpos     = self.mpGenerator[NBody.RandIntervalLenIs.One].rand()
                let position = nrpos * (inner + (length * rpos))
                
                self.mpPosition[Axis.x.rawValue][i] = position.x
                self.mpPosition[Axis.y.rawValue][i] = position.y
                self.mpPosition[Axis.z.rawValue][i] = position.z
                
                self.mpMass?[i] = 1.0
                
                var axis = self.m_Axis
                
                let scalar = dot(nrpos, axis)
                
                if 1.0 - scalar < 1.0e-6 {
                    (axis.x,axis.y) = (nrpos.y, nrpos.x)
                    
                    axis = normalize(axis)
                }
                
                var velocity = Float3(
                    self.mpPosition[Axis.x.rawValue][i],
                    self.mpPosition[Axis.y.rawValue][i],
                    self.mpPosition[Axis.z.rawValue][i]
                )
                
                velocity = vscale * cross(velocity, axis)
                
                self.mpVelocity[Axis.x.rawValue][i] = velocity.x
                self.mpVelocity[Axis.y.rawValue][i] = velocity.y
                self.mpVelocity[Axis.z.rawValue][i] = velocity.z
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
                    
                    mpMass?[i] = mscale * vec[0]
                    
                    position  = Float3(vec[1], vec[2], vec[3])
                    position *= pscale
                    
                    mpPosition[Axis.x.rawValue][i] = position.x
                    mpPosition[Axis.y.rawValue][i] = position.y
                    mpPosition[Axis.z.rawValue][i] = position.z
                    
                    velocity  = Float3(vec[4], vec[5], vec[6])
                    velocity *= vscale
                    
                    mpVelocity[Axis.x.rawValue][i] = velocity.x
                    mpVelocity[Axis.y.rawValue][i] = velocity.y
                    mpVelocity[Axis.z.rawValue][i] = velocity.z
                    
                    i += 1
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
        
        @discardableResult
        func setTo(_ pSplit: Split) -> Bool {
            
            mpMass = pSplit.mass()
            
            mpPosition = [pSplit.position(.x),
             pSplit.position(.y),
             pSplit.position(.z)]
            
            mpVelocity = [pSplit.velocity(.x),
             pSplit.velocity(.y),
             pSplit.velocity(.z)]
            
            switch mnConfig {
            case .shell:
                configShell()
                
            case .mwm31:
                configMWM31()
                
            case .expand:
                configExpand()
                
            case .random:
                configRandom()
            }
            
            return true
        }
    }
}
