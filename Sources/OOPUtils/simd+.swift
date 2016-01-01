//
//  simd+.swift
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

import simd

public typealias Float2 = float2
public typealias Float3 = float3
public typealias Float4 = float4
public typealias Float4x4 = float4x4

func + (lhs: Float, rhs: float3) -> float3 {
    return float3(lhs+rhs.x, lhs+rhs.y, lhs+rhs.z)
}
