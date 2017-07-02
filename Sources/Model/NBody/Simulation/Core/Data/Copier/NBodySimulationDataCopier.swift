//
//  NBodySimulationDataCopier.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
 <codex>
 <abstract>
 Functor for copying split position data to/from packed position data.
 </abstract>
 </codex>
 */

import Foundation

extension NBody.Simulation.Data {
    class Copier {
        
        var mnCount: size_t = 0
        var m_Queue: DispatchQueue
        
        init(_ nCount: size_t) {
            let queue = CF.Queue()
            
            mnCount = nCount
            m_Queue = queue.createQueue("com.apple.nbody.simulation.data.copier.main")
        }
        
        @discardableResult
        func copy(_ pSplit: NBody.Simulation.Data.Split,
            to pPacked: NBody.Simulation.Data.Packed) -> Bool {
                
                let pData = pPacked.data
                
                let pMass = pSplit.mass()
                let pPositionX = pSplit.position(.x)
                let pPositionY = pSplit.position(.y)
                let pPositionZ = pSplit.position(.z)
                
                DispatchQueue.concurrentPerform(iterations: mnCount) {i in
                    let j = 4 * i
                    
                    pData[j]   = pPositionX[i]
                    pData[j+1] = pPositionY[i]
                    pData[j+2] = pPositionZ[i]
                    pData[j+3] = pMass[i]
                }
                
                return true
        }
        
        func copy(_ pPacked: NBody.Simulation.Data.Packed,
            to pSplit: NBody.Simulation.Data.Split) -> Bool {
                
                let pData = pPacked.data
                
                let pMass      = pSplit.mass()
                let pPositionX = pSplit.position(.x)
                let pPositionY = pSplit.position(.y)
                let pPositionZ = pSplit.position(.z)
                
                DispatchQueue.concurrentPerform(iterations: mnCount) {i in
                    let j = 4 * i
                    
                    pPositionX[i] = pData[j]
                    pPositionY[i] = pData[j+1]
                    pPositionZ[i] = pData[j+2]
                    pMass[i]      = pData[j+3]
                }
                
                return true
        }
    }
}
