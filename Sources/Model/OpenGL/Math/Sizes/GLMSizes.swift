//
//  GLMSizes.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
OpenGL size types.
</abstract>
</codex>
 */

import OpenGL

extension GLM {
    public struct Size {
        
        private static let GLSizeChar = MemoryLayout<GLchar>.stride
        private static let GLSizeChrPtr = MemoryLayout<UnsafePointer<GLchar>>.stride
        private static let GLSizeFloat = MemoryLayout<GLfloat>.stride
        private static let GLSizeDouble = MemoryLayout<GLdouble>.stride
        private static let GLSizeSignedByte = MemoryLayout<GLbyte>.stride
        private static let GLSizeSignedBytePtr = MemoryLayout<UnsafePointer<GLbyte>>.stride
        private static let GLSizeSignedShort = MemoryLayout<GLshort>.stride
        private static let GLSizeSignedInt = MemoryLayout<GLint>.stride
        private static let GLSizeUnsignedByte = MemoryLayout<GLubyte>.stride
        private static let GLSizeUnsignedShort = MemoryLayout<GLushort>.stride
        private static let GLSizeUnsignedInt = MemoryLayout<GLuint>.stride
        private static let GLSizeLong = MemoryLayout<Int64>.stride
        private static let GLSizeULong = MemoryLayout<UInt64>.stride
        
        public static let kByte = GLSizeSignedByte
        public static let kBytePtr = GLSizeSignedBytePtr
        public static let kChar = GLSizeChar
        public static let kCharPtr = GLSizeChrPtr
        public static let kFloat = GLSizeFloat
        public static let kHFloat = GLSizeFloat / 2
        public static let kDouble = GLSizeDouble
        public static let kShort = GLSizeSignedShort
        public static let kInt = GLSizeSignedInt
        public static let kLong = GLSizeLong
        public static let kUByte = GLSizeUnsignedByte
        public static let kUInt = GLSizeUnsignedInt
        public static let kULong = GLSizeULong
        public static let kUShort = GLSizeUnsignedShort
    }
}
