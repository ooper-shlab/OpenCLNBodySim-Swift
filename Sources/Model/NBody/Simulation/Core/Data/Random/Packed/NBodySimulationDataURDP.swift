//
//  NBodySimulationDataURDP.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
///*
// <codex>
// <abstract>
// Functor for generating random packed-data sets for the cpu or gpu bound simulator using uniform random distribution.
// </abstract>
// </codex>
// */
//
//#ifndef _NBODY_SIMULATION_DATA_URDP_H_
//#define _NBODY_SIMULATION_DATA_URDP_H_
//
//#import "NBodySimulationDataURDB.h"
import Foundation
import OpenGL.GL
import simd
//
//#ifdef __cplusplus
//
//namespace NBody
//{
//    namespace Simulation
//    {
//        namespace Data
//        {
extension NBody.Simulation.Data {
//            class URDP : public URDB
//            {
    class URDP: URDB {
//            public:
//                URDP(const Properties& rProperties);
//
//                virtual ~URDP();
//
//                bool operator()(GLfloat* pPosition, GLfloat* pVelocity);
//
//            private:
//                void configRandom(simd::float4* pPosition, simd::float4* pVelocity);
//                void configShell(simd::float4* pPosition, simd::float4* pVelocity);
//                void configMWM31(simd::float4* pPosition, simd::float4* pVelocity);
//                void configExpand(simd::float4* pPosition, simd::float4* pVelocity);
//
//                GLfloat mnCount;
        private var mnCount: GLfloat = 0.0
//                GLfloat mnBCScale;
        private var mnBCScale: GLfloat = 0.0
//                GLfloat mnTCScale;
        private var mnTCScale: GLfloat = 0.0
//                GLfloat mnVCScale;
        private var mnVCScale: GLfloat = 0.0
//            }; // URDP
//        } // Data
//    } // Simulation
//} // NBody
//
//#endif
//
//#endif
//
//#import "NBodyConstants.h"
//#import "NBodySimulationDataGalaxy.h"
//#import "NBodySimulationDataURDP.h"
//
//#pragma mark -
//#pragma mark Private - Namespace
//
//using namespace NBody::Simulation::Data;
//
//#pragma mark -
//#pragma mark Private - Constants
//
//static const GLfloat kBodyCountScale = 1.0f / 16384.0f;
        private let kBodyCountScale: GLfloat = 1.0 / 16384.0
//
//#pragma mark -
//#pragma mark Private - Utilities
//
//void URDP::configExpand(simd::float4* pPosition,
//                        simd::float4* pVelocity)
//{
        private func configExpand(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
//    const GLfloat pscale  = m_Scale[0] * std::max(1.0f, mnBCScale);
            let pscale  = m_Scale[0] * max(1.0, mnBCScale)
//    const GLfloat vscale = pscale * m_Scale[1];
            let vscale = pscale * m_Scale[1]
//
//    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
            dispatch_apply(mnParticles, m_DQueue) {i in
//        simd::float3 position = pscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->rand();
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].rand()
//        simd::float3 velocity = vscale * position;
                let velocity = vscale * position
//
//        pPosition[i].xyz = position;
                pPosition[i] = Float4(position.x, position.y, position.z, 1.0)
//        pPosition[i].w   = 1.0f;
//
//        pVelocity[i].xyz = velocity;
                pVelocity[i] = Float4(velocity.x, velocity.y, velocity.z, 1.0)
//        pVelocity[i].w   = 1.0f;
//    });
            }
//} // configExpand
        }
//
//void URDP::configRandom(simd::float4* pPosition,
        private func configRandom(pPosition: UnsafeMutablePointer<Float4>,
//                        simd::float4* pVelocity)
            _ pVelocity: UnsafeMutablePointer<Float4>)
//{
        {
//    const GLfloat pscale = m_Scale[0] * std::max(1.0f, mnBCScale);
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
//    const GLfloat vscale = m_Scale[1] * pscale;
            let vscale = m_Scale[1] * pscale
//
//    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
            dispatch_apply(mnParticles, m_DQueue) {i in
                let p = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
//        pPosition[i].xyz = pscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
                pPosition[i] = pscale * Float4(p.x, p.y, p.z, 1.0/* mass */)
//        pPosition[i].w   = 1.0f; // mass
//
                let v = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
//        pVelocity[i].xyz = vscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
                pVelocity[i] = vscale * Float4(v.x, v.y, v.z, 1.0/* inverse mass*/)
//        pVelocity[i].w   = 1.0f; // inverse mass
//    });
            }
//} // configRandom
        }
//
//void URDP::configShell(simd::float4* pPosition,
//                       simd::float4* pVelocity)
//{
        private func configShell(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
//    const GLfloat pscale = m_Scale[0];
            let pscale = m_Scale[0]
//    const GLfloat vscale = pscale * m_Scale[1];
            let vscale = pscale * m_Scale[1]
//    const GLfloat inner  = 2.5f * pscale;
            let inner  = 2.5 * pscale
//    const GLfloat outer  = 4.0f * pscale;
            let outer  = 4.0 * pscale
//    const GLfloat length = outer - inner;
            let length = outer - inner
//
//    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
            dispatch_apply(mnParticles, m_DQueue) {i in
//        simd::float3 nrpos    = mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
                let nrpos    = self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
//        simd::float3 rpos     = mpGenerator[eNBodyRandIntervalLenIsOne]->rand();
                let rpos     = self.mpGenerator[NBody.RandIntervalLenIs.One].rand()
//        simd::float3 position = nrpos * (inner + (length * rpos));
                let position = nrpos * (inner + (length * rpos))
//
//        pPosition[i].xyz = position;
                pPosition[i] = Float4(position.x, position.y, position.z, self.mnTCScale)
//        pPosition[i].w   = mnTCScale;
//
//        simd::float3 axis = m_Axis;
                var axis = self.m_Axis
//
//        GLfloat scalar = simd::dot(nrpos, axis);
                let scalar = dot(nrpos, axis)
//
//        if((1.0f - scalar) < 1e-6)
//        {
                if (1.0 - scalar) < 1e-6 {
//            axis.xy = nrpos.yx;
                    (axis.x, axis.y) = (nrpos.y, nrpos.x)
//
//            axis = simd::normalize(axis);
                    axis = normalize(axis)
//        } // if
                }
//
//        simd::float3 velocity = vscale * simd::cross(position, axis);
                let velocity = vscale * cross(position, axis)
//
//        pVelocity[i].xyz = velocity;
                pVelocity[i] = Float4(velocity.x, velocity.y, velocity.z, self.mnVCScale)
//        pVelocity[i].w   = mnVCScale;
//    });
            }
//} // configShell
        }
//
//void URDP::configMWM31(simd::float4* pPosition,
//                       simd::float4* pVelocity)
//{
        private func configMWM31(pPosition: UnsafeMutablePointer<Float4>,
            _ pVelocity: UnsafeMutablePointer<Float4>)
        {
//    Data::Galaxy df(mnParticles);
            let df = Galaxy(mnParticles)
//
//    if(df.rows())
//    {
            if df.rows != 0 {
//        // The Milky-Way (MW) seems to be on a collision course with our
//        // neighbour spiral galaxy Andromeda (M31)
//
//        GLfloat pscale = m_Scale[0];
                let pscale = m_Scale[0]
//        GLfloat vscale = pscale * m_Scale[1];
                let vscale = pscale * m_Scale[1]
//        GLfloat mscale = pscale * pscale * pscale;
                let mscale = pscale * pscale * pscale
//
//        GLint numPoints = 0;
                //var numPoints = 0   //### not used
//
//        GLfloat mass = 0.0f;
                var mass: GLfloat = 0.0
//
//        simd::float3 position = 0.0f;
                var position: Float3 = Float3()
//        simd::float3 velocity = 0.0f;
                var velocity: Float3 = Float3()
//
//        size_t i = 0;
                var i = 0
//
//        while(!df.eof())
//        {
                while !df.eof {
//            numPoints++;
                    //numPoints++
//
//            std::vector<float> vec = df.floats();
                    let vec = df.floats()
//
//            mass = vec[0] * mscale;
                    mass = vec[0] * mscale
//
//            position = {vec[1], vec[2], vec[3]};
                    position = Float3(vec[1], vec[2], vec[3])
//
//            pPosition[i].xyz = pscale * position;
                    let p = pscale * position
//            pPosition[i].w   = mass;
                    pPosition[i] = Float4(p.x, p.y, p.z, mass)
//
//            velocity = {vec[4], vec[5], vec[6]};
                    velocity = Float3(vec[4], vec[5], vec[6])
//
//            pVelocity[i].xyz = vscale * velocity;
                    let v = vscale * velocity
//            pVelocity[i].w   = 1.0f / mass;
                    pVelocity[i] = Float4(v.x, v.y, v.z, 1.0 / mass)
                    
                    ++i //### was missing
//        } // while
                }
//    } // if
            }
//} // configMWM31
        }
//
//#pragma mark -
//#pragma mark Public - Interfaces
//
//URDP::URDP(const Properties& rProperties)
        override init(_ rProperties: NBody.Simulation.Properties) {
//: URDB::URDB(rProperties)
            super.init(rProperties)
//{
//    mnCount   = GLfloat(mnParticles);
            mnCount   = GLfloat(mnParticles)
//    mnBCScale = mnCount / 1024.0f;
            mnBCScale = mnCount / 1024.0
//    mnTCScale = 16384.0f / mnCount;
            mnTCScale = 16384.0 / mnCount
//    mnVCScale = kBodyCountScale * mnCount;
            mnVCScale = kBodyCountScale * mnCount
//} // Constructor
        }
//
//URDP::~URDP()
//{
//    mnCount   = 0.0f;
//    mnBCScale = 0.0f;
//    mnTCScale = 0.0f;
//    mnVCScale = 0.0f;
//} // Destructor
//
//bool URDP::operator()(GLfloat* pInPosition,
//                      GLfloat* pInVelocity)
//{
        func setTo(pInPosition: UnsafeMutablePointer<GLfloat>,
            _ pInVelocity: UnsafeMutablePointer<GLfloat>) -> Bool
        {
//    bool bSuccess = (pInPosition != nullptr) && (pInVelocity != nullptr);
            guard pInPosition != nil && pInVelocity != nil else {return false}
//
//    if(bSuccess)
//    {
//        simd::float4* pPosition = reinterpret_cast<simd::float4 *>(pInPosition);
            let pPosition = UnsafeMutablePointer<Float4>(pInPosition)
//        simd::float4* pVelocity = reinterpret_cast<simd::float4 *>(pInVelocity);
            let pVelocity = UnsafeMutablePointer<Float4>(pInVelocity)
//
//        switch(mnConfig)
//        {
            switch mnConfig {
//            case NBody::eConfigShell:
            case .Shell:
//                configShell(pPosition, pVelocity);
                configShell(pPosition, pVelocity)
//                break;
//
//            case NBody::eConfigMWM31:
            case .MWM31:
//                configMWM31(pPosition, pVelocity);
                configMWM31(pPosition, pVelocity)
//                break;
//
//            case NBody::eConfigExpand:
            case .Expand:
//                configExpand(pPosition, pVelocity);
                configExpand(pPosition, pVelocity)
//                break;
//
//            case NBody::eConfigRandom:
            case .Random:
//            default:
//                configRandom(pPosition, pVelocity);
                configRandom(pPosition, pVelocity)
//                break;
//        } // switch
            }
//    } // if
//
//    return bSuccess;
            return true
//} // operator()
        }
    }
}