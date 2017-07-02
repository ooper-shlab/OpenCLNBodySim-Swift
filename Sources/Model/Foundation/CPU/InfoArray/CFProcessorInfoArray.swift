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
    
    static func ProcessorInfoArrayCreate(_ nSize: natural_t,
        _ err: inout kern_return_t) -> processor_info_array_t
    {
        var pInfo: processor_info_array_t? = nil
        
        err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = withUnsafeMutableBytes(of: &pInfo) {pInfoBuf in
                vm_allocate(mach_task_self(),
                    pInfoBuf.baseAddress!.assumingMemoryBound(to: vm_address_t.self),
                    vm_size_t(nSize),
                    VM_FLAGS_ANYWHERE)
            }
        }
        
        return pInfo!
    }
    
    static func ProcessorInfoArrayCreateCopy(_ nSizeDst: natural_t,
        _ pInfoSrc: processor_info_array_t,
        _ err: inout kern_return_t) -> processor_info_array_t
    {
        var pInfoDst: processor_info_array_t? = nil
        
        err = (nSizeDst != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = withUnsafeMutableBytes(of: &pInfoDst) {pInfoDstBuf in
                vm_allocate(mach_task_self(),
                    pInfoDstBuf.baseAddress!.assumingMemoryBound(to: vm_address_t.self),
                    vm_size_t(nSizeDst),
                    VM_FLAGS_ANYWHERE)
            }
            
            if err == KERN_SUCCESS {
                
                err = vm_copy(mach_task_self(),
                    vm_address_t(bitPattern: pInfoSrc),
                    vm_size_t(nSizeDst),
                    unsafeBitCast(pInfoDst, to: vm_address_t.self))
            }
        }
        
        return pInfoDst!
    }
    
    static func ProcessorInfoArrayCopy(_ nSize: natural_t,
        _ pInfoSrc: processor_info_array_t,
        _ pInfoDst: processor_info_array_t) -> kern_return_t
    {
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = vm_copy(mach_task_self(),
                vm_address_t(bitPattern: pInfoSrc),
                vm_size_t(nSize),
                vm_address_t(bitPattern: pInfoDst))
        }
        
        return err
    }
    
    @discardableResult
    static func ProcessorInfoArrayDelete(_ nSize: natural_t,
        _ pInfo: processor_info_array_t) -> kern_return_t
    {
        var err = (nSize != 0) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT
        
        if err == KERN_SUCCESS {
            err = vm_deallocate(mach_task_self(), vm_address_t(bitPattern: pInfo), vm_size_t(nSize))
            
        }
        
        return err
    }
}
