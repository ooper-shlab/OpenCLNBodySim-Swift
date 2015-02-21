//
//  GLUQuery.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: GLUQuery.h
     File: GLUQuery.mm
 Abstract:
 Utility class for querying OpenGL for vendor, version, and renderer.

  Version: 3.3

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2014 Apple Inc. All Rights Reserved.

 */

import Cocoa
import OpenGL

extension GLU {
    public class Query {
        
        private var m_Flag: [Bool] = [false, false, false, false]
        private var m_Regex: [GLregex!] = [nil, nil, nil, nil]
        private var m_String: [GLstring] = ["", "", "", ""]
    }
}

//MARK: -
//MARK: Private - Enumerated Types

extension GLU {
    private static let QueryRenderer = 0
    private static let QueryVendor = 1
    private static let QueryVersion = 2
    private static let QueryInfo = 3
    
    private static let QueryIsAMD = 0
    private static let QueryIsATI = 1
    private static let QueryIsNVidia = 2
    private static let QueryIsIntel = 3
    
}

//MARK: -
//MARK: Private - Utilities

extension GLU.Query {
    private func createString(name: GLenum) -> String {
        let pString = glGetString(name)
        
        return GLstring(pString)
    }
    
    private func match(i: Int, _ j: Int) -> Bool {
        return m_Regex[j].matches(m_String[i])
    }
    
    private func match(#expr: GLstring) -> Bool {
        let regex = GLregex(expr)!
        
        return regex.matches(m_String[GLU.QueryRenderer])
    }
    
    //MARK: -
    //MARK: Public - Constructor
    
    public class func create() -> GLU.Query {
        let instance = GLU.Query()
        instance.initialize()
        return instance
    }
    private func initialize() {
        m_String[GLU.QueryRenderer] = createString(GL_RENDERER.ui)
        m_String[GLU.QueryVendor]   = createString(GL_VENDOR.ui)
        m_String[GLU.QueryVersion]   = createString(GL_VERSION.ui)
        
        m_String[GLU.QueryInfo] =
            m_String[GLU.QueryRenderer] + "\n"
            +   m_String[GLU.QueryVendor]   + "\n"
            +   m_String[GLU.QueryVersion]
        
        m_Regex[GLU.QueryIsAMD]    = GLregex("AMD|amd")
        m_Regex[GLU.QueryIsATI]    = GLregex("ATI|ati")
        m_Regex[GLU.QueryIsNVidia] = GLregex("NVIDIA|nVidia|NVidia|nvidia")
        m_Regex[GLU.QueryIsIntel]  = GLregex("Intel|intel|INTEL")
        
        m_Flag[GLU.QueryIsAMD]    = match(GLU.QueryVendor, GLU.QueryIsAMD)
        m_Flag[GLU.QueryIsATI]    = match(GLU.QueryVendor, GLU.QueryIsATI)
        m_Flag[GLU.QueryIsNVidia] = match(GLU.QueryVendor, GLU.QueryIsNVidia)
        m_Flag[GLU.QueryIsIntel]  = match(GLU.QueryVendor, GLU.QueryIsIntel)
    }
    
    //MARK: -
    //MARK: Public - Accessors
    
    public var info: GLstring {
        return m_String[GLU.QueryInfo]
    }
    
    public var renderer: GLstring {
        return m_String[GLU.QueryRenderer]
    }
    
    public var vendor: String {
        return m_String[GLU.QueryVendor]
    }
    
    public var version: String {
        return m_String[GLU.QueryVersion]
    }
    
    //MARK: -
    //MARK: Public - Queries
    
    public var isAMD: Bool {
        return m_Flag[GLU.QueryIsAMD]
    }
    
    public var isATI: Bool {
        return m_Flag[GLU.QueryIsATI]
    }
    
    public var isNVidia: Bool {
        return m_Flag[GLU.QueryIsNVidia]
    }
    
    public var isIntel: Bool {
        return m_Flag[GLU.QueryIsIntel]
    }
    
    public func match(rKey: String) -> Bool {
        var bSuccess = !rKey.isEmpty
        
        if bSuccess {
            let found = m_String[GLU.QueryRenderer].rangeOfString(rKey)
            
            bSuccess = found != nil
        }
        
        return bSuccess
    }
    
    public func match(rKeys: GLstrings) -> Bool {
        var bSuccess = !rKeys.isEmpty
        
        if bSuccess {
            
            let expr = "|".join(rKeys)
            
            bSuccess = match(expr: expr)
        }
        
        return bSuccess
    }
    
}