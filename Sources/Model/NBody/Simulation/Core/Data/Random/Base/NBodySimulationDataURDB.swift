//
//  NBodySimulationDataURDB.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
 <codex>
 <abstract>
 Base class for generating random packed or split data sets for the cpu or gpu bound simulator using unifrom random distributuon.
 </abstract>
 </codex>
 */

import Foundation
import OpenGL
import simd

extension NBody.Simulation.Data {
    class URDB {
        
        var mnParticles: size_t = 0
        var mnConfig: NBody.Config = .random
        var m_Scale: [GLfloat] = [0, 0]
        var m_Axis: Float3 = Float3()
        var m_DQueue: DispatchQueue
        var mpGenerator: [CM.URD3.Generator]
        
        init(_ rProperties: NBody.Simulation.Properties) {
            let queue = CF.Queue()
            
            m_DQueue = queue.createQueue("com.apple.nbody.simulation.data.urdb")
            
            m_Axis = Float3(0.0, 0.0, 1.0)
            
            mnParticles = rProperties.mnParticles
            mnConfig    = rProperties.mnConfig
            
            m_Scale[0] = rProperties.mnClusterScale
            m_Scale[1] = rProperties.mnVelocityScale
            
            mpGenerator = [
                CM.URD3.Generator(),
                CM.URD3.Generator(min: -1.0, max: 1.0, len: 1.0)
            ]
        }
        
        var axis: Float3 {
            get {
                return m_Axis
            }
            
            set {
                m_Axis = normalize(newValue)
            }
        }
        
        func setProperties(_ rProperties: NBody.Simulation.Properties) {
            mnParticles = rProperties.mnParticles
            mnConfig = rProperties.mnConfig
            
            m_Scale[0] = rProperties.mnClusterScale
            m_Scale[1] = rProperties.mnVelocityScale
        }
    }
}
