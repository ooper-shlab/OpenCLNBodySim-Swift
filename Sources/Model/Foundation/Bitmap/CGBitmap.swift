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
    open class Bitmap {
        deinit {destruct()}
        
        fileprivate var mnWidth: size_t = 0
        fileprivate var mnHeight: size_t = 0
        fileprivate var mnRowBytes: size_t = 0
        fileprivate var mnBMPI: CGBitmapInfo = []
        fileprivate var mpContext: CGContext? = nil
    }
}


//MARK: -
//MARK: Private - Utilities

extension CG.Bitmap {
    private class func createFromImage(_ pImage: CGImage?) -> CGContext? {
        var pContext: CGContext? = nil
        
        if let pImage = pImage {
            let pColorSpace = CGColorSpaceCreateDeviceRGB()
            
            let nWidth    = pImage.width
            let nHeight   = pImage.height
            let nRowBytes = 4 * nWidth
            let nBMPI: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            
            pContext = CGContext(data: nil,
                                 width: nWidth,
                                 height: nHeight,
                                 bitsPerComponent: 8,
                                 bytesPerRow: nRowBytes,
                                 space: pColorSpace,
                                 bitmapInfo: nBMPI)
            
            pContext?.draw(pImage, in: CGRect(x: 0, y: 0, width: CGFloat(nWidth), height: CGFloat(nHeight)))
            
        }
        
        return pContext
    }
    
    private class func createImage(_ pName: String?, _ pExt: String?) -> CGImage? {
        var pImage: CGImage? = nil
        
        if pName != nil && pExt != nil {
            let pBundle = Bundle.main
            
            if let pURL = pBundle.url(forResource: pName!, withExtension: pExt!) {
                
                if let pSource = CGImageSourceCreateWithURL(pURL as CFURL, nil) {
                    
                    pImage = CGImageSourceCreateImageAtIndex(pSource, 0, nil)
                    
                }
                
            }
        }
        
        return pImage
    }
    
    private func createCopy(_ pContextSrc: CGContext?) -> CGContext? {
        var pContextDst: CGContext? = nil
        
        if pContextSrc != nil {
            if let pImage = pContextSrc?.makeImage() {
                
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
            
            mnWidth    = pImage.width
            mnHeight   = pImage.height
            mnRowBytes = 4 * mnWidth
            mnBMPI = CGBitmapInfo.byteOrder32Little.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue))
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
    
    fileprivate func destruct() {
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
    
    public func copy(_ pContext: CGContext?) -> Bool {
        var bSuccess = pContext != nil
        
        if bSuccess {
            let nWidth    = pContext?.width
            let nHeight   = pContext?.height
            let nRowBytes = pContext?.bytesPerRow
            let nBMPI     = pContext?.bitmapInfo
            
            bSuccess =
                (nWidth == mnWidth)
                &&  (nHeight == mnHeight)
                &&  (nRowBytes == mnRowBytes)
                &&  (nBMPI == mnBMPI)
            
            if bSuccess {
                let pDataSrc = pContext?.data
                
                let pDataDst = mpContext?.data
                
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
    
    public var data: UnsafeMutableRawPointer {
        var pData: UnsafeMutableRawPointer? = nil
        
        if mpContext != nil {
            pData = mpContext?.data
        }
        
        return pData!
    }
}
