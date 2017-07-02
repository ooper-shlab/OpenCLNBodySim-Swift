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
        
        var attribute: DispatchQueue.Attributes?
        
        private var m_SQID: String
        
        init(_ attrib: DispatchQueue.Attributes? = DispatchQueue.Attributes()) {
            attribute = attrib
            m_SQID    = ""
        }
        
        var identifier: String {
            return m_SQID
        }
        
        func createQueue(_ label: String) -> DispatchQueue {
            let qid = UUID()
            
            let sqid = qid.uuidString
            
            if label.isEmpty {
                m_SQID = sqid
            } else {
                m_SQID = "\(label).\(sqid)"
            }
            
            return DispatchQueue(label: m_SQID, attributes: attribute!)
        }
    }
}
