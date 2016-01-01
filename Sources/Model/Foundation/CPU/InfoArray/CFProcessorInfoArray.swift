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

import Darwin.Mach

//### <mach/mach_init.h>
//#define	mach_task_self() mach_task_self_
func mach_task_self() -> mach_port_t {return mach_task_self_}

extension CF {
    
    typealias vm_address_ref = UnsafeMutablePointer<vm_address_t>
    
    static func ProcessorInfoArrayCreate(nSize: natural_t,
        inout _ err: kern_return_t) -> processor_info_array_t
    {
        var pInfo: processor_info_array_t = nil
        
        err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = withUnsafeMutablePointer(&pInfo) {pInfoPtr in
                vm_allocate(mach_task_self(),
                    vm_address_ref(pInfoPtr),
                    vm_size_t(nSize),
                    VM_FLAGS_ANYWHERE)
            }
        }
        
        return pInfo
    }
    
    static func ProcessorInfoArrayCreateCopy(nSizeDst: natural_t,
        _ pInfoSrc: processor_info_array_t,
        inout _ err: kern_return_t) -> processor_info_array_t
    {
        var pInfoDst: processor_info_array_t = nil
        
        err = (nSizeDst != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = withUnsafeMutablePointer(&pInfoDst) {pInfoDstPtr in
                vm_allocate(mach_task_self(),
                    vm_address_ref(pInfoDstPtr),
                    vm_size_t(nSizeDst),
                    VM_FLAGS_ANYWHERE)
            }
            
            if err == KERN_SUCCESS {
                
                err = vm_copy(mach_task_self(),
                    unsafeBitCast(pInfoSrc, vm_address_t.self),
                    vm_size_t(nSizeDst),
                    unsafeBitCast(pInfoDst, vm_address_t.self))
            }
        }
        
        return pInfoDst
    }
    
    static func ProcessorInfoArrayCopy(nSize: natural_t,
        _ pInfoSrc: processor_info_array_t,
        _ pInfoDst: processor_info_array_t) -> kern_return_t
    {
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = vm_copy(mach_task_self(),
                unsafeBitCast(pInfoSrc, vm_address_t.self),
                vm_size_t(nSize),
                unsafeBitCast(pInfoDst, vm_address_t.self))
        }
        
        return err
    }
    
    static func ProcessorInfoArrayDelete(nSize: natural_t,
        _ pInfo: processor_info_array_t) -> kern_return_t
    {
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = vm_deallocate(mach_task_self(), unsafeBitCast(pInfo, vm_address_t.self), vm_size_t(nSize))
            
        }
        
        return err
    }
}