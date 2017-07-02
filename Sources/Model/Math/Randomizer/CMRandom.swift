//
//  CMRandom.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/13.
//
//
/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Utility class for generating random values using uniform real distribution for a simd float3 vector with a least upper bound and a greatest lower bound.
*/

import Foundation

import simd

extension CM {
    enum URD3 {
        
        //MARK: -
        //MARK: Private - Interfaces
        
        // Uniform real distribution triplets base class
        // Base class for generating uniform random distribution triplets
        class Core {
            // Instantiate the object using a least uppper bound
            // and a greatest lower bound
            init(min: Float = 0.0, max: Float = 1.0) {
                // Default bounds for the uniform real distribution
                mnMin = min
                mnMax = max
                
                // Initialize the bounding metric 2-norm maximum
                mnEPS = 1e-6
                mnLen = 0.0
                
                // Acquire a random device for initializing our engine
                let device = RandomDevice()
                
                // Initialize the uniform real distribution for
                // random number generation
                m_Generator    = DefaultRandomEngine(seed: device.next)
                m_Distribution = UniformRealDistribution(min: mnMin, max: mnMax)
            }
            
            // Destructor
            deinit {
                mnMin = 0.0
                mnMax = 0.0
                
                m_Distribution.reset();
            }
            
            // Uniform real distribution triplets
            func rand() -> float3 {fatalError("abstract: not implemented")}
            
            // Normalized uniform real distribution triplets
            func nrand() -> float3 {fatalError("abstract: not implemented")}
            
            var mnEPS: Float   // Tolerance for the bounding value of 2-norm metric
            var mnLen: Float   // Bounding value for 2-norm metric
            var mnMin: Float   // Greatest lower bound for uniform integer generator
            var mnMax: Float   // Least upper bound for uniform integer generator
            
            // Uniform discrete real generator:
            //
            // <http://www.cplusplus.com/reference/random/uniform_real_distribution/>
            //
            // The valid type names here are float, double, or long double.
            fileprivate var m_Generator: DefaultRandomEngine
            fileprivate var m_Distribution: UniformRealDistribution<Float>
            
            //MARK: -
            //MARK: Private - Implementation - Core
            
            //---------------------------------------------------------------
            //
            // Base class for generating uniform random distribution triplets
            //
            //---------------------------------------------------------------
            
            //// Instantiate the object using a least uppper bound
            //// and a greatest lower bound
            //CM::URD3::core::core(const float& min,
            //                     const float& max)
            //{
            //    // Default bounds for the uniform real distribution
            //    mnMin = min;
            //    mnMax = max;
            //
            //    // Initialize the bounding metric 2-norm maximum
            //    mnEPS = 1e-6;
            //    mnLen = 0.0;
            //
            //    // Acquire a random device for initializing our engine
            //    std::random_device  device;
            //
            //    // Initialize the uniform real distribution for
            //    // random number generation
            //    m_Generator    = std::default_random_engine(device());
            //    m_Distribution = std::uniform_real_distribution<float>(mnMin, mnMax);
            //} // Constructor
            
            // Tolerance for the Euclidean 2-norm
            // Set the tolerance for the Euclidean 2-norm
            var eps: Float {
                get {
                    return mnEPS
                }
                set {
                    mnEPS = newValue
                }
            }
            
            // Upper bound for the Euclidean 2-norm
            // Set the length for bounding metric
            var length: Float {
                get {
                    return mnLen
                }
                set {
                    mnLen = newValue
                }
            }
            
            // Get the greatest lower bound
            var min: Float {
                return mnMin
            }
            
            // Get the least upper bound
            var max: Float {
                return mnMax
            }
            
            // Reset the distribution such that subsequent values generated
            // are independent of previously generated values
            func reset() {
                m_Distribution.reset()
            }
            
        }
    }
}
extension CM.URD3 {
    
    //MARK: -
    //MARK: Private - Implementation - Bounded
    
    //--------------------------------------------------------------
    //
    // Uniform real distribution triplets bounded by a 2-norm metric
    //
    //--------------------------------------------------------------
    class Bounded: Core {
        
        override init(min: Float, max: Float) {
            super.init(min: min, max: max)
        }
        
        // Concrete implementation for generating uniform real distribution
        // triplets
        override func rand() -> float3 {
            var reslt = float3()
            
            var norm: Float = 0.0
            
            repeat {
                reslt.x = m_Distribution.next(m_Generator)
                reslt.y = m_Distribution.next(m_Generator)
                reslt.z = m_Distribution.next(m_Generator)
                
                norm = simd.length(reslt)
            } while norm > mnLen
            
            return reslt
        }
        
