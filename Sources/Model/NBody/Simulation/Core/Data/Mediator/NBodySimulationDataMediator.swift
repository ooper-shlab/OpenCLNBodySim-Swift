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
    open class Mediator {
        
        private var mnReadIndex: Int = 0
        private var mnWriteIndex: Int = 0
        private var mnParticles: Int = 0
        private var mpPacked: Packed
        private var mpSplit: [Split]
        private var m_Queue: DispatchQueue
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
        
        open func swap() {
            Swift.swap(&mnReadIndex, &mnWriteIndex)
        }
        
        open func acquire(_ pContext: cl_context?) -> cl_int {
            var err = mpSplit[0].acquire(pContext)
            
            if err == CL_SUCCESS {
                err = mpSplit[1].acquire(pContext)
                
                if err == CL_SUCCESS {
                    err = mpPacked.acquire(pContext)
                }
            }
            
            return err
        }
        
        open func bind(_ pKernel: cl_kernel?) -> cl_int {
            var err = mpSplit[mnWriteIndex].bind(0, pKernel)
            
            if err == CL_SUCCESS {
                err = mpSplit[mnReadIndex].bind(6, pKernel)
                
                if err == CL_SUCCESS {
                    err = mpPacked.bind(13, pKernel)
                }
            }
            
            return err
        }
        
        @discardableResult
        open func update(_ pKernel: cl_kernel?) -> cl_int {
            var err = mpSplit[mnWriteIndex].bind(0, pKernel)
            
            if err == CL_SUCCESS {
                err = mpSplit[mnReadIndex].bind(6, pKernel)
                
                if err == CL_SUCCESS {
                    err = mpPacked.update(13, pKernel)
                }
            }
            
            return err
        }
        
        open func reset(_ rProperties: NBody.Simulation.Properties) {
            let urds = URDS(rProperties)
            
            urds.setTo(mpSplit[mnReadIndex])
            
            let copier = Copier(mnParticles)
            
            copier.copy(mpSplit[mnReadIndex], to: mpPacked);
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        open var data: UnsafePointer<GLfloat> {
            return UnsafePointer(mpPacked.data)
        }
        
        open func positionInRange(_ range: CFRange,
            _ _pDst: UnsafeMutablePointer<GLfloat>?)
            -> GLint
        {
            var err = CL_INVALID_VALUE
            
            var pDst = _pDst
            if pDst != nil {
                let nMin = (range.location > 0) ? range.location : 0;
                let nMax = (range.length   > 0) ? range.length   : (mnParticles - nMin + 1);
                
                let nOffset = nMin * 4
                
                pDst = pDst!.advanced(by: nOffset)
                
                let pData = mpPacked.data
                
                DispatchQueue.concurrentPerform(iterations: nMax) {i in
                    let j = 4 * i + nMin
                    
                    pDst![j]   = pData[j]
                    pDst![j+1] = pData[j+1]
                    pDst![j+2] = pData[j+2]
                    pDst![j+3] = pData[j+3]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        open func positionInRange(_ nMin: size_t,
            _ nMax: size_t,
            _ pDst: UnsafeMutablePointer<GLfloat>) -> GLint
        {
            let nLen  = (nMax != 0) ? (nMax - nMin + 1) : mnParticles;
            let range = CFRangeMake(nMin, nLen);
            
            return positionInRange(range, pDst);
        } // positionInRange
        
        open func position(_ nMax: size_t,
            _ pDst: UnsafeMutablePointer<GLfloat>?) -> GLint
        {
            var err = CL_INVALID_VALUE
            
            if let pDst = pDst {
                let pData = mpPacked.data
                
                DispatchQueue.concurrentPerform(iterations: nMax) {i in
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
        
        open func setPosition(_ pSrc: UnsafePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if let pSrc = pSrc {
                let pData  = mpPacked.data
                
                let pPositionX = mpSplit[mnReadIndex].position(.x)
                let pPositionY = mpSplit[mnReadIndex].position(.y)
                let pPositionZ = mpSplit[mnReadIndex].position(.z)
                
                DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
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
        
        open func velocity(_ pDest: UnsafeMutablePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            
            if let pDest = pDest {
                let pVelocityX = mpSplit[mnReadIndex].velocity(.x)
                let pVelocityY = mpSplit[mnReadIndex].velocity(.y)
                let pVelocityZ = mpSplit[mnReadIndex].velocity(.z)
                
                DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
                    let j = 4 * i
                    
                    pDest[j]   = pVelocityX[i]
                    pDest[j+1] = pVelocityY[i]
                    pDest[j+2] = pVelocityZ[i]
                }
                
                err = CL_SUCCESS
            }
            
            return err
        }
        
        open func setVelocity(_ pSrc: UnsafePointer<GLfloat>?) -> GLint {
            var err = CL_INVALID_VALUE
            if let pSrc = pSrc {
                let pVelocityX = mpSplit[mnReadIndex].velocity(.x)
                let pVelocityY = mpSplit[mnReadIndex].velocity(.y)
                let pVelocityZ = mpSplit[mnReadIndex].velocity(.z)
                
                DispatchQueue.concurrentPerform(iterations: mnParticles) {i in
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
