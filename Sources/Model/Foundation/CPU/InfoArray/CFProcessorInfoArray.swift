//
//  CFProcessorInfoArray.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/28.
//
//
///*
// <codex>
// <abstract>
// Utility methods for processor info array management.
// </abstract>
// </codex>
// */
//
//#ifndef _CORE_FOUNDATION_PROCESSOR_INFO_ARRAY_H_
//#define _CORE_FOUNDATION_PROCESSOR_INFO_ARRAY_H_
//
//#import <mach/mach.h>
import Darwin.Mach

//### <mach/mach_init.h>
//#define	mach_task_self() mach_task_self_
func mach_task_self() -> mach_port_t {return mach_task_self_}
//
//#ifdef __cplusplus
//
//namespace CF
//{
extension CF {
//    processor_info_array_t ProcessorInfoArrayCreate(const natural_t& nSize,
//                                                    kern_return_t& err);
//
//    processor_info_array_t ProcessorInfoArrayCreateCopy(const natural_t& nSizeDst,
//                                                        processor_info_array_t pInfoSrc,
//                                                        kern_return_t& err);
//
//    kern_return_t ProcessorInfoArrayCopy(const natural_t& nSize,
//                                         processor_info_array_t pInfoSrc,
//                                         processor_info_array_t pInfoDst);
//
//    kern_return_t ProcessorInfoArrayDelete(const natural_t& nSize,
//                                           processor_info_array_t pInfo);
//} // CF
//
//#endif
//
//#endif
//
///*
// <codex>
// <import>CFProcessorInfoArray.h</import>
// </codex>
// */
//
//#include <mach/vm_map.h>
//
//#import "CFProcessorInfoArray.h"
//
//typedef vm_address_t * vm_address_ref;
    typealias vm_address_ref = UnsafeMutablePointer<vm_address_t>
//
//processor_info_array_t CF::ProcessorInfoArrayCreate(const natural_t& nSize,
//                                                    kern_return_t& err)
//{
    static func ProcessorInfoArrayCreate(nSize: natural_t,
        inout _ err: kern_return_t) -> processor_info_array_t
    {
//    processor_info_array_t pInfo = nullptr;
        var pInfo: processor_info_array_t = nil
//
//    err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
        err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
//
//    if(err == KERN_SUCCESS)
//    {
        if err == KERN_SUCCESS {
//        err = vm_allocate(mach_task_self(),
            err = withUnsafeMutablePointer(&pInfo) {pInfoPtr in
                vm_allocate(mach_task_self(),
//                          vm_address_ref(&pInfo),
                    vm_address_ref(pInfoPtr),
//                          nSize,
                    vm_size_t(nSize),
//                          VM_FLAGS_ANYWHERE);
                    VM_FLAGS_ANYWHERE)
            }
//    } // if
        }
//
//    return pInfo;
        return pInfo
//} // ProcessorInfoArrayCreate
    }
//
//processor_info_array_t CF::ProcessorInfoArrayCreateCopy(const natural_t& nSizeDst,
//                                                        processor_info_array_t pInfoSrc,
//                                                        kern_return_t& err)
//{
    static func ProcessorInfoArrayCreateCopy(nSizeDst: natural_t,
        _ pInfoSrc: processor_info_array_t,
        inout _ err: kern_return_t) -> processor_info_array_t
    {
//    processor_info_array_t pInfoDst = nullptr;
        var pInfoDst: processor_info_array_t = nil
//
//    err = (nSizeDst) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
        err = (nSizeDst != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
//
//    if(err == KERN_SUCCESS)
//    {
        if err == KERN_SUCCESS {
            err = withUnsafeMutablePointer(&pInfoDst) {pInfoDstPtr in
//        err = vm_allocate(mach_task_self(),
                vm_allocate(mach_task_self(),
//                          vm_address_ref(&pInfoDst),
                    vm_address_ref(pInfoDstPtr),
//                          nSizeDst,
                    vm_size_t(nSizeDst),
//                          VM_FLAGS_ANYWHERE);
                    VM_FLAGS_ANYWHERE)
            }
//
//        if(err == KERN_SUCCESS)
//        {
            if err == KERN_SUCCESS {
                
//            err = vm_copy(mach_task_self(),
                err = vm_copy(mach_task_self(),
//                          vm_address_t(pInfoSrc),
                    unsafeBitCast(pInfoSrc, vm_address_t.self),
//                          nSizeDst,
                    vm_size_t(nSizeDst),
//                          vm_address_t(pInfoDst));
                    unsafeBitCast(pInfoDst, vm_address_t.self))
//        } // if
            }
//    } // if
        }
//
//    return pInfoDst;
        return pInfoDst
//} // ProcessorInfoArrayCreateCopy
    }
//
//kern_return_t CF::ProcessorInfoArrayCopy(const natural_t& nSize,
    static func ProcessorInfoArrayCopy(nSize: natural_t,
        _ pInfoSrc: processor_info_array_t,
        _ pInfoDst: processor_info_array_t) -> kern_return_t
    {
//                                         processor_info_array_t pInfoSrc,
//                                         processor_info_array_t pInfoDst)
//{
//    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
//
//    if(err == KERN_SUCCESS)
//    {
        if err == KERN_SUCCESS {
//        err = vm_copy(mach_task_self(),
            err = vm_copy(mach_task_self(),
//                      vm_address_t(pInfoSrc),
                unsafeBitCast(pInfoSrc, vm_address_t.self),
//                      nSize,
                vm_size_t(nSize),
//                      vm_address_t(pInfoDst));
                unsafeBitCast(pInfoDst, vm_address_t.self))
//    } // if
        }
//
//    return err;
        return err
//} // ProcessorInfoArrayCopy
    }
//
//kern_return_t CF::ProcessorInfoArrayDelete(const natural_t& nSize,
//                                           processor_info_array_t pInfo)
    static func ProcessorInfoArrayDelete(nSize: natural_t,
        _ pInfo: processor_info_array_t) -> kern_return_t
    {
//{
//    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
//
//    if(err == KERN_SUCCESS)
//    {
        if err == KERN_SUCCESS {
//        err = vm_deallocate(mach_task_self(), vm_address_t(pInfo), nSize);
            err = vm_deallocate(mach_task_self(), unsafeBitCast(pInfo, vm_address_t.self), vm_size_t(nSize))
//
//        pInfo = nullptr;
//    } // if
        }
//
//    return err;
        return err
//} // ProcessorInfoArrayDelete
    }
}