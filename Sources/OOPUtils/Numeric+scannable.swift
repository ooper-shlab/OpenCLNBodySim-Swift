//
//  Numeric+scannable.swift
//  OpenCL_NBody_Simulation
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/12/28.
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

import Foundation

protocol StringScannable {
    static func scan(scanner: NSScanner) -> Self?
}

extension Float: StringScannable {
    static func scan(scanner: NSScanner) -> Float? {
        var result: Float = 0
        let success = scanner.scanFloat(&result)
        if success {
            return result
        } else {
            return nil
        }
    }
}

extension Double: StringScannable {
    static func scan(scanner: NSScanner) -> Double? {
        var result: Double = 0
        let success = scanner.scanDouble(&result)
        if success {
            return result
        } else {
            return nil
        }
    }
}

extension Int32: StringScannable {
    static func scan(scanner: NSScanner) -> Int32? {
        var result: Int32 = 0
        let success = scanner.scanInt(&result)
        if success {
            return result
        } else {
            return nil
        }
    }
}
extension Int: StringScannable {
    static func scan(scanner: NSScanner) -> Int? {
        var result: Int = 0
        let success = scanner.scanInteger(&result)
        if success {
            return result
        } else {
            return nil
        }
    }
}
extension Int64: StringScannable {
    static func scan(scanner: NSScanner) -> Int64? {
        var result: Int64 = 0
        let success = scanner.scanLongLong(&result)
        if success {
            return result
        } else {
            return nil
        }
    }
}