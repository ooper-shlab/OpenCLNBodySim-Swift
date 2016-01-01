//
//  NBodySimulationDataMediator.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
<codex>
<abstract>
Utility class for managing cpu bound device and host memories.
</abstract>
</codex>
 */

import Cocoa
import OpenGL
import OpenCL


//MARK: -
//MARK: Private - Namespace

extension NBody.Simulation.Data {
    public class Mediator {
        
        private var mnReadIndex: Int = 0
        private var mnWriteIndex: Int = 0
        private var mnParticles: Int = 0
        private var mpPacked: Packed
        private var mpSplit: [Split]
        private var m_Queue: dispatch_queue_t
        //MARK: -
        //MARK: Public - Constructor
        
        public init(_ rProperties: NBody.Simulation.Properties) {
            let queue = CF.Queue()
            
            mnParticles     = rProperties.mnParticles
            mnReadIndex  = 0
            mnWriteIndex = 1
            mpPacked     = NBody.Simulation.Data.Packed(rProperties)
            mpSplit   = [
                NBody.Simulation.Data.Split(rProperties),
                NBody.Simulation.Data.Split(rProperties)
            ]
            m_Queue      = queue.createQueue("com.apple.nbody.simulation.data.mediator.main");
        }
        
        //MARK: -
        //MARK: Public - Utilities
        
        public func swap() {
            Swift.swap(&mnReadIndex, &mnWriteIndex)
        }
        
        public func acquire(pContext: cl_context) -> cl_int {
            var err = mpSplit[0].acquire(pContext)
            
            if err == CL_SUCCESS {
                err = mpSplit[1].acquire(pContext)
                
                if err == CL_SUCCESS {
                    err = mpPacked.acquire(pContext)
                }
            }
            
            return err
        }
        
        public func bind(pKernel: cl_kernel) -> cl_int {
            var err = mpSplit[mnWriteIndex].bind(0, pKernel)
            
            if err == CL_SUCCESS {
                err = mpSplit[mnReadIndex].bind(6, pKernel)
                
                if err == CL_SUCCESS {
                    err = mpPacked.bind(13, pKernel)
                }
            }
            
            return err
        }
        
        public func update(pKernel: cl_kernel) -> cl_int {
            var err = mpSplit[mnWriteIndex].bind(0, pKernel)
            
            if err == CL_SUCCESS {
                err = mpSplit[mnReadIndex].bind(6, pKernel)
                
                if err == CL_SUCCESS {
                    err = mpPacked.update(13, pKernel)
                }
            }
            
            return err
        }
        
        public func reset(rProperties: NBody.Simulation.Properties) {
            let urds = URDS(rProperties)
            
            urds.setTo(mpSplit[mnReadIndex])
            
            let copier = Copier(mnParticles)
            
            copier.copy(mpSplit[mnReadIndex], to: mpPacked);
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        public var data: UnsafePointer<GLfloat> {
            return UnsafePointer(mpPacked.data)
        }
        
        public func positionInRange(range: CFRange,
            var _ pDst: UnsafeMutablePointer<GLfloat>)
            -> GLint
        {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                let nMin = (range.location > 0) ? range.location : 0;
                let nMax = (range.length   > 0) ? range.length   : (mnParticles - nMin + 1);
                
                let nOffset = nMin * 4
                
                pDst = pDst.advancedBy(nOffset)
                
                let pData = mpPacked.data
                
                dispatch_apply(nMax, m_Queue) {i in
                    let j = 4 * i + nMin
                    
                    pDst[j]   = pData[j]
                    pDst[j+1] = pData[j+1]
                    pDst[j+2] = pData[j+2]
                    pDst[j+3] = pData[j+3]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        public func positionInRange(nMin: size_t,
            _ nMax: size_t,
            _ pDst: UnsafeMutablePointer<GLfloat>) -> GLint
        {
            let nLen  = (nMax != 0) ? (nMax - nMin + 1) : mnParticles;
            let range = CFRangeMake(nMin, nLen);
            
            return positionInRange(range, pDst);
        } // positionInRange
        
        public func position(nMax: size_t,
            _ pDst: UnsafeMutablePointer<GLfloat>) -> GLint
        {
            var err = CL_INVALID_VALUE
            
            if pDst != nil {
                let pData = mpPacked.data
                
                dispatch_apply(nMax, m_Queue) {i in
                    let j = 4 * i
                    
                    pDst[j]   = pData[j]
                    pDst[j+1] = pData[j+1]
                    pDst[j+2] = pData[j+2]
                    pDst[j+3] = pData[j+3]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        public func setPosition(pSrc: UnsafePointer<GLfloat>) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pSrc != nil {
                let pData  = mpPacked.data
                
                let pPositionX = mpSplit[mnReadIndex].position(.X)
                let pPositionY = mpSplit[mnReadIndex].position(.Y)
                let pPositionZ = mpSplit[mnReadIndex].position(.Z)
                
                dispatch_apply(mnParticles, m_Queue) {i in
                    let j = 4 * i
                    
                    pData[j]   = pSrc[j]
                    pData[j+1] = pSrc[j+1]
                    pData[j+2] = pSrc[j+2]
                    
                    pPositionX[i] = pData[j]
                    pPositionY[i] = pData[j+1]
                    pPositionZ[i] = pData[j+2]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        public func velocity(pDest: UnsafeMutablePointer<GLfloat>) -> GLint {
            var err = CL_INVALID_VALUE
            
            if pDest != nil {
                let pVelocityX = mpSplit[mnReadIndex].velocity(.X)
                let pVelocityY = mpSplit[mnReadIndex].velocity(.Y)
                let pVelocityZ = mpSplit[mnReadIndex].velocity(.Z)
                
                dispatch_apply(mnParticles, m_Queue) {i in
                    let j = 4 * i
                    
                    pDest[j]   = pVelocityX[i]
                    pDest[j+1] = pVelocityY[i]
                    pDest[j+2] = pVelocityZ[i]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        public func setVelocity(pSrc: UnsafePointer<GLfloat>) -> GLint {
            var err = CL_INVALID_VALUE
            if pSrc != nil  {
                let pVelocityX = mpSplit[mnReadIndex].velocity(.X)
                let pVelocityY = mpSplit[mnReadIndex].velocity(.Y)
                let pVelocityZ = mpSplit[mnReadIndex].velocity(.Z)
                
                dispatch_apply(mnParticles, m_Queue) {i in
                    let j = 4 * i
                    
                    pVelocityX[i] = pSrc[j]
                    pVelocityY[i] = pSrc[j+1]
                    pVelocityZ[i] = pSrc[j+2]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
    }
}