//
//  CFCPUHostInfo.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/28.
//
//
///*
// <codex>
// <abstract>
// Utility class for acquiring host (cpu) info array.
// </abstract>
// </codex>
// */

import Darwin.Mach

extension CF.CPU {
    class HostInfo {
        init() {
            construct()
        }
        
        init(hostInfo rHostInfo: HostInfo) {
            construct(rHostInfo)
        }
        
        private var mnCount: natural_t = 0
        private var mnSize: natural_t = 0
        private var mnFlavor: processor_flavor_t = 0
        private var mnError: kern_return_t = 0
        private var mpInfo: processor_info_array_t? = nil
        private var mnInfo: mach_msg_type_number_t = 0
        
        private let kSizeInteger = MemoryLayout<natural_t>.size
        
        static func getState(_ i: Int,
            _ nCount: natural_t,
            _ type: Int,
            _ pInfo: processor_info_array_t?) -> natural_t
        {
            var nState: natural_t = 0
            
            if pInfo != nil {
                nState = (i < nCount.l) ? (pInfo?[CPU_STATE_MAX.l * i + type].ui)! : 0
            }
            
            return nState
        }
        
        static func getUserState(_ i: Int,
            _ nCount: natural_t,
            _ pInfo: processor_info_array_t) -> natural_t
        {
            return getState(i, nCount, CPU_STATE_USER.l, pInfo)
        }
        
        static func getSystemState(_ i: Int,
            _ nCount: natural_t,
            _ pInfo: processor_info_array_t) -> natural_t
        {
            return getState(i, nCount, CPU_STATE_SYSTEM.l, pInfo)
        }
        
        static func getIdleState(_ i: Int,
            _ nCount: natural_t,
            _ pInfo: processor_info_array_t) -> natural_t
        {
            return getState(i, nCount, CPU_STATE_IDLE.l, pInfo)
        }
        
        static func getNiceState(_ i: Int,
            _ nCount: natural_t,
            _ pInfo: processor_info_array_t) -> natural_t
        {
            return getState(i, nCount, CPU_STATE_NICE.l, pInfo)
        }
        
        static func getSum(_ i: Int,
            _ nCount: natural_t,
            _ pInfo: processor_info_array_t?) -> size_t
        {
            var nSum: size_t = 0
            
            if i < nCount.l && pInfo != nil {
                let nOffset = CPU_STATE_MAX.l * i
                let nUser   = pInfo?[nOffset + CPU_STATE_USER.l]
                let nSytem  = pInfo?[nOffset + CPU_STATE_SYSTEM.l]
                let nIde    = pInfo?[nOffset + CPU_STATE_IDLE.l]
                let nNice   = pInfo?[nOffset + CPU_STATE_NICE.l]
                
                nSum = (nSytem?.l)! + (nIde?.l)! + (nNice?.l)! + (nUser?.l)!
            }
            
            return nSum
        }
        
        private func construct() {
            mnCount  = 0
            mnInfo   = 0
            mpInfo   = nil
            mnFlavor = PROCESSOR_CPU_LOAD_INFO
            mnError  = host_processor_info(mach_host_self(), mnFlavor, &mnCount, &mpInfo, &mnInfo)
            mnSize   = kSizeInteger.ui * mnInfo
        }
        
        private func construct(_ rHostInfo: HostInfo) {
            mnCount  = rHostInfo.mnCount
            mnInfo   = rHostInfo.mnInfo
            mnSize   = kSizeInteger.ui * rHostInfo.mnInfo
            mnFlavor = PROCESSOR_CPU_LOAD_INFO
            mpInfo   = CF.ProcessorInfoArrayCreateCopy(mnSize, rHostInfo.mpInfo!, &mnError)
        }
        
        private func destruct() {
            CF.ProcessorInfoArrayDelete(mnSize, mpInfo!)
            
            mnCount  = 0
            mnInfo   = 0
            mnSize   = 0
            mnFlavor = 0
            mnError  = 0
        }
        
        //HostInfo& HostInfo::operator=(const HostInfo& rHostInfo)
        //{
        //    if(this != &rHostInfo)
        //    {
        //        if((mnInfo != rHostInfo.mnInfo) || (mpInfo == nullptr))
        //        {
        //            processor_info_array_t pInfo = ProcessorInfoArrayCreateCopy(rHostInfo.mnSize,
        //                                                                        rHostInfo.mpInfo,
        //                                                                        mnError);
        //
        //            if(mnError == KERN_SUCCESS)
        //            {
        //                mnError = ProcessorInfoArrayDelete(mnSize, mpInfo);
        //
        //                if(mnError == KERN_SUCCESS)
        //                {
        //                    mpInfo = pInfo;
        //                } // if
        //                else
        //                {
        //                    ProcessorInfoArrayDelete(mnSize, pInfo);
        //                } // else
        //            } // if
        //        } // if
        //        else
        //        {
        //            mnError = ProcessorInfoArrayCopy(rHostInfo.mnSize, rHostInfo.mpInfo, mpInfo);
        //        } // else
        //
        //        if(mnError == KERN_SUCCESS)
        //        {
        //            mnSize   = rHostInfo.mnSize;
        //            mnCount  = rHostInfo.mnCount;
        //            mnInfo   = rHostInfo.mnInfo;
        //            mnFlavor = PROCESSOR_CPU_LOAD_INFO;
        //        } // if
        //    } // if
        //
        //    return *this;
        //} // Assignment Operator
        
        var error: kern_return_t {
            return mnError
        }
        
        var flavor: processor_flavor_t {
            return mnFlavor
        }
        
        var cpus: Int {
            return mnCount.l
        }
        
        var size: natural_t {
            return mnSize
        }
        
        func user(_ i: Int) -> natural_t {
            return CF.CPU.HostInfo.getUserState(i, mnCount, mpInfo!)
        }
        
        func system(_ i: Int) -> natural_t {
            return CF.CPU.HostInfo.getSystemState(i, mnCount, mpInfo!)
        }
        
        func idle(_ i: Int) -> natural_t {
            return CF.CPU.HostInfo.getIdleState(i, mnCount, mpInfo!)
        }
        
        func nice(_ i: Int) -> natural_t {
            return CF.CPU.HostInfo.getNiceState(i, mnCount, mpInfo!)
        }
        
        func total(_ i: Int) -> size_t {
            return CF.CPU.HostInfo.getSum(i, mnCount, mpInfo)
        }
    }
}
