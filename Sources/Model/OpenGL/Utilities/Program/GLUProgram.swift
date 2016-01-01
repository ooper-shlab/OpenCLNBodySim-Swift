//
//  GLUProgram.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
<codex>
<abstract>
Utility method for creating an OpenGL program object.
</abstract>
</codex>
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
        
        private enum Shader {
            private static func sourceCreate(target: GLenum, _ pName: String) -> GLstring {
                var pExt: String? = nil
                //var shader: GLstring = "" //### not used
                
                switch target {
                case GL_VERTEX_SHADER.ui:
                    pExt = "vsh"
                    //                    shader = "vertex"
                    
                case GL_GEOMETRY_SHADER_EXT.ui:
                    pExt = "gsh"
                    //                    shader = "geometry"
                    
                case GL_FRAGMENT_SHADER.ui:
                    pExt = "fsh"
                    //                    shader = "fragment"
                    
                default:
                    break
                }
                
                let file = CF.File(pName, pExt!)
                
                return file.string ?? ""
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
                    
                    //                    var actualInfoLogLength: GLsizei = GLsizei(nInfoLogLength)
                    glGetShaderInfoLog(nShader,
                        //                        actualInfoLogLength,
                        nInfoLogLength,
                        //                        &actualInfoLogLength,
                        &nInfoLogLength,
                        &pInfoLog)
                    print(">> INFO: OpenGL Shader - Compile log:")
                    print(GLstring.fromCString(pInfoLog)!)
                    
                }
            }
            
            private static func validate(nShader: GLuint, _ source: String) -> Bool {
                var nIsCompiled: GLint = 0
                
                glGetShaderiv(nShader, GL_COMPILE_STATUS.ui, &nIsCompiled)
                
                if nIsCompiled == 0 {
                    if !source.isEmpty {
                        print(">> WARNING: OpenGL Shader - Failed to compile shader!")
                        print(source)
                    }
                    
                    print(">> WARNING: OpenGL Shader - Deleted shader object with id = \(nShader)")
                    
                    glDeleteShader(nShader)
                }
                
                return nIsCompiled != 0
            }
            
            private static func create(target: GLenum, _ source: String) -> GLuint {
                var nShader: GLuint = 0
                
                if !source.isEmpty {
                    nShader = glCreateShader(target)
                    
                    if nShader != 0 {
                        source.withCString {pSource in
                            var ptrSource = pSource
                            
                            glShaderSource(nShader, 1, &ptrSource, nil)
                            glCompileShader(nShader)
                            
                            Shader.getInfoLog(nShader)
                        }
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
                
                print(">> INFO: OpenGL Program - Link log:")
                print(GLstring.fromCString(pInfoLog))
                
            }
        }
        
        private class func validate(nProgram: GLuint) -> Bool {
            var nIsLinked: GLint = 0
            
            glGetProgramiv(nProgram, GL_LINK_STATUS.ui, &nIsLinked)
            
            if nIsLinked == 0 {
                print(">> WARNING: OpenGL Shader - Deleted program object with id = \(nProgram)")
                
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
            outVert nOutVert: GLsizei)
        {
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