        // Concrete implementation for generating normalized uniform real
        // distribution triplets
        override func nrand() -> float3 {
            return normalize(rand())
        }
    }
    
    //MARK: -
    //MARK: Private - Implementation - Unbounded
    
    //--------------------------------------------------------------
    //
    // Uniform real distribution triplets without a bounding metric
    //
    //--------------------------------------------------------------
    class Unbounded: Core {
        
        override init(min: Float, max: Float) {
            super.init(min: min, max: max)
        }
        
        // Concrete implementation for generating uniform real distribution
        // triplets
        override func rand() -> float3 {
            var reslt = float3()
            
            reslt.x = m_Distribution.next(m_Generator)
            reslt.y = m_Distribution.next(m_Generator)
            reslt.z = m_Distribution.next(m_Generator)
            
            return reslt
        }
        
        // Concrete implementation for generating normalized uniform real
        // distribution triplets
        override func nrand() -> float3 {
            return normalize(rand())
        }
    }
    
    //MARK: -
    //MARK: Private - Utilities
    
    // A constructor for  creating a uniform real distribution
    // triplets with/without a bounding metric
    static func create(_ min: Float, _ max: Float, _ len: Float, _ eps: Float) -> CM.URD3.Core {
        let pCore: CM.URD3.Core
        
        let nLen = len
        let nEPS = eps
        
        if CM.isZero(nLen, nEPS) {
            pCore = CM.URD3.Unbounded(min: min, max: max)
        } else {
            pCore = CM.URD3.Bounded(min: min, max: max)
        }
        
        pCore.length = nLen
        pCore.eps = nEPS
        
        return pCore
    }
    
}
extension CM.URD3 {
    
    //MARK: -
    //MARK: Public - Implementation - Generator
    
    //-------------------------------------------------------------------------
    //
    // Uniform real distribution facade for generating triplets with/without
    // a bounding metric.
    //
    //-------------------------------------------------------------------------
    
    // Facade for generating uniform random distribution triplets
    class Generator {
        private var mpCore: Core
        // Instantiate the object using a least uppper bound and a greatest lower
        // bound. If the length is a value greter than zero, then the object will
        // generate uniform real distribution triplets bounded by a 2-norm metric.
        // Otherwise, the instantiated object generates uniform real distribution
        // triplets without a bounding metric.
        init(min: Float = 0.0, max: Float = 1.0, len: Float = 0.0, eps: Float = 1.0e-6) {
            mpCore = CM.URD3.create(min, max, len, eps)
        }
        
        // Get the greatest lower bound
        var min: Float {
            return mpCore.min
        }
        
        // Get the least upper bound
        var max: Float {
            return mpCore.max
        }
        
        // Reset the distribution such that subsequent values generated
        // are independent of previously generated values
        func reset() {
            mpCore.reset()
        }
        
        // Uniform real distribution triplets
        func rand() -> float3 {
            return mpCore.rand()
        }
        
        // Normalized uniform real distribution triplets
        func nrand() -> float3 {
            return mpCore.nrand()
        }
    }
}

//MARK: -
//MARK: Public - Utilities

class RandomDevice {
    init() {
        srandomdev()
        sranddev()
    }
    var next: UInt64 {
        let r1 = UInt64(arc4random())
        let r2 = UInt64(arc4random())
        return r1<<32 | r2
    }
}
class DefaultRandomEngine {
    typealias ResultType = UInt64
    private var _seed: UInt64
    init(seed: UInt64) {
        self._seed = seed
    }
    
    var min: UInt64 {
        return 0
    }
    var max: UInt64 {
        return UInt64(UInt32.max)
    }
    var seed: UInt64 {
        return _seed
    }
    var next: UInt64 {
        return UInt64(arc4random())
    }
    func advance() {
        _ = self.next
    }
}
class UniformRealDistribution<F: BinaryFloatingPoint> {
    private var min: F
    private var max: F
    init(min: F, max: F) {
        self.min = min
        self.max = max
    }
    
    func next(_ re: DefaultRandomEngine) -> F {
        let rnd = re.next
        let drnd = Double(rnd - re.min)/Double(re.max + 1 - re.min)
        return F(drnd) * (max - min) + min
    }
    func reset() {}
}
