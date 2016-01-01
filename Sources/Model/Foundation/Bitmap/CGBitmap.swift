//
//  CGBitmap.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility methods acquiring CG bitmap contexts.
</abstract>
</codex>
 */

import Cocoa
import OpenGL

extension CG {
    public class Bitmap {
        deinit {destruct()}
        
        private var mnWidth: size_t = 0
        private var mnHeight: size_t = 0
        private var mnRowBytes: size_t = 0
        private var mnBMPI: CGBitmapInfo = []
        private var mpContext: CGContext? = nil
    }
}


//MARK: -
//MARK: Private - Utilities

extension CG.Bitmap {
    private class func createFromImage(pImage: CGImage?) -> CGContext? {
        var pContext: CGContext? = nil
        
        if pImage != nil {
            if let pColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB) {
                
                let nWidth    = CGImageGetWidth(pImage)
                let nHeight   = CGImageGetHeight(pImage)
                let nRowBytes = 4 * nWidth
                let nBMPI: UInt32 = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
                
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
    
    public convenience init(_ pName: String?,
        _ pExt: String?)
    {
        self.init()
        
        if let pImage = CG.Bitmap.createImage(pName, pExt) {
            
            mnWidth    = CGImageGetWidth(pImage)
            mnHeight   = CGImageGetHeight(pImage)
            mnRowBytes = 4 * mnWidth
            mnBMPI = CGBitmapInfo.ByteOrder32Little.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue))
            mpContext  = CG.Bitmap.createFromImage(pImage)
            
        }
    }
    
    //Bitmap::Bitmap(const Bitmap::Bitmap& rBitmap)
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
    
    public convenience init(_ pBitmap: CG.Bitmap?) {
        self.init()
        if let pBitmap = pBitmap {
            mpContext = createCopy(pBitmap.mpContext)
            
            if mpContext != nil {
                mnWidth = pBitmap.mnWidth
                mnHeight = pBitmap.mnHeight
                mnRowBytes = pBitmap.mnRowBytes
                mnBMPI = pBitmap.mnBMPI
            }
        }
    }
    
    private func destruct() {
        //CGContextRelease(mpContext);
    }
    
    //Bitmap& Bitmap::operator=(const Bitmap& rBitmap)
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
