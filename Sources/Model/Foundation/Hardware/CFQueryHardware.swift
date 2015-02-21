//
//  CFQueryHardware.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/30.
//
//
/*
     File: CFQueryHardware.h
     File: CFQueryHardware.mm
 Abstract:
 Utility class for querying hardware features.

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

import Foundation

extension CF {
    
    //MARK: -
    //MARK: Namespace
    
    public struct Query {
        
        //MARK: -
        //MARK: Public - Constants
        
        public struct Frequency {
            public static let kGigaHertz = 1.0e-9
            public static let kMegaHertz = 1.0e-6
            public static let kKiloHertz = 1.0e-3
            public static let kHertz = 1.0
        }
        
        //MARK: -
        //MARK: Private - Constants
        
        private static let  kGigaBytes: size_t = 1073741824
        
        //MARK: -
        //MARK: Public - Class
        
        public class Hardware {
            
            private var m_Model: String = ""
            private var mnCPU: Double = 0
            private var mnFreq: Double = 0
            private var mnScale: Double = 0
            private var mnCores: size_t = 0
            private var mnSize: size_t = 0
            
            private class func getMemSize(inout gigabytes: size_t) -> Int {
                
                var size = size_t(strideof(size_t))
                var bytes = size_t(strideof(size_t))
                
                let result = sysctlbyname("hw.memsize", &bytes, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for memory size!")
                } else {
                    gigabytes = bytes / kGigaBytes
                }
                
                return Int(result)
            }
            
            private class func getCPUCount(inout count: size_t) -> Int {
                var size = size_t(strideof(size_t))
                
                let result = sysctlbyname("hw.physicalcpu_max", &count, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for max physical cpu count!")
                }
                
                return Int(result)
            }
            
            private class func getCPUClock(inout clock: Double) -> Int {
                var freq: size_t = 0
                var size = size_t(strideof(size_t))
                
                let result = sysctlbyname("hw.cpufrequency_max", &freq, &size, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed for max cpu frequency!")
                } else {
                    clock = Double(freq)
                }
                
                return Int(result)
            }
            
            private class func getModel(inout model: String) -> Int {
                var nLength: size_t = 0
                
                let result = sysctlbyname("hw.model", nil, &nLength, nil, 0)
                
                if result < 0 {
                    NSLog("sysctlbyname() failed in acquring string length for the hardware model!")
                    
                    return Int(result)
                }
                
                if nLength != 0 {
                    var pModel: [CChar] = [CChar](count: Int(nLength), repeatedValue: 0)
                    
                    let result = sysctlbyname("hw.model", &pModel, &nLength, nil, 0)
                    
                    if result < 0 {
                        NSLog("sysctlbyname() failed in acquring a hardware model name!")
                    } else {
                        model = String.fromCString(pModel)!
                        
                    }
                }
                
                return Int(result)
            }

            //MARK: -
            //MARK: Public - Hardware
            
            public init(frequency: Double = CF.Query.Frequency.kGigaHertz) {
                mnCores = 0
                mnCPU = 0.0
                mnFreq  = (frequency > 0.0) ? frequency : CF.Query.Frequency.kGigaHertz
                mnScale = mnFreq
                
                var result = CF.Query.Hardware.getCPUCount(&mnCores)
                
                if result >= 0 {
                    result = CF.Query.Hardware.getCPUClock(&mnCPU)
                    
                    if result >= 0 {
                        mnScale *= mnFreq * mnCPU * Double(mnCores)
                    }
                }
                CF.Query.Hardware.getMemSize(&mnSize)
                CF.Query.Hardware.getModel(&m_Model)
            }

            //CF::Query::Hardware::~Hardware()
            //{
            //    mnCores = 0;
            //    mnSize  = 0;
            //    mnFreq  = 0.0f;
            //    mnCPU   = 0.0f;
            //    mnScale = 0.0f;
            //
            //    m_Model.clear();
            //} // Destructor
            
            public init(hw: CF.Query.Hardware) {
                mnCores = hw.mnCores
                mnSize = hw.mnSize
                mnCPU = hw.mnCPU
                mnFreq = hw.mnFreq
                mnScale = hw.mnScale
                m_Model = hw.m_Model
            }

            //CF::Query::Hardware& CF::Query::Hardware::operator=(const CF::Query::Hardware& hw)
            //{
            // 	if(this != &hw)
            //    {
            //        mnCores = hw.mnCores;
            //        mnSize  = hw.mnSize;
            //        mnCPU   = hw.mnCPU;
            //        mnFreq  = hw.mnFreq;
            //        mnScale = hw.mnScale;
            //        m_Model = hw.m_Model;
            //    } // if
            //
            //    return *this;
            //} // operator=
            
            public func setFrequency(frequency: Double) {
                mnFreq   = (frequency > 0.0) ? frequency : CF.Query.Frequency.kGigaHertz
                mnScale  = mnFreq
                mnScale *= mnFreq * mnCPU * Double(mnCores)
            }
            
            public var cores: size_t {
                return mnCores
            }
            
            public var cpu: Double {
                return mnCPU
            }
            
            public var memory: size_t {
                return mnSize
            }
            
            public var scale: Double {
                return mnScale
            }
            
            public var model: String {
                return m_Model
            }
            
            public class var instance: CF.Query.Hardware {
                struct My {
                    static let instance = CF.Query.Hardware()
                }
                return My.instance
            }
        }
    }
}