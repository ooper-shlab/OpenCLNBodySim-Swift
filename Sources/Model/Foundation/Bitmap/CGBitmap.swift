//
//  CGBitmap.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
///*
//     File: CGBitmap.h
//     File: CGBitmap.mm
// Abstract:
// Utility methods acquiring CG bitmap contexts.
//
//  Version: 3.3
//
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
//
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
//
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Copyright (C) 2014 Apple Inc. All Rights Reserved.
//
// */

import Cocoa
import OpenGL

extension CG {
    public class Bitmap {
        deinit {destruct()}

        private var mnWidth: size_t = 0
        private var mnHeight: size_t = 0
        private var mnRowBytes: size_t = 0
        private var mnBMPI: CGBitmapInfo = nil
        private var mpContext: CGContext? = nil
    }
}
//
//
//MARK: -
//MARK: Private - Headers

//MARK: -
//MARK: Private - Utilities
//
extension CG.Bitmap {
    private class func createFromImage(pImage: CGImage?) -> CGContext? {
        var pContext: CGContext? = nil

        if pImage != nil {
            if let pColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB) {

                let nWidth    = CGImageGetWidth(pImage)
                let nHeight   = CGImageGetHeight(pImage)
                let nRowBytes = 4 * nWidth
                let nBMPI: CGBitmapInfo = .ByteOrder32Little | CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)

                pContext = CGBitmapContextCreate(nil,
                    nWidth,
                    nHeight,
                    8,
                    nRowBytes,
                    pColorSpace,
                    nBMPI)

                if pContext != nil {
                    CGContextDrawImage(pContext, CGRectMake(0, 0, CGFloat(nWidth), CGFloat(nHeight)), pImage)
                }

            }
        }

        return pContext
    }

    private class func createImage(pName: String?, _ pExt: String?) -> CGImage? {
        var pImage: CGImage? = nil

        if pName != nil && pExt != nil {
            let pBundle = NSBundle.mainBundle()

            if let pURL = pBundle.URLForResource(pName!, withExtension: pExt!) {

                if let pSource = CGImageSourceCreateWithURL(pURL, nil) {

                    pImage = CGImageSourceCreateImageAtIndex(pSource, 0, nil)

                }

            }
        }

        return pImage
    }

    private func createCopy(pContextSrc: CGContext?) -> CGContext? {
        var pContextDst: CGContext? = nil

        if pContextSrc != nil {
            if let pImage = CGBitmapContextCreateImage(pContextSrc) {

                pContextDst = CG.Bitmap.createFromImage(pImage)

            }
        }

        return pContextDst
    }

//MARK: -
//MARK: Public - Interfaces

    public convenience init(name pName: String?, ext pExt: String?) {
        self.init()

        if let pImage = CG.Bitmap.createImage(pName, pExt) {

            mnWidth    = CGImageGetWidth(pImage)
            mnHeight   = CGImageGetHeight(pImage)
            mnRowBytes = 4 * mnWidth
            mnBMPI = .ByteOrder32Little | CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
            mpContext  = CG.Bitmap.createFromImage(pImage)

        }
    }

//CG::Bitmap::Bitmap(const CG::Bitmap::Bitmap& rBitmap)
//{
//    mpContext = CGBitmapCreateCopy(rBitmap.mpContext);
//
//    if(mpContext != nullptr)
//    {
//        mnWidth    = rBitmap.mnWidth;
//        mnHeight   = rBitmap.mnHeight;
//        mnRowBytes = rBitmap.mnRowBytes;
//        mnBMPI     = rBitmap.mnBMPI;
//    } // if
//} // Copy Constructor

    public convenience init(bitmap pBitmap: CG.Bitmap?) {
        self.init()
        if pBitmap != nil {
            self.mpContext = self.createCopy(pBitmap!.mpContext)

            if self.mpContext != nil {
                mnWidth = pBitmap!.mnWidth
                mnHeight = pBitmap!.mnHeight
                mnRowBytes = pBitmap!.mnRowBytes
                mnBMPI = pBitmap!.mnBMPI
            }
        }
    }

    private func destruct() {
        //CGContextRelease(mpContext);
    }

//CG::Bitmap& CG::Bitmap::operator=(const CG::Bitmap& rBitmap)
//{
//    if(this != &rBitmap)
//    {
//        CGContextRef pContext = CGBitmapCreateCopy(rBitmap.mpContext);
//
//        if(pContext != nullptr)
//        {
//            CGContextRelease(mpContext);
//
//            mnWidth    = rBitmap.mnWidth;
//            mnHeight   = rBitmap.mnHeight;
//            mnRowBytes = rBitmap.mnRowBytes;
//            mnBMPI     = rBitmap.mnBMPI;
//            mpContext  = pContext;
//        } // if
//    } // if
//
//    return *this;
//} // Operator =

    public func copy(pContext: CGContext?) -> Bool {
        var bSuccess = pContext != nil

        if bSuccess {
            let nWidth    = CGBitmapContextGetWidth(pContext)
            let nHeight   = CGBitmapContextGetHeight(pContext)
            let nRowBytes = CGBitmapContextGetBytesPerRow(pContext)
            let nBMPI     = CGBitmapContextGetBitmapInfo(pContext)

            bSuccess =
                (nWidth == mnWidth)
            &&  (nHeight == mnHeight)
            &&  (nRowBytes == mnRowBytes)
            &&  (nBMPI == mnBMPI)

            if bSuccess {
                let pDataSrc = CGBitmapContextGetData(pContext)

                let pDataDst = CGBitmapContextGetData(mpContext)

                bSuccess = pDataSrc != nil && pDataDst != nil

                if bSuccess {
                    let nSize = mnRowBytes * mnHeight

                    memcpy(pDataDst, pDataSrc, nSize)
                }
            }
        }

        return bSuccess
    }

    public var width: size_t {
        return mnWidth
    }

    public var height: size_t {
        return mnHeight
    }

    public var rowBytes: size_t {
        return mnRowBytes
    }

    public var bitmapInfo: CGBitmapInfo {
        return mnBMPI
    }

    public var context: CGContext? {
        return mpContext
    }

    public var data: UnsafeMutablePointer<Void> {
        var pData: UnsafeMutablePointer<Void> = nil

        if mpContext != nil {
            pData = CGBitmapContextGetData(mpContext)
        }

        return pData
    }
}
