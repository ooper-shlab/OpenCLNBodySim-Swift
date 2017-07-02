//
//  GLUQuery.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility class for querying OpenGL for vendor, version, and renderer.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension GLU {
    open class Query {
        
        fileprivate var m_Flag: [Bool] = [false, false, false, false]
        fileprivate var m_Regex: [GLregex?] = [nil, nil, nil, nil]
        fileprivate var m_String: [GLstring] = ["", "", "", ""]
    }
}

//MARK: -
//MARK: Private - Enumerated Types

extension GLU {
    fileprivate static let QueryRenderer = 0
    fileprivate static let QueryVendor = 1
    fileprivate static let QueryVersion = 2
    fileprivate static let QueryInfo = 3
    
    fileprivate static let QueryIsAMD = 0
    fileprivate static let QueryIsATI = 1
    fileprivate static let QueryIsNVidia = 2
    fileprivate static let QueryIsIntel = 3
    
}

//MARK: -
//MARK: Private - Utilities

extension GLU.Query {
    private func createString(_ name: GLenum) -> String {
        let pString = glGetString(name)
        
        return GLstring(cString: pString!)
    }
    
    private func match(_ i: Int, _ j: Int) -> Bool {
        return m_Regex[j]!.matches(m_String[i])
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
        
        m_Regex[GLU.QueryIsAMD]    = try! GLregex("AMD|amd")
        m_Regex[GLU.QueryIsATI]    = try! GLregex("ATI|ati")
        m_Regex[GLU.QueryIsNVidia] = try! GLregex("NVIDIA|nVidia|NVidia|nvidia")
        m_Regex[GLU.QueryIsIntel]  = try! GLregex("Intel|intel|INTEL")
        
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
    
    public func match(_ rKey: String) -> Bool {
        var bSuccess = !rKey.isEmpty
        
        if bSuccess {
            let found = m_String[GLU.QueryRenderer].range(of: rKey)
            
            bSuccess = found != nil
        }
        
        return bSuccess
    }
    
    public func match(_ rKeys: GLstrings) -> Bool {
        var bSuccess = !rKeys.isEmpty
        
        if bSuccess {
            
            let expr = rKeys.joined(separator: "|")
            
            let regex = try! GLregex(expr)
            
            bSuccess = regex.matches(m_String[GLU.QueryRenderer])
        }
        
        return bSuccess
    }
    
}
