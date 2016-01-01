//
//  CFCPULoad.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/28.
//
//
///*
// <codex>
// <abstract>
// Utility class for calculating load on CPU cores.
// </abstract>
// </codex>
// */

import Darwin

extension CF.CPU {
    class Load {
        init() {
            construct()
        }
        
        init(load rLoad: Load) {
            construct(rLoad)
        }
        
        deinit {
            destruct()
        }
        
        private var mnTotalTime: size_t = 0
        private var mnUserTime: size_t = 0
        
        private func construct() {
            mnTotalTime = 0
            mnUserTime  = 0
        }
        
        private func construct(rLoad: Load) {
            mnTotalTime = rLoad.mnTotalTime
            mnUserTime  = rLoad.mnUserTime
        }
        
        private func destruct() {
            mnTotalTime = 0
            mnUserTime  = 0
        }
        
        //Load& Load::operator=(const Load& rLoad)
        //{
        //    if(this != &rLoad)
        //    {
        //        mnTotalTime = rLoad.mnTotalTime;
        //        mnUserTime  = rLoad.mnUserTime;
        //    } // if
        //
        //    return *this;
        //} // Assignment Operator
        
        var total: size_t {
            return mnTotalTime
        }
        
        var user: size_t {
            return mnUserTime
        }
        
        var percentage: Double {
            var nResult = 0.0
            
            let hostInfo = HostInfo()
            
            if hostInfo.error == KERN_SUCCESS {
                var nTotalTime = 0
                var nUserTime  = 0
                
                let nCPUMax = hostInfo.cpus
                
                for nCPU in 0..<nCPUMax {
                    nUserTime  += hostInfo.user(nCPU).l
                    nTotalTime += hostInfo.total(nCPU)
                }
                
                nResult = 100.0 * Double(nUserTime  - mnUserTime) / Double(nTotalTime - mnTotalTime)
                
                mnUserTime  = nUserTime
                mnTotalTime = nTotalTime
            }
            
            return nResult
        }
    }
}