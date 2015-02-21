//
//  NBodySimulationRandom.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/31.
//
//
/*
     File: NBodySimulationRandom.h
     File: NBodySimulationRandom.mm
 Abstract:
 Functor for generating random data sets for the cpu or gpu bound simulator.

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
//import simd

extension NBody.Simulation.Data {
    public class Random {
        
        private var mnBodies: Int = 0
        private var mnConfig: NBody.Config = .Random
        private var m_Scale: [GLfloat] = [0, 0]
    }
}

//MARK: -
//MARK: Private - Constants

private var kGalaxyDataFiles: [String] = [
    "bodies_16k.dat",
    "bodies_24k.dat",
    "bodies_32k.dat",
    "bodies_64k.dat",
    "bodies_80k.dat",
]

private let kBodyCountScale = 1.0 / 16384.0
private let kRandMax        = RAND_MAX

extension NBody.Simulation.Data.Random {
    //MARK: -
    //MARK: Private - Utilities
    
    private func create(bIsClamped: Bool) -> Float3 {
        
        if bIsClamped {
            let x = rand().f / kRandMax.f * 2.0 - 1.0
            let y = rand().f / kRandMax.f * 2.0 - 1.0
            let z = rand().f / kRandMax.f * 2.0 - 1.0
            return (x,y,z)
        } else {
            let x = rand().f / kRandMax.f
            let y = rand().f / kRandMax.f
            let z = rand().f / kRandMax.f
            return (x,y,z)
        }
        
    }
    
    private func acquire(pPosition: UnsafeMutablePointer<GLfloat>,
        _ pVelocity: UnsafeMutablePointer<GLfloat>)
    {
        let fcount   = mnBodies.f
        let fbcscale = fcount / 1024.0
        let ftcscale = 16384.0 / fcount
        let fvcscale = kBodyCountScale.f * fcount
        
        switch mnConfig {
        case .Random:
            let scale  = m_Scale[0] * max(1.0, fbcscale)
            let vscale = m_Scale[1] * scale
            
            var p = 0
            var v = 0
            var i = 0
            
            var point: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            
            var scalar = 0.0.f
            
            while i < mnBodies {
                point = create(true)
                scalar = GLM.length_squared(point)
                
                if scalar > 1 {
                    continue
                }
                
                velocity = create(true)
                scalar = GLM.length_squared(velocity)
                
                if scalar > 1 {
                    continue
                }
                
                point *= scale
                velocity *= vscale
                
                pPosition[p++] = point.x
                pPosition[p++] = point.y
                pPosition[p++] = point.z
                pPosition[p++] = 1.0; // mass
                
                pVelocity[v++] = velocity.x
                pVelocity[v++] = velocity.y
                pVelocity[v++] = velocity.z
                pVelocity[v++] = 1.0; // inverse mass
                
                i++
            }
            
        case .Shell:
            let scale  = m_Scale[0]
            let vscale = scale * m_Scale[1]
            let inner  = 2.5 * scale
            let outer  = 4.0 * scale
            
            var p = 0
            var v = 0
            var i = 0
            
            var dot = 0.0.f
            var len = 0.0.f
            
            var point: Float3 = (0, 0, 0)
            
            var position: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            var axis: Float3 = (0, 0, 0)
            
            while i < mnBodies {
                point = create(true)
                len   = GLM.length(point)
                
                point = GLM.normalize(point)
                
                if len > 1 {
                    continue
                }
                
                position = create(false)
                position *= (outer - inner)
                position += inner
                position *= point
                
                pPosition[p++] = position.x
                pPosition[p++] = position.y
                pPosition[p++] = position.z
                pPosition[p++] = ftcscale
                
                axis = (0.0, 0.0, 1.0)
                axis = GLM.normalize(axis)
                dot  = GLM.dot(point, axis)
                
                if 1.0 - dot < 1e-6 {
                    axis.x = point.y
                    axis.y = point.x
                    
                    axis = GLM.normalize(axis)
                }
                
                velocity  = GLM.cross(position, axis)
                velocity *= vscale
                
                pVelocity[v++] = velocity.x
                pVelocity[v++] = velocity.y
                pVelocity[v++] = velocity.z
                pVelocity[v++] = fvcscale
                
                i++
            }
            
            // Galaxy collision
        case .MWM31:
            let scale  = m_Scale[0]
            let vscale = scale * m_Scale[1]
            let mscale = scale * scale * scale
            
            var p = 0
            var v = 0
            
            var infile: CF.IFStream
            
            switch mnBodies {
            case 16384:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[0])!
            case 24576:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[1])!
            case 32768:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[2])!
            case 65536:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[3])!
            case 81920:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[4])!
            default:
                fatalError(">> ERROR: Number of bodies must be one of 16384, 24576, 32768, 65536, 81920, 131072 or 1048576!")
                
            }
            
            var numPoints = 0
            
            var bMass: GLfloat = 0.0
            var bIDf: GLfloat = 0.0
            
            var value: [GLfloat] = [0, 0, 0, 0, 0, 0]
            
            var position: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            
            if infile.isValid {
                while !infile.eof && numPoints < mnBodies {
                    numPoints++
                    
                    infile >>> bMass
                        >>> value[0]
                        >>> value[1]
                        >>> value[2]
                        >>> value[3]
                        >>> value[4]
                        >>> value[5]
                        >>> bIDf
                    
                    position = (value[0], value[1], value[2])
                    velocity = (value[3], value[4], value[5])
                    
                    bMass *= mscale
                    
                    position *= scale
                    
                    pPosition[p++] = position.x
                    pPosition[p++] = position.y
                    pPosition[p++] = position.z
                    pPosition[p++] = bMass
                    
                    velocity *= vscale
                    
                    pVelocity[v++] = velocity.x
                    pVelocity[v++] = velocity.y
                    pVelocity[v++] = velocity.z
                    pVelocity[v++] = 1.0 / bMass
                }
            }
            
        case .Expand:
            let scale = m_Scale[0] * max(1.0.f, mnBodies.f / 1024)
            let vscale = scale * m_Scale[1]
            var lenSqr = 0.0.f
            
            var point: Float3 = (0.0, 0.0, 0.0)
            var position: Float3 = (0.0, 0.0, 0.0)
            var velocity: Float3 = (0.0, 0.0, 0.0)
            
            var p = 0
            var v = 0
            
            for var i = 0; i < mnBodies; {
                point = create(true)
                lenSqr = GLM.length_squared(point)
                
                if lenSqr > 1.0 {
                    continue
                }
                
                position *= scale
                
                pPosition[p++] = position.x
                pPosition[p++] = position.y
                pPosition[p++] = position.z
                pPosition[p++] = 1.0
                
                velocity *= vscale
                
                pVelocity[v++] = velocity.x
                pVelocity[v++] = velocity.y
                pVelocity[v++] = velocity.z
                pVelocity[v++] = 1.0
                
                i++
            }
            
        default:
            break
        }
    }
    
    private func acquire(pSplit: NBody.Simulation.Data.Split,
        _ pPacked: NBody.Simulation.Data.Packed)
    {
        let fcount = mnBodies.f
        let fbcscale = fcount / 1024.0
        
        let pMass = pPacked.mass
        
        let pPositionX = pSplit.position(.X)
        let pPositionY = pSplit.position(.Y)
        let pPositionZ = pSplit.position(.Z)
        
        let pVelocityX = pSplit.velocity(.X)
        let pVelocityY = pSplit.velocity(.Y)
        let pVelocityZ = pSplit.velocity(.Z)
        
        switch mnConfig {
        case .Random:
            let scale  = m_Scale[0] * max(1.0, fbcscale)
            let vscale = m_Scale[1] * scale
            var lenSqr = 0.0.f
            
            var p = 0
            var v = 0
            var i = 0
            
            var point: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            
            while i < mnBodies {
                point = create(true)
                lenSqr = GLM.length_squared(point)
                
                if lenSqr > 1.0 {
                    continue
                }
                
                velocity = create(true)
                lenSqr   = GLM.length_squared(velocity)
                
                if lenSqr > 1.0 {
                    continue
                }
                
                point *= scale
                
                pPositionX[p] = point.x
                pPositionY[p] = point.y
                pPositionZ[p] = point.z
                
                pMass[p] = 1.0 // mass
                
                velocity *= vscale
                
                pVelocityX[v] = velocity.x
                pVelocityY[v] = velocity.y
                pVelocityZ[v] = velocity.z
                
                p++
                v++
                i++
            }
            
        case .Shell:
            let scale  = m_Scale[0]
            let vscale = scale * m_Scale[1]
            let inner  = 2.5 * scale
            let outer  = 4.0 * scale
            var len    = 0.0.f
            var dot    = 0.0.f
            
            var p = 0
            var v = 0
            var i = 0
            
            var point: Float3 = (0, 0, 0)
            var position: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            var axis: Float3 = (0, 0, 0)
            
            while i < mnBodies {
                point = create(true)
                len   = GLM.length(point)
                point = GLM.normalize(point)
                
                if len > 1 {
                    continue
                }
                
                position = create(false)
                position *= (outer - inner)
                position += inner
                position *= point
                
                pPositionX[p] = position.x
                pPositionY[p] = position.y
                pPositionZ[p] = position.z
                
                pMass[p] = 1.0
                
                axis = (0.0, 0.0, 1.0)
                axis = GLM.normalize(axis)
                dot  = GLM.dot(point, axis)
                
                if 1.0 - dot < 1.0e-6 {
                    axis.x = point.y
                    axis.y = point.x
                    
                    axis = GLM.normalize(axis)
                }
                
                velocity = (pPositionX[i], pPositionY[i], pPositionZ[i])
                velocity = GLM.cross(velocity, axis)
                velocity *= vscale
                
                pVelocityX[v] = velocity.x
                pVelocityY[v] = velocity.y
                pVelocityZ[v] = velocity.z
                
                p++
                v++
                i++
            }
            
            // Galaxy collision
        case .MWM31:
            let scale = m_Scale[0]
            let vscale = scale * m_Scale[1]
            let mscale = scale * scale * scale
            
            var infile: CF.IFStream
            
            switch mnBodies {
            case 16384:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[0])!
            case 24576:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[1])!
            case 32768:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[2])!
            case 65536:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[3])!
            case 81920:
                infile = CF.IFStream(pathname: kGalaxyDataFiles[4])!
            default:
                fatalError(">> ERROR: Number of bodies must be one of 16384, 24576, 32768, 65536 or 81920!")
                
            }
            
            var numPoints = 0
            var p = 0
            
            var value:[GLfloat] = [0, 0, 0, 0, 0, 0]
            
            var position: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            
            var bMass = 0.0.f
            var bIDf = 0.0.f
            
            if infile.isValid {
                while !infile.eof && numPoints < mnBodies {
                    numPoints++
                    
                    infile >>> bMass
                        >>> value[0]
                        >>> value[1]
                        >>> value[2]
                        >>> value[3]
                        >>> value[4]
                        >>> value[5]
                        >>> bIDf
                    
                    position = (value[0], value[1], value[2])
                    velocity = (value[3], value[4], value[5])
                    
                    bMass *= mscale
                    
                    position *= scale
                    
                    pPositionX[p] = position.x
                    pPositionY[p] = position.y
                    pPositionZ[p] = position.z
                    
                    pMass[p] = bMass
                    
                    velocity *= vscale
                    
                    pVelocityX[p] = velocity.x
                    pVelocityY[p] = velocity.y
                    pVelocityZ[p] = velocity.z
                    
                    p++
                }
            }
            
        case .Expand:
            let scale  = m_Scale[0] * max(1.0, fbcscale)
            let vscale = scale * m_Scale[1]
            var lenSqr = 0.0.f
            
            var p = 0
            var v = 0
            
            var point: Float3 = (0, 0, 0)
            var velocity: Float3 = (0, 0, 0)
            
            for var i = 0; i < mnBodies; {
                point  = create(true)
                lenSqr = GLM.length_squared(point)
                
                if lenSqr > 1.0 {
                    continue
                }
                
                point *= scale
                
                pPositionX[p] = point.x
                pPositionY[p] = point.y
                pPositionZ[p] = point.z
                
                pMass[p] = 1.0 // pMass
                
                velocity *= vscale
                
                pVelocityX[v] = velocity.x
                pVelocityY[v] = velocity.y
                pVelocityZ[v] = velocity.z
                
                p++
                v++
                i++
            }
            
        }
    }
    
    private func copy(pSplit: NBody.Simulation.Data.Split,
        _ pPacked: NBody.Simulation.Data.Packed)
    {
        let pMass      = pPacked.mass
        let pPosition  = pPacked.position
        let pPositionX = pSplit.position(.X)
        let pPositionY = pSplit.position(.Y)
        let pPositionZ = pSplit.position(.Z)
        
        for i in 0..<mnBodies {
            let j = 4 * i
            
            pPosition[j]   = pPositionX[i]
            pPosition[j+1] = pPositionY[i]
            pPosition[j+2] = pPositionZ[i]
            pPosition[j+3] = pMass[i]
        }
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public convenience init(nbodies nBodies: Int, params rParams: NBody.Simulation.Params) {
        self.init()
        mnBodies   = nBodies
        mnConfig   = rParams.mnConfig
        m_Scale[0] = rParams.mnClusterScale
        m_Scale[1] = rParams.mnVelocityScale
    }
    
    //MARK: -
    //MARK: Public - Accessor
    
    public func setParam(rParams: NBody.Simulation.Params) {
        mnConfig   = rParams.mnConfig
        m_Scale[0] = rParams.mnClusterScale
        m_Scale[1] = rParams.mnVelocityScale
    }
    
    //MARK: -
    //MARK: Public - Operators
    
    private func operator_right(pSplit: NBody.Simulation.Data.Split?,
        _ pPacked: NBody.Simulation.Data.Packed?) -> Bool
    {
        let bSuccess = (pSplit != nil) && (pPacked != nil)
        
        if bSuccess {
            acquire(pSplit!, pPacked!)
            copy(pSplit!, pPacked!)
        }
        
        return bSuccess
    }
    
    private func operator_right(pPosition: UnsafeMutablePointer<GLfloat>,
        _ pVelocity: UnsafeMutablePointer<GLfloat>) -> Bool
    {
        let bSuccess = (pPosition != nil) && (pVelocity != nil)
        
        if bSuccess {
            acquire(pPosition, pVelocity)
        }
        
        return bSuccess
    }
}

func >>>(random: NBody.Simulation.Data.Random, right: (NBody.Simulation.Data.Split, NBody.Simulation.Data.Packed)) -> NBody.Simulation.Data.Random {
    random.operator_right(right.0, right.1)
    return random
}

func >>>(random: NBody.Simulation.Data.Random, right: (UnsafeMutablePointer<GLfloat>, UnsafeMutablePointer<GLfloat>)) -> Bool {
    return random.operator_right(right.0, right.1)
}
