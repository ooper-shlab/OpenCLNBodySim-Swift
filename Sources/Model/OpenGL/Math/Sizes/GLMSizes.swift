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
        
        private static let GLSizeChar = strideof(GLchar)
        private static let GLSizeChrPtr = strideof(UnsafePointer<GLchar>)
        private static let GLSizeFloat = strideof(GLfloat)
        private static let GLSizeDouble = strideof(GLdouble)
        private static let GLSizeSignedByte = strideof(GLbyte)
        private static let GLSizeSignedBytePtr = strideof(UnsafePointer<GLbyte>)
        private static let GLSizeSignedShort = strideof(GLshort)
        private static let GLSizeSignedInt = strideof(GLint)
        private static let GLSizeUnsignedByte = strideof(GLubyte)
        private static let GLSizeUnsignedShort = strideof(GLushort)
        private static let GLSizeUnsignedInt = strideof(GLuint)
        private static let GLSizeLong = strideof(Int64)
        private static let GLSizeULong = strideof(UInt64)
        
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
