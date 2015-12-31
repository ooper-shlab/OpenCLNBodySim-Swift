//
//  CFQueue.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// Copyright (C) 2015 Apple Inc. All Rights Reserved.
// See LICENSE.txt for this sample’s licensing information
//
// Abstract:
// Utility functor for creating dispatch queues with a unique identifier
// */
//
//
//#ifndef _CORE_FOUNDATION_QUEUE_H_
//#define _CORE_FOUNDATION_QUEUE_H_
//
//#import <random>
//#import <string>
//
//#import <Foundation/Foundation.h>
import Foundation
//
//#ifdef __cplusplus
//
//namespace CF
//{
extension CF {
//    class Queue
//    {
    class Queue {
//    public:
//        Queue(const dispatch_queue_attr_t& attribute = DISPATCH_QUEUE_SERIAL);
//
//        virtual ~Queue();
//
//        const std::string identifier() const;
//
//        dispatch_queue_t operator()(const std::string& label);
//
//    public:
//        dispatch_queue_attr_t attribute;  // Dispatch queue attribute
        var attribute: dispatch_queue_attr_t?
//
//    private:
//
//        std::string        m_SQID;      // Dispatch queue label plus an attched id
        private var m_SQID: String
//        std::random_device m_Device;    // A device for random number generation
//    };
//} // Queue
//
//#endif
//
//#endif
//
//#import <strstream>
//
//#include "CFQueue.h"
//
//CF::Queue::Queue(const dispatch_queue_attr_t& attrib)
//{
        init(_ attrib: dispatch_queue_attr_t? = DISPATCH_QUEUE_SERIAL) {
//    attribute = attrib;
            attribute = attrib
//    m_SQID    = "";
            m_SQID    = ""
//} // Constructor
        }
//
//CF::Queue::~Queue()
//{
//    attribute = nullptr;
//    m_SQID    = "";
//} // Destructor
//
//const std::string CF::Queue::identifier() const
//{
        var identifier: String {
//    return m_SQID;
            return m_SQID
//} // identifier
        }
//
//dispatch_queue_t CF::Queue::operator()(const std::string& label)
//{
        func createQueue(label: String) -> dispatch_queue_t {
//    uint64_t qid = m_Device();
            let qid = NSUUID()
//
//    std::strstream sqid;
//
//    sqid << qid;
            let sqid = qid.UUIDString
//
//    if(label.empty())
//    {
            if label.isEmpty {
//        m_SQID = sqid.str();
                m_SQID = sqid
//    } // if
//    else
//    {
            } else {
//        m_SQID  = label + ".";
//        m_SQID += sqid.str();
                m_SQID = "\(label).\(sqid)"
//    } // else
            }
//
//    m_SQID += "\0";
//
//    return dispatch_queue_create(m_SQID.c_str(), attribute);
            return dispatch_queue_create(m_SQID, attribute)
//} // Operator()
        }
    }
}