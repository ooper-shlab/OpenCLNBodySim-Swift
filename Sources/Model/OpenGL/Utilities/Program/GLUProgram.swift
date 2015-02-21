//
//  GLUProgram.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: GLUProgram.h
     File: GLUProgram.mm
 Abstract:
 Utility method for creating an OpenGL program object.

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
    public class Program {
        init() {}
        
        deinit {destruct()}
        
        private var mnProgram: GLuint = 0
        private var mnInType: GLenum = 0
        private var mnOutType: GLenum = 0
        private var mnOutVert: GLsizei = 0
        private var m_Sources: GLsources = [:]
        
        //MARK: -
        //MARK: Private - Utilities - Shaders
        
        private struct Shader {
            private static func sourceCreate(target: GLenum, _ pName: String) -> GLstring {
                var pExt: String? = nil
                
                var shader: GLstring = ""
                
                switch target {
                case GL_VERTEX_SHADER.ui:
                    pExt = "vsh"
                    shader = "vertex"
                    
                case GL_GEOMETRY_SHADER_EXT.ui:
                    pExt = "gsh"
                    shader = "geometry"
                    
                case GL_FRAGMENT_SHADER.ui:
                    pExt = "fsh"
                    shader = "fragment"
                    
                default:
                    break
                }
                
                let pStream = CF.IFStream(name: pName, ext: pExt)!
                
                var source: GLstring = ""
                
                if !pStream.isValid {
                    fatalError(">> ERROR: Failed acquiring \(shader) shader source!")
                } else {
                    source = GLstring(pStream.buffer)
                }
                
                return source
            }
            
            private static func sourcesCreate(targets: GLtargets, _ pName: String) -> GLsources {
                var sources: GLsources = [:]
                
                for target in targets {
                    let source = Shader.sourceCreate(target, pName)
                    
                    if !source.isEmpty {
                        sources[target] = source
                    }
                }
                
                return sources
            }
            
            private static func getInfoLog(nShader: GLuint) {
                var nInfoLogLength: GLint = 0
                
                glGetShaderiv(nShader, GL_INFO_LOG_LENGTH.ui, &nInfoLogLength)
                
                if nInfoLogLength != 0 {
                    var pInfoLog = [GLchar](count: Int(nInfoLogLength), repeatedValue: 0)
                    
                    var actualInfoLogLength: GLsizei = GLsizei(nInfoLogLength)
                    glGetShaderInfoLog(nShader,
                        actualInfoLogLength,
                        &actualInfoLogLength,
                        &pInfoLog)
                    println(">> INFO: OpenGL Shader - Compile log:")
                    println(String.fromCString(pInfoLog)!)
                    
                }
            }
            
            private static func validate(nShader: GLuint, _ source: String) -> Bool {
                var nIsCompiled: GLint = 0
                
                glGetShaderiv(nShader, GL_COMPILE_STATUS.ui, &nIsCompiled)
                
                if nIsCompiled == 0 {
                    if !source.isEmpty {
                        println(">> WARNING: OpenGL Shader - Failed to compile shader!")
                        println(source)
                    }
                    
                    println(">> WARNING: OpenGL Shader - Deleted shader object with id = \(nShader)")
                    
                    glDeleteShader(nShader)
                }
                
                return nIsCompiled != 0
            }
            
            private static func create(target: GLenum, _ source: String) -> GLuint {
                var nShader: GLuint = 0
                
                if !source.isEmpty {
                    nShader = glCreateShader(target)
                    
                    if nShader != 0 {
                        var pSource = UnsafePointer<GLchar>(source.cStringUsingEncoding(NSUTF8StringEncoding)!)
                        
                        glShaderSource(nShader, 1, &pSource, nil)
                        glCompileShader(nShader)
                        
                        Shader.getInfoLog(nShader)
                    }
                    
                    if !Shader.validate(nShader, source) {
                        nShader = 0
                    }
                }
                
                return nShader
            }
        }
        
        //MARK: -
        //MARK: Private - Utilities - Programs
        
        private class func getInfoLog(nProgram: GLuint) {
            var nInfoLogLength: GLint = 0
            
            glGetProgramiv(nProgram, GL_INFO_LOG_LENGTH.ui, &nInfoLogLength)
            
            if nInfoLogLength != 0 {
                var pInfoLog = [GLchar](count: Int(nInfoLogLength), repeatedValue: 0)
                
                glGetProgramInfoLog(nProgram,
                    nInfoLogLength,
                    &nInfoLogLength,
                    &pInfoLog)
                
                println(">> INFO: OpenGL Program - Link log:")
                println(GLstring(pInfoLog))
                
            }
        }
        
        private class func validate(nProgram: GLuint) -> Bool {
            var nIsLinked: GLint = 0
            
            glGetProgramiv(nProgram, GL_LINK_STATUS.ui, &nIsLinked)
            
            if nIsLinked == 0 {
                println(">> WARNING: OpenGL Shader - Deleted program object with id = \(nProgram)")
                
                glDeleteProgram(nProgram)
            }
            
            return nIsLinked != 0
        }
        
        private class func createShaders(nProgram: GLuint, _ sources: GLsources) -> GLshaders {
            var nShader: GLuint = 0
            
            var shaders: GLshaders = []
            
            for source in sources {
                nShader = Shader.create(source.0, source.1)
                
                if nShader != 0 {
                    glAttachShader(nProgram, nShader)
                    
                    shaders.append(nShader)
                }
            }
            
            return shaders
        }
        
        private class func deleteShaders(shaders: GLshaders) {
            for shader in shaders {
                if shader != 0 {
                    glDeleteShader(shader)
                }
            }
        }
        
        private class func hasGeometryShader(sources: GLsources) -> Bool {
            
            return sources[GL_GEOMETRY_SHADER_EXT.ui] != nil
        }
        
        private class func create(sources: GLsources,
            _ nInType: GLenum,
            _ nOutType: GLenum,
            _ nOutVert: GLsizei) -> GLuint {
                var nProgram: GLuint = 0
                
                if !sources.isEmpty {
                    nProgram = glCreateProgram()
                    
                    if nProgram != 0 {
                        let shaders = createShaders(nProgram, sources)
                        
                        if hasGeometryShader(sources) {
                            glProgramParameteriEXT(nProgram, GL_GEOMETRY_INPUT_TYPE_EXT.ui, GLint(nInType))
                            glProgramParameteriEXT(nProgram, GL_GEOMETRY_OUTPUT_TYPE_EXT.ui, GLint(nOutType))
                            glProgramParameteriEXT(nProgram, GL_GEOMETRY_VERTICES_OUT_EXT.ui, nOutVert)
                        }
                        
                        glLinkProgram(nProgram)
                        
                        deleteShaders(shaders)
                        
                        getInfoLog(nProgram)
                        
                        if !validate(nProgram) {
                            nProgram = 0
                        }
                    }
                }
                
                return nProgram
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        public convenience init(name pName: String) {
            self.init()
            let targets: GLtargets = [GL_VERTEX_SHADER.ui, GL_FRAGMENT_SHADER.ui]
            mnInType  = 0
            mnOutType = 0
            mnOutVert = 0
            m_Sources = Shader.sourcesCreate(targets, pName)
            mnProgram = GLU.Program.create(m_Sources, mnInType, mnOutType, mnOutVert)
        }
        
        public init(name pName: String?,
            inType nInType: GLenum,
            outType nOutType: GLenum,
            outVert nOutVert: GLsizei) {
                if pName != nil {
                    let targets: GLtargets = [GL_VERTEX_SHADER.ui, GL_FRAGMENT_SHADER.ui, GL_GEOMETRY_SHADER_EXT.ui]
                    
                    mnInType = nInType
                    mnOutType = nOutType
                    mnOutVert = nOutVert
                    m_Sources = Shader.sourcesCreate(targets, pName!)
                    mnProgram = GLU.Program.create(m_Sources, mnInType, mnOutType, mnOutVert)
                }
        }
        
        public convenience init(program rProgram: GLU.Program) {
            self.init()
            if !rProgram.m_Sources.isEmpty {
                mnInType  = rProgram.mnInType
                mnOutType = rProgram.mnOutType
                mnOutVert = rProgram.mnOutVert
                m_Sources = rProgram.m_Sources
                mnProgram = GLU.Program.create(m_Sources, mnInType, mnOutType, mnOutVert)
            }
        }
        
        private func destruct() {
            if mnProgram != 0 {
                glDeleteProgram(mnProgram)
                
                mnProgram = 0
            }
            
        }
        
        public var program: GLuint {
            return mnProgram
        }
        
        public func enable() {
            glUseProgram(mnProgram)
        }
        
        public func disable() {
            glUseProgram(0)
        }
        
    }
}