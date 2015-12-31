//
//  CMNumerics.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/13.
//
//
/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Numerics utilities for fast-float comparison and swapping integer values.
*/

import Foundation

extension CM {
    
    private static func NUMERICS_SGN_MASK_32(i: Int32) -> Int32 {
        return -Int32((UInt32(i))>>31)
    }
    //#define NUMERICS_SGN_MASK_64(i) (-(int64_t)(((uint64_t)(i))>>63))
    
    // Single and double precision comparisons
    //-------------------------------------------------------------------------------
    //
    // Algorithm:  Performant single and double precision comparisons
    //
    // Lomont, Chris. “Floating Point Tricks”: Game Programming Gems #6, 2006, pg 121
    //
    //-------------------------------------------------------------------------------
    
    static func isEQ(x: Float, _ y: Float, max: Int32 = 1) -> Bool {
        let v = unsafeBitCast(x, Int32.self)
        let w = unsafeBitCast(y, Int32.self)
        let r = NUMERICS_SGN_MASK_32(v^w)
        
        assert((0 == r) || (-1 == r))
        
        let d = (v ^ (r & 0x7FFFFFFF)) - w
        
        let lub = max + d
        let glb = max - d
        
        return (lub|glb) >= 0
    }
    
    //bool CM::isEQ(double& x,
    //              double& y,
    //              const int64_t& max)
    //{
    //    int64_t v = *reinterpret_cast<int64_t *>(&x);
    //    int64_t w = *reinterpret_cast<int64_t *>(&y);
    //    int64_t r = NUMERICS_SGN_MASK_64(v^w);
    //
    //    assert((0 == r) || (0xFFFFFFFFFFFFFFFF == r));
    //
    //    int64_t d = (v ^ (r&  0x7FFFFFFFFFFFFFFF)) - w;
    //
    //    int64_t lub = max + d;
    //    int64_t glb = max - d;
    //
    //    return (lub|glb) >= 0;
    //} // isEQ
    
    static func isLT(x: Float, _ y: Float) -> Bool {
        let v = unsafeBitCast(x, Int32.self)
        let w = unsafeBitCast(y, Int32.self)
        let r = NUMERICS_SGN_MASK_32(v & w)
        
        return (v ^ r) < (w ^ r)
    }
    
    //bool CM::isLT(double& x,
    //              double& y)
    //{
    //    int64_t v = *reinterpret_cast<int64_t *>(&x);
    //    int64_t w = *reinterpret_cast<int64_t *>(&y);
    //    int64_t r = NUMERICS_SGN_MASK_64(v & w);
    //
    //    return (v ^ r) < (w ^ r);
    //} // isLT
    
    static func isZero(x: Float, _ eps: Float) -> Bool {
        let v = unsafeBitCast(x, Int32.self)
        let e = unsafeBitCast(eps, Int32.self)
        
        return (v & 0x7FFFFFFF) <= e
    }
    
    //bool  CM::isZero(double& x,
    //                 double& eps)
    //{
    //    int64_t v = *reinterpret_cast<int64_t *>(&x);
    //    int64_t e = *reinterpret_cast<int64_t *>(&eps);
    //
    //    return (v & 0x7FFFFFFFFFFFFFFF) <= e;
    //} // isZero
    
    // Storsge-free swap
    //------------------------------------------------------------------------------------
    //
    // Algorithm:
    //
    //  <http://graphics.stanford.edu/~seander/bithacks.html#SwappingValuesSubAdd>
    //
    // Traditional integer swapping requires the use of a temporary variable.
    // However, using the XOR swap, no temporary variable is required.
    //
    //------------------------------------------------------------------------------------
    
    //### XOR swapping is an interesting algorithm, but very suspicious if efficient in actual apps.
    //#define NUMERICS_SWAP(a, b) (((a) ^ (b)) && ((b) ^= (a) ^= (b), (a) ^= (b)))
    
    static func swap(inout x: Int, inout _ y: Int) {
        (x, y) = (y, x) //### No reason to use XOR swap...
    }
    
    //void swap(size_t& x, size_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(int8_t& x, int8_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(int16_t& x, int16_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(int32_t& x, int32_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(int64_t& x, int64_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(size_t& x, size_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(uint8_t& x, uint8_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(uint16_t& x, uint16_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(uint32_t& x, uint32_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
    //
    //void CM::swap(uint64_t& x, uint64_t& y)
    //{
    //    NUMERICS_SWAP(x, y);
    //} // swap
}