//
//  PointerAssignment.swift
//  OpenCL_NBody_Simulation
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
Copyright (c) 2015, OOPer(NAGATA, Atsuyuki)
All rights reserved.

Use of any parts(functions, classes or any other program language components)
of this file is permitted with no restrictions, unless you
redistribute or use this file in its entirety without modification.
In this case, providing any sort of warranties or not is the user's responsibility.

Redistribution and use in source and/or binary forms, without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*
    Caution:
    The following operators are very unsafe and fragile. Intended to be more experimental than practical. A subtle change of Swift runtime may crash apps using these operators.
    As for now (Swift 2.1), theses operators work as expected for:
        - global variables
        - stored instance properties
 */

//### Very dangerous operator!!!
//Use with extra caution! The assigned pointer may not be valid after assinment operation finished!!!
infix operator =&! :AssignmentPrecedence
func =&! <T>(p: inout UnsafeMutablePointer<T>, v: UnsafeMutablePointer<T>) {
    p = v
}
func =&! <T>(p: inout UnsafePointer<T>, v: UnsafePointer<T>) {
    p = v
}

//### Very dangerous operator!!!
//Use with extra caution! The returned pointer may be pointing some temporary area!!!
prefix operator &!
prefix func &! <T>(v: inout T) -> UnsafeMutablePointer<T> {
    return unsafeMutablePointerTo(&v)
}
prefix func &! <T>(v: inout T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(unsafeMutablePointerTo(&v))
}
private func unsafeMutablePointerTo<T>(_ ptr: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<T> {
    return ptr
}
