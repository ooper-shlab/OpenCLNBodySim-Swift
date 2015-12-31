//
//  NBodySimulationDataURDS.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
///*
// <codex>
// <abstract>
// Functor for generating random split-data sets for the cpu or gpu bound simulator using uniform random distribution.
// </abstract>
// </codex>
// */
//
//#ifndef _NBODY_SIMULATION_DATA_URDS_H_
//#define _NBODY_SIMULATION_DATA_URDS_H_
//
//#import "NBodySimulationDataURDB.h"
//#import "NBodySimulationDataSplit.h"
import Foundation
import OpenGL
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
//            class URDS : public URDB
//            {
    class URDS: URDB {
//            public:
//                URDS(const Properties& rProperties);
//
//                virtual ~URDS();
//
//                bool operator()(Split* pSplit);
//
//            private:
//                void configRandom();
//                void configShell();
//                void configMWM31();
//                void configExpand();
//
//                GLfloat mnCount;
        private var mnCount: GLfloat = 0.0
//                GLfloat mnBCScale;
        private var mnBCScale: GLfloat = 0.0
//
//                GLfloat* mpMass;
        private var mpMass: UnsafeMutablePointer<GLfloat> = nil
//                GLfloat* mpPosition[3];
        private var mpPosition: [UnsafeMutablePointer<GLfloat>] = Array(count: 3, repeatedValue: nil)
//                GLfloat* mpVelocity[3];
        private var mpVelocity: [UnsafeMutablePointer<GLfloat>] = Array(count: 3, repeatedValue: nil)
//            }; // URDS
//        } // Data
//    } // Simulation
//} // NBody
//
//#endif
//
//#endif
///*
// <codex>
// <import>NBodySimulationDataURDS.h</import>
// </codex>
// */
//
//#import "NBodyConstants.h"
//#import "NBodySimulationDataGalaxy.h"
//#import "NBodySimulationDataURDS.h"
//
//#pragma mark -
//#pragma mark Private - Namespace
//
//using namespace NBody::Simulation::Data;
//
//#pragma mark -
//#pragma mark Private - Utilities
//
//void URDS::configExpand()
//{
        private func configExpand() {
//    const GLfloat pscale = m_Scale[0] * std::max(1.0f, mnBCScale);
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
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
//        mpPosition[eAxisX][i] = position.x;
                self.mpPosition[Axis.X.rawValue][i] = position.x
//        mpPosition[eAxisY][i] = position.y;
                self.mpPosition[Axis.Y.rawValue][i] = position.y
//        mpPosition[eAxisZ][i] = position.z;
                self.mpPosition[Axis.Z.rawValue][i] = position.z
//
//        mpVelocity[eAxisX][i] = velocity.x;
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
//        mpVelocity[eAxisY][i] = velocity.y;
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
//        mpVelocity[eAxisZ][i] = velocity.z;
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
//
//        mpMass[i] = 1.0f;
                self.mpMass[i] = 1.0
//    });
            }
//} // configExpand
        }
//
//void URDS::configRandom()
//{
        private func configRandom() {
//    const GLfloat pscale = m_Scale[0] * std::max(1.0f, mnBCScale);
            let pscale = m_Scale[0] * max(1.0, mnBCScale)
//    const GLfloat vscale = m_Scale[1] * pscale;
            let vscale = m_Scale[1] * pscale
//
//    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
            dispatch_apply(mnParticles, m_DQueue) {i in
//        simd::float3 position = pscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
                let position = pscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
//        simd::float3 velocity = vscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
                let velocity = vscale * self.mpGenerator[NBody.RandIntervalLenIs.Two].nrand()
//
//        mpPosition[eAxisX][i] = position.x;
                self.mpPosition[Axis.X.rawValue][i] = position.x
//        mpPosition[eAxisY][i] = position.y;
                self.mpPosition[Axis.Y.rawValue][i] = position.y
//        mpPosition[eAxisZ][i] = position.z;
                self.mpPosition[Axis.Z.rawValue][i] = position.z
//
//        mpMass[i] = 1.0f; // mass
                self.mpMass[i] = 1.0 // mass
//
//        mpVelocity[eAxisX][i] = velocity.x;
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
//        mpVelocity[eAxisY][i] = velocity.y;
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
//        mpVelocity[eAxisZ][i] = velocity.z;
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
//    });
            }
//} // configRandom
        }
//
//void URDS::configShell()
//{
        private func configShell() {
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
//        mpPosition[eAxisX][i] = position.x;
                self.mpPosition[Axis.X.rawValue][i] = position.x
//        mpPosition[eAxisY][i] = position.y;
                self.mpPosition[Axis.Y.rawValue][i] = position.y
//        mpPosition[eAxisZ][i] = position.z;
                self.mpPosition[Axis.Z.rawValue][i] = position.z
//
//        mpMass[i] = 1.0f;
                self.mpMass[i] = 1.0
//
//        simd::float3 axis = m_Axis;
                var axis = self.m_Axis
//
//        GLfloat scalar = simd::dot(nrpos, axis);
                let scalar = dot(nrpos, axis)
//
//        if((1.0f - scalar) < 1.0e-6)
//        {
                if 1.0 - scalar < 1.0e-6 {
//            axis.xy = nrpos.yx;
                    (axis.x,axis.y) = (nrpos.y, nrpos.x)
//
//            axis = simd::normalize(axis);
                    axis = normalize(axis)
//        } // if
                }
//
//        simd::float3 velocity =
//        {
                var velocity = Float3(
//            mpPosition[eAxisX][i],
                self.mpPosition[Axis.X.rawValue][i],
//            mpPosition[eAxisY][i],
                    self.mpPosition[Axis.Y.rawValue][i],
//            mpPosition[eAxisZ][i]
                    self.mpPosition[Axis.Z.rawValue][i]
//        };
            )
//
//        velocity = vscale * simd::cross(velocity, axis);
                velocity = vscale * cross(velocity, axis)
//
//        mpVelocity[eAxisX][i] = velocity.x;
                self.mpVelocity[Axis.X.rawValue][i] = velocity.x
//        mpVelocity[eAxisY][i] = velocity.y;
                self.mpVelocity[Axis.Y.rawValue][i] = velocity.y
//        mpVelocity[eAxisZ][i] = velocity.z;
                self.mpVelocity[Axis.Z.rawValue][i] = velocity.z
//    });
            }
