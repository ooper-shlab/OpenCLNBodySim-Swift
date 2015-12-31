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
//
//#ifndef _CORE_FOUNDATION_CPU_HOST_INFO_H_
//#define _CORE_FOUNDATION_CPU_HOST_INFO_H_
//
//#import <mach/mach.h>
import Darwin.Mach
//
//#ifdef __cplusplus
//
//namespace CF
//{
//    namespace CPU
//    {
extension CF.CPU {
//        class HostInfo
//        {
    class HostInfo {
//        public:
//            HostInfo();
        init() {
            construct()
        }
//
//            HostInfo(const HostInfo& rHostInfo);
        init(hostInfo rHostInfo: HostInfo) {
            construct(rHostInfo)
        }
//
//            virtual ~HostInfo();
//
//            HostInfo& operator=(const HostInfo& rHostInfo);
//
//            const kern_return_t error() const;
//
//            const processor_flavor_t flavor() const;
//
//            const natural_t cpus() const;
//            const natural_t size() const;
//
//            const natural_t user(const uint32_t& i)   const;
//            const natural_t system(const uint32_t& i) const;
//            const natural_t idle(const uint32_t& i)   const;
//            const natural_t nice(const uint32_t& i)   const;
//
//            const size_t total(const uint32_t& i) const;
//
//        private:
//            natural_t              mnCount;
        private var mnCount: natural_t = 0
//            natural_t              mnSize;
        private var mnSize: natural_t = 0
//            processor_flavor_t     mnFlavor;
        private var mnFlavor: processor_flavor_t = 0
//            kern_return_t          mnError;
        private var mnError: kern_return_t = 0
//            processor_info_array_t mpInfo;
        private var mpInfo: processor_info_array_t = nil
//            mach_msg_type_number_t mnInfo;
        private var mnInfo: mach_msg_type_number_t = 0
//        }; // HostInfo
//    } // CPU
//} // CF
//
//#endif
//
//#endif
//
///*
// <codex>
// <import>CFHostInfo.h</import>
// </codex>
// */
//
//#import "CFProcessorInfoArray.h"
//#import "CFCPUHostInfo.h"
//
//using namespace CF::CPU;
//
//static const size_t kSizeInteger = sizeof(natural_t);
        private let kSizeInteger = sizeof(natural_t)
//
//static natural_t CFCPUHostInfoGetState(const uint32_t& i,
        static func getState(i: Int,
//                                       const natural_t& nCount,
            _ nCount: natural_t,
//                                       const natural_t& type,
            _ type: Int,
//                                       processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> natural_t
//{
        {
//    natural_t nState = 0;
            var nState: natural_t = 0
//
//    if(pInfo != nullptr)
//    {
            if pInfo != nil {
//        nState = (i < nCount) ? pInfo[CPU_STATE_MAX * i + type] : 0;
                nState = (i < nCount.l) ? pInfo[CPU_STATE_MAX.l * i + type].ui : 0
//    } // if
            }
//
//    return nState;
            return nState
//} // CFCPUHostInfoGetState
        }
//
//static natural_t CFCPUHostInfoGetUserState(const uint32_t& i,
        static func getUserState(i: Int,
//                                           const natural_t& nCount,
            _ nCount: natural_t,
//                                           processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> natural_t
//{
        {
//    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_USER, pInfo);
            return getState(i, nCount, CPU_STATE_USER.l, pInfo)
//} // CFCPUHostInfoGetUserState
        }
//
//static natural_t CFCPUHostInfoGetSystemState(const uint32_t& i,
        static func getSystemState(i: Int,
//                                             const natural_t& nCount,
            _ nCount: natural_t,
//                                             processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> natural_t
//{
        {
//    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_SYSTEM, pInfo);
            return getState(i, nCount, CPU_STATE_SYSTEM.l, pInfo)
//} // CFCPUHostInfoGetSystemState
        }
//
//static natural_t CFCPUHostInfoGetIdleState(const uint32_t& i,
        static func getIdleState(i: Int,
//                                           const natural_t& nCount,
            _ nCount: natural_t,
//                                           processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> natural_t
//{
        {
//    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_IDLE, pInfo);
            return getState(i, nCount, CPU_STATE_IDLE.l, pInfo)
//} // CFCPUHostInfoGetIdleState
        }
//
//static natural_t CFCPUHostInfoGetNiceState(const uint32_t& i,
        static func getNiceState(i: Int,
//                                           const natural_t& nCount,
            _ nCount: natural_t,
//                                           processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> natural_t
//{
        {
//    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_NICE, pInfo);
            return getState(i, nCount, CPU_STATE_NICE.l, pInfo)
//} // CFCPUHostInfoGetNiceState
        }
//
//static size_t CFCPUHostInfoGetSum(const uint32_t& i,
        
        static func getSum(i: Int,
//                                  const natural_t& nCount,
            _ nCount: natural_t,
//                                  processor_info_array_t pInfo)
            _ pInfo: processor_info_array_t) -> size_t
//{
        {
//    natural_t nSum = 0;
            var nSum: size_t = 0
//
//    if((i < nCount) && (pInfo != nullptr))
//    {
            if i < nCount.l && pInfo != nil {
//        natural_t nOffset = CPU_STATE_MAX * i;
                let nOffset = CPU_STATE_MAX.l * i
//        natural_t nUser   = pInfo[nOffset + CPU_STATE_USER];
                let nUser   = pInfo[nOffset + CPU_STATE_USER.l]
//        natural_t nSytem  = pInfo[nOffset + CPU_STATE_SYSTEM];
                let nSytem  = pInfo[nOffset + CPU_STATE_SYSTEM.l]
//        natural_t nIde    = pInfo[nOffset + CPU_STATE_IDLE];
                let nIde    = pInfo[nOffset + CPU_STATE_IDLE.l]
//        natural_t nNice   = pInfo[nOffset + CPU_STATE_NICE];
                let nNice   = pInfo[nOffset + CPU_STATE_NICE.l]
//
//        nSum = nSytem + nIde + nNice + nUser;
                nSum = nSytem.l + nIde.l + nNice.l + nUser.l
//    } // if
            }
//
//    return nSum;
            return nSum
//} // CFCPUHostInfoGetSum
        }
//
//HostInfo::HostInfo()
//{
        private func construct() {
//    mnCount  = 0;
            mnCount  = 0
//    mnInfo   = 0;
            mnInfo   = 0
//    mpInfo   = nullptr;
            mpInfo   = nil
//    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
            mnFlavor = PROCESSOR_CPU_LOAD_INFO
//    mnError  = host_processor_info(mach_host_self(), mnFlavor, &mnCount, &mpInfo, &mnInfo);
            mnError  = host_processor_info(mach_host_self(), mnFlavor, &mnCount, &mpInfo, &mnInfo)
//    mnSize   = kSizeInteger * mnInfo;
            mnSize   = kSizeInteger.ui * mnInfo
//} // Constructor
        }
//
//HostInfo::HostInfo(const HostInfo& rHostInfo)
//{
        private func construct(rHostInfo: HostInfo) {
//    mnCount  = rHostInfo.mnCount;
            mnCount  = rHostInfo.mnCount
//    mnInfo   = rHostInfo.mnInfo;
            mnInfo   = rHostInfo.mnInfo
//    mnSize   = kSizeInteger * rHostInfo.mnInfo;
            mnSize   = kSizeInteger.ui * rHostInfo.mnInfo
//    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
            mnFlavor = PROCESSOR_CPU_LOAD_INFO
//    mpInfo   = ProcessorInfoArrayCreateCopy(mnSize, rHostInfo.mpInfo, mnError);
            mpInfo   = CF.ProcessorInfoArrayCreateCopy(mnSize, rHostInfo.mpInfo, &mnError)
//} // Copy Constructor
        }
//
//HostInfo::~HostInfo()
//{
        private func destruct() {
//    ProcessorInfoArrayDelete(mnSize, mpInfo);
            CF.ProcessorInfoArrayDelete(mnSize, mpInfo)
//
//    mnCount  = 0;
            mnCount  = 0
//    mnInfo   = 0;
            mnInfo   = 0
//    mnSize   = 0;
            mnSize   = 0
//    mnFlavor = 0;
            mnFlavor = 0
//    mnError  = 0;
            mnError  = 0
//} // Destructor
        }
//
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
//
//const kern_return_t HostInfo::error() const
//{
        var error: kern_return_t {
//    return mnError;
            return mnError
//} // error
        }
//
//const processor_flavor_t HostInfo::flavor() const
//{
        var flavor: processor_flavor_t {
//    return mnFlavor;
            return mnFlavor
//} // flavor
        }
//
//const natural_t HostInfo::cpus() const
//{
        var cpus: Int {
//    return mnCount;
            return mnCount.l
//} // cpus
        }
//
//const natural_t HostInfo::size() const
//{
        var size: natural_t {
//    return mnSize;
            return mnSize
//} // size
        }
//
//const natural_t HostInfo::user(const uint32_t& i) const
//{
        func user(i: Int) -> natural_t {
//    return CFCPUHostInfoGetUserState(i, mnCount, mpInfo);
            return CF.CPU.HostInfo.getUserState(i, mnCount, mpInfo)
//} // user
        }
//
//const natural_t HostInfo::system(const uint32_t& i) const
//{
        func system(i: Int) -> natural_t {
//    return CFCPUHostInfoGetSystemState(i, mnCount, mpInfo);
            return CF.CPU.HostInfo.getSystemState(i, mnCount, mpInfo)
//} // system
        }
//
//const natural_t HostInfo::idle(const uint32_t& i) const
//{
        func idle(i: Int) -> natural_t {
//    return CFCPUHostInfoGetIdleState(i, mnCount, mpInfo);
            return CF.CPU.HostInfo.getIdleState(i, mnCount, mpInfo)
//} // idle
        }
//
//const natural_t HostInfo::nice(const uint32_t& i) const
//{
        func nice(i: Int) -> natural_t {
//    return CFCPUHostInfoGetNiceState(i, mnCount, mpInfo);
            return CF.CPU.HostInfo.getNiceState(i, mnCount, mpInfo)
//} // nice
        }
//
//const size_t HostInfo::total(const uint32_t& i) const
//{
        func total(i: Int) -> size_t {
//    return CFCPUHostInfoGetSum(i, mnCount, mpInfo);
            return CF.CPU.HostInfo.getSum(i, mnCount, mpInfo)
//} // total
        }
//
    }
//
}