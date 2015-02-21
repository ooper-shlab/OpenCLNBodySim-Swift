//
//  CFIFStream.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: CFIFStream.h
     File: CFIFStream.mm
 Abstract:
 Utility methods for managing input file streams.

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

//MARK: -
//MARK: Private - Data Structures

extension CF {
    public class IFStream {
        
        private var mbIsValid: Bool = false
        private var mpBuffer: NSData? = nil
        private var mnLength: size_t = 0
        
        private var url: NSURL? = nil
        
        lazy var scanner: NSScanner = NSScanner(string: NSString(data: self.mpBuffer!, encoding: NSUTF8StringEncoding)!)
    }
}

//MARK: -
//MARK: Private - Utilities - Delete

extension CF.IFStream {
    
    //MARK: -
    //MARK: Private - Utilities - Files
    
    private func read() -> Bool {
        let data = NSData(contentsOfURL: url!)
        var bSuccess = data != nil
        
        if bSuccess {
            let buffer = NSMutableData(data: data!)
            var trailingNul: CChar = 0
            buffer.appendBytes(&trailingNul, length: 1)
            self.mpBuffer = buffer
            
            bSuccess = self.mpBuffer != nil
        } else {
            NSLog(">> ERROR: File has size 0!")
        }
        
        return bSuccess
    }
    
    //MARK: -
    //MARK: Private - Utilities - Acquire
    
    private func acquire() {
        self.mbIsValid = self.url != nil
        
        if self.mbIsValid {
            self.mbIsValid = self.read()
        } else {
            NSLog(">> ERROR: Failed opening the file \"%@\"!", url!)
        }
    }
    
    //MARK: -
    //MARK: Private - Utilities - Constructors
    
    private convenience init(_ pathname: String) {
        self.init()
        
        let url = NSURL(fileURLWithPath: pathname)
        if url != nil {
            self.url = url
            
            self.acquire()
        } else {
            NSLog(">> ERROR: Invalid url!")
        }
        
    }
    
    //MARK: -
    //MARK: Public - Utilities
    
    public convenience init?(pathname: String) {
        self.init(pathname)
    }
    
    public convenience init?(name pName: String?, ext pExt:String?) {
        var pPathname: String? = nil
        
        if pName != nil {
            let pFileExt = pExt ?? "txt"
            
            let pBundle = NSBundle.mainBundle()
            
            pPathname = pBundle.pathForResource(pName!, ofType: pFileExt)
        }
        
        if pPathname == nil {
            self.init()
            return nil
        }
        self.init(pPathname!)
    }
    
    var isValid: Bool {
        return self.mpBuffer != nil ? self.mbIsValid : false
    }
    
    public var buffer: UnsafePointer<Void> {
        return self.mpBuffer != nil ? self.mpBuffer!.bytes : nil
    }
    
    public func get() -> Double? {
        let scanner = self.scanner
        var value: Double = 0
        if scanner.scanDouble(&value) {
            return value
        } else {
            return nil
        }
    }
    
    public var eof: Bool {
        return !self.isValid || self.scanner.atEnd
    }
}

infix operator >>> {
associativity left
precedence 90
assignment
}
func >>> (stream: CF.IFStream, inout variable: Double) -> CF.IFStream {
    if let value = stream.get() {
        variable = value
    }
    return stream
}
func >>> (stream: CF.IFStream, inout variable: Float) -> CF.IFStream {
    if let value = stream.get() {
        variable = value.f
    }
    return stream
}
func >>> (stream: CF.IFStream, inout variable: CGFloat) -> CF.IFStream {
    if let value = stream.get() {
        variable = value.g
    }
    return stream
}