//} // configShell
        }
//
//void URDS::configMWM31()
//{
        private func configMWM31() {
//    Data::Galaxy galaxy(mnParticles);
        let galaxy = NBody.Simulation.Data.Galaxy(mnParticles)
//
//    if(galaxy.rows())
//    {
            if galaxy.rows != 0 {
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
//        simd::float3 position = 0.0f;
                var position: Float3 = Float3()
//        simd::float3 velocity = 0.0f;
                var velocity: Float3 = Float3()
//
//        size_t i = 0;
                var i = 0
//
//        while(!galaxy.eof())
//        {
                while !galaxy.eof {
//            numPoints++;
                    //numPoints++
//
//            std::vector<float> vec = galaxy.floats();
                    let vec = galaxy.floats()
//
//            mpMass[i] = mscale * vec[0];
                    mpMass[i] = mscale * vec[0]
//
//            position  = {vec[1], vec[2], vec[3]};
                    position  = Float3(vec[1], vec[2], vec[3])
//            position *= pscale;
                    position *= pscale
//
//            mpPosition[eAxisX][i] = position.x;
                    mpPosition[Axis.X.rawValue][i] = position.x
//            mpPosition[eAxisY][i] = position.y;
                    mpPosition[Axis.Y.rawValue][i] = position.y
//            mpPosition[eAxisZ][i] = position.z;
                    mpPosition[Axis.Z.rawValue][i] = position.z
//
//            velocity  = {vec[4], vec[5], vec[6]};
                    velocity  = Float3(vec[4], vec[5], vec[6])
//            velocity *= vscale;
                    velocity *= vscale
//
//            mpVelocity[eAxisX][i] = velocity.x;
                    mpVelocity[Axis.X.rawValue][i] = velocity.x
//            mpVelocity[eAxisY][i] = velocity.y;
                    mpVelocity[Axis.Y.rawValue][i] = velocity.y
//            mpVelocity[eAxisZ][i] = velocity.z;
                    mpVelocity[Axis.Z.rawValue][i] = velocity.z
//
//            i++;
                    i++
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
//URDS::URDS(const Properties& rProperties)
//: URDB::URDB(rProperties)
//{
        override init(_ rProperties: NBody.Simulation.Properties) {
            super.init(rProperties)
//    mnCount   = GLfloat(mnParticles);
            mnCount   = GLfloat(mnParticles)
//    mnBCScale = mnCount / 1024.0f;
            mnBCScale = mnCount / 1024.0
//} // Constructor
        }
//
//URDS::~URDS()
//{
//    mnCount   = 0.0f;
//    mnBCScale = 0.0f;
//    mpMass    = nullptr;
//
//    mpPosition[eAxisX] = nullptr;
//    mpPosition[eAxisY] = nullptr;
//    mpPosition[eAxisZ] = nullptr;
//
//    mpVelocity[eAxisX] = nullptr;
//    mpVelocity[eAxisY] = nullptr;
//    mpVelocity[eAxisZ] = nullptr;
//} // Destructor
//
//bool URDS::operator()(Split* pSplit)
//{
        func setTo(pSplit: Split) -> Bool {
//    bool bSuccess = pSplit != nullptr;
//
//    if(bSuccess)
//    {
//        mpMass = pSplit->mass();
            mpMass = pSplit.mass()
//
//        mpPosition[eAxisX] = pSplit->position(eAxisX);
            mpPosition[Axis.X.rawValue] = pSplit.position(.X)
//        mpPosition[eAxisY] = pSplit->position(eAxisY);
            mpPosition[Axis.Y.rawValue] = pSplit.position(.Y)
//        mpPosition[eAxisZ] = pSplit->position(eAxisZ);
            mpPosition[Axis.Z.rawValue] = pSplit.position(.Z)
//
//        mpVelocity[eAxisX] = pSplit->velocity(eAxisX);
            mpVelocity[Axis.X.rawValue] = pSplit.velocity(.X)
//        mpVelocity[eAxisY] = pSplit->velocity(eAxisY);
            mpVelocity[Axis.Y.rawValue] = pSplit.velocity(.Y)
//        mpVelocity[eAxisZ] = pSplit->velocity(eAxisZ);
            mpVelocity[Axis.Z.rawValue] = pSplit.velocity(.Z)
//
//        switch(mnConfig)
//        {
            switch mnConfig {
//            case NBody::eConfigShell:
            case .Shell:
//                configShell();
                configShell()
//                break;
//
//            case NBody::eConfigMWM31:
            case .MWM31:
//                configMWM31();
                configMWM31()
//                break;
//
//            case NBody::eConfigExpand:
            case .Expand:
//                configExpand();
                configExpand()
//                break;
//
//            case NBody::eConfigRandom:
            case .Random:
//            default:
//                configRandom();
                configRandom()
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