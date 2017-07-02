//
//  GLContainers.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
OpenGL container type definitions.
</abstract>
</codex>
 */

import Cocoa

import OpenGL

public typealias GLstring = String
extension GLstring {
    public init(_ pString: UnsafeRawPointer) {
        self = String(cString: pString.assumingMemoryBound(to: CChar.self))
    }
}
public typealias GLregex = NSRegularExpression
extension GLregex {
    public convenience init(_ pattern: String, options: NSRegularExpression.Options = []) throws {
        try self.init(pattern: pattern, options: options)
    }
    
    public func matches(_ string: String) -> Bool {
        let range = NSMakeRange(0, string.utf16.count)
        return self.numberOfMatches(in: string, options: [], range: range) > 0
    }
}

public typealias GLuints = [GLuint]
public typealias GLenums = [GLenum]
public typealias GLstrings = [GLstring]

public typealias GLhandles = GLuints
public typealias GLshaders = GLuints
public typealias GLtargets = GLenums

public typealias GLproperties = [GLuint: GLuint]
public typealias GLrenderers = [GLint: GLproperties]
public typealias GLdisplays = [GLuint: GLrenderers]
public typealias GLpropertynames = [GLuint: GLstring]
public typealias GLsources = [GLenum: GLstring]

public typealias GLstringset = Set<GLstring>

