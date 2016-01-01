//
//  CFQueue.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Utility functor for creating dispatch queues with a unique identifier
 */


import Foundation

extension CF {
    class Queue {
        
        var attribute: dispatch_queue_attr_t?
        
        private var m_SQID: String
        
        init(_ attrib: dispatch_queue_attr_t? = DISPATCH_QUEUE_SERIAL) {
            attribute = attrib
            m_SQID    = ""
        }
        
        var identifier: String {
            return m_SQID
        }
        
        func createQueue(label: String) -> dispatch_queue_t {
            let qid = NSUUID()
            
            let sqid = qid.UUIDString
            
            if label.isEmpty {
                m_SQID = sqid
            } else {
                m_SQID = "\(label).\(sqid)"
            }
            
            return dispatch_queue_create(m_SQID, attribute)
        }
    }
}
