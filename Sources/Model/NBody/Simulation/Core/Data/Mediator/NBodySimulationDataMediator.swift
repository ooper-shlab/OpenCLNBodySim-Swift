//
//  NBodySimulationDataMediator.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
     File: NBodySimulationDataMediator.h
     File: NBodySimulationDataMediator.mm
 Abstract:
 Utility class for managing cpu bound device and host memories.

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

import Cocoa
import OpenGL
import OpenCL

extension NBody.Simulation.Data {
    public class Mediator {
        
        private var mnReadIndex: Int = 0
        private var mnWriteIndex: Int = 0
        private var mnBodies: Int = 0
        private var mpPacked: Packed!
        private var mpSplit: [Split!] = [nil, nil]
    }
}

//MARK: -
//MARK: Private - Namespace

extension NBody.Simulation.Data.Mediator {
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(nbodies: Int) {
        self.init()
        mnBodies     = nbodies
        mnReadIndex  = 0
        mnWriteIndex = 1
        mpPacked     = NBody.Simulation.Data.Packed(nbodies: mnBodies)
        mpSplit[0]   = NBody.Simulation.Data.Split(nbodies: mnBodies)
        mpSplit[1]   = NBody.Simulation.Data.Split(nbodies: mnBodies)
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public func swap() {
        Swift.swap(&mnReadIndex, &mnWriteIndex)
    }
    
    public func acquire(pContext: cl_context) -> Int {
        var err = mpSplit[0].acquire(pContext)
        
        if err == CL_SUCCESS.l {
            err = mpSplit[1].acquire(pContext)
            
            if err == CL_SUCCESS.l {
                err = mpPacked.acquire(pContext)
            }
        }
        
        return err
    }
    
    public func bind(pKernel: cl_kernel) -> Int {
        var err = mpSplit[mnWriteIndex].bind(0, kernel: pKernel)
        
        if err == CL_SUCCESS.l {
            err = mpSplit[mnReadIndex].bind(6, kernel: pKernel)
            
            if err == CL_SUCCESS.l {
                err = mpPacked.bind(12, kernel: pKernel)
            }
        }
        
        return 0
    }
    
    public func update(pKernel: cl_kernel) -> Int {
        var err = mpSplit[mnWriteIndex].bind(0, kernel: pKernel)
        
        if err == CL_SUCCESS.l {
            err = mpSplit[mnReadIndex].bind(6, kernel: pKernel)
            
            if err == CL_SUCCESS.l {
                err = mpPacked.update(12, kernel: pKernel)
            }
        }
        
        return err
    }
    
    public func reset(rParams: NBody.Simulation.Params) {
        let rand = NBody.Simulation.Data.Random(nbodies: mnBodies, params: rParams)
        
        rand>>>(mpSplit[mnReadIndex], mpPacked)
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public func position() -> UnsafePointer<GLfloat> {
        return UnsafePointer(mpPacked.position)
    }
    
    public func positionInRange(nMin: Int,
        max nMax: Int,
        var dst pDst: UnsafeMutablePointer<GLfloat>)
        -> Int {
            var err = CL_INVALID_VALUE.l
            
            if pDst != nil {
                let offset = nMin * 4
                
                pDst = pDst.advancedBy(nMin)
                
                let pPackedPosition = mpPacked.position
                
                for i in nMin..<nMax {
                    let j = 4 * i
                    
                    pDst[j]   = pPackedPosition[j]
                    pDst[j+1] = pPackedPosition[j+1]
                    pDst[j+2] = pPackedPosition[j+2]
                    pDst[j+3] = pPackedPosition[j+3]
                }
                
                err = CL_SUCCESS.l
            }
            
            return err
    }
    
    public func position(nMax: Int, dst pDst: UnsafeMutablePointer<GLfloat>) -> Int {
        var err = CL_INVALID_VALUE.l
        
        if pDst != nil {
            let pPosition = mpPacked.position
            
            for i in 0..<nMax {
                let j = 4 * i
                
                pDst[j]   = pPosition[j]
                pDst[j+1] = pPosition[j+1]
                pDst[j+2] = pPosition[j+2]
                pDst[j+3] = pPosition[j+3]
            }
            
            err = CL_SUCCESS.l
        }
        
        return err
    }
    
    public func setPosition(pSrc: UnsafePointer<GLfloat>) -> Int {
        var err = CL_INVALID_VALUE.l
        
        if pSrc != nil {
            let pPosition  = mpPacked.position
            let pPositionX = mpSplit[mnReadIndex].position(.X)
            let pPositionY = mpSplit[mnReadIndex].position(.Y)
            let pPositionZ = mpSplit[mnReadIndex].position(.Z)
            
            for i in 0..<mnBodies {
                let j = 4 * i
                
                pPosition[j]   = pSrc[j]
                pPosition[j+1] = pSrc[j+1]
                pPosition[j+2] = pSrc[j+2]
                
                pPositionX[i] = pPosition[j]
                pPositionY[i] = pPosition[j+1];
                pPositionZ[i] = pPosition[j+2]
            }
            
            err = CL_SUCCESS.l
        }
        
        return err
    }
    
    public func velocity(pDest: UnsafeMutablePointer<GLfloat>) -> Int {
        var err = CL_INVALID_VALUE.l
        
        if pDest != nil {
            let pVelocityX = mpSplit[mnReadIndex].velocity(.X)
            let pVelocityY = mpSplit[mnReadIndex].velocity(.Y)
            let pVelocityZ = mpSplit[mnReadIndex].velocity(.Z)
            
            for i in 0..<mnBodies {
                let j = 4 * i
                
                pDest[j]   = pVelocityX[i]
                pDest[j+1] = pVelocityY[i]
                pDest[j+2] = pVelocityZ[i]
            }
            
        }
        
        return err
    }
    
    public func setVelocity(pSrc: UnsafePointer<GLfloat>) -> Int {
        var err = CL_INVALID_VALUE.l
        if pSrc != nil  {
            let pVelocityX = mpSplit[mnReadIndex].velocity(.X)
            let pVelocityY = mpSplit[mnReadIndex].velocity(.Y)
            let pVelocityZ = mpSplit[mnReadIndex].velocity(.Z)
            
            for i in 0..<mnBodies {
                let j = 4 * i
                
                pVelocityX[i] = pSrc[j]
                pVelocityY[i] = pSrc[j+1]
                pVelocityZ[i] = pSrc[j+2]
            }
            
            err = CL_SUCCESS.l
        }
        
        return err
    }
}