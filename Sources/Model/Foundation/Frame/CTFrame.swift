//
//  CTFrame.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
     File: CTFrame.h
     File: CTFrame.mm
 Abstract:
 Utility calss for generating frames from attributed strings.

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
import OpenGL

extension CT {
    public class Frame {
        
        private var mpFrame: CTFrame!
        private var m_Range: CFRange = CFRangeMake(0, 0)
        private var m_Bounds: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        //MARK: -
        //MARK: Private - Constants
        private final let kCTFrameDefaultMaxSz = CGSizeMake(CGFloat.max, CGFloat.max)
        
        //MARK: -
        //MARK: Private - Utilities - Constructor - Framesetter
        
        private func create(rText: String, _ rFont: String, _ nFontSize: CGFloat, _ nTextAlign: CTTextAlignment) -> CTFramesetter? {
            var pFrameSetter: CTFramesetter? = nil
            
            if let pText: CF.Text? = CF.Text(string: rText, fontName: rFont, fontSize: nFontSize, alignment: nTextAlign) {
                
                m_Range = CFRangeMake(0, CFAttributedStringGetLength(pText!))
                
                pFrameSetter = CTFramesetterCreateWithAttributedString(pText)
                
            }
            
            return pFrameSetter
        }
        
        //MARK: -
        //MARK: Private - Utilities - Constructors - Frames
        
        private func create(pFrameSetter: CTFramesetter) -> CTFrame? {
            var pFrame: CTFrame? = nil
            
            if let pPath: CGMutablePath = CGPathCreateMutable() {
                
                CGPathAddRect(pPath, nil, m_Bounds)
                
                pFrame = CTFramesetterCreateFrame(pFrameSetter,
                    m_Range,
                    pPath,
                    nil)
                
            }
            
            return pFrame
        }
        
        private func create(rOrigin: CGPoint, _ rSize: CGSize, _ pFrameSetter: CTFramesetter) -> CTFrame? {
            m_Bounds = CGRectMake(rOrigin.x,
                rOrigin.y,
                rSize.width,
                rSize.height)
            
            return create(pFrameSetter)
        }
        
        private func create(nWidth: GLsizei, _ nHeight: GLsizei, _ pFrameSetter: CTFramesetter) -> CTFrame? {
            m_Bounds = CGRectMake(0.0,
                0.0,
                CGFloat(nWidth),
                CGFloat(nHeight))
            
            return create(pFrameSetter)
        }
        
        private func create(rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment)
            -> CTFrame? {
                var pFrame: CTFrame? = nil
                
                if !rText.isEmpty {
                    if let pFrameSetter = create(rText, rFont, nFontSize, nTextAlign) {
                        
                        let size = CTFramesetterSuggestFrameSizeWithConstraints(pFrameSetter,
                            m_Range,
                            nil,
                            kCTFrameDefaultMaxSz,
                            nil)
                        
                        pFrame = create(rOrigin, size, pFrameSetter)
                        
                    }
                }
                
                return pFrame
        }
        
        private func create(rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment)
            -> CTFrame? {
                var pFrame: CTFrame? = nil
                
                if !rText.isEmpty {
                    if let pFrameSetter = create(rText, rFont, nFontSize, nTextAlign) {
                        
                        pFrame = create(nWidth, nHeight, pFrameSetter)
                        
                    }
                }
                
                return pFrame
        }
        
        //MARK: -
        //MARK: Private - Utilities - Defaults
        
        private func defaults() {
            mpFrame = nil
            m_Range = CFRangeMake(0, 0)
            m_Bounds = CGRectMake(0.0, 0.0, 0.0, 0.0)
        }
        
        //MARK: -
        //MARK: Public - Constructors
        
        /// Create a frame with bounds derived from the text size.
        public init(text rText: String,
            font rFont: String,
            fontSize nFontSize: CGFloat,
            origin rOrigin: CGPoint,
            textAlign nTextAlign: CTTextAlignment)
        {
            mpFrame = create(rText, rFont, nFontSize, rOrigin, nTextAlign)
        }
        
        /// Create a frame with bounds derived from the input width and height.
        public init(text rText: String,
            font rFont: String,
            fontSize nFontSize: CGFloat,
            width nWidth: GLsizei,
            height nHeight: GLsizei,
            textAlign nTextAlign: CTTextAlignment)
        {
            mpFrame = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        /// Create a frame with bounds derived from the text size using
        /// helvetica bold or helvetica bold oblique font.
        public init(text rText: String,
            fontSize nFontSize: CGFloat,
            isItalic bIsItalic: Bool,
            origin rOrigin: CGPoint,
            textAlign nTextAlign: CTTextAlignment)
        {
            let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
            
            mpFrame = create(rText, font, nFontSize, rOrigin, nTextAlign)
        }
        
        /// Create a frame with bounds derived from input width and height,
        /// and using helvetica bold or helvetica bold oblique font.
        public init(text rText: String,
            fontSize nFontSize: CGFloat,
            isItalic bIsItalic: Bool,
            width nWidth: GLsizei,
            height nHeight: GLsizei,
            textAlign nTextAlign: CTTextAlignment)
        {
            let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
            
            mpFrame = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        //MARK: -
        //MARK: Public - Destructor
        //
        //CT::Frame::~Frame()
        //{
        //    if(mpFrame != nullptr)
        //    {
        //        CFRelease(mpFrame);
        //
        //        mpFrame = nullptr;
        //    } // if
        //} // Destructor
        
        //MARK: -
        //MARK: Public - Utlities
        
        public func draw(pContext: CGContext?) {
            if pContext != nil {
                CTFrameDraw(mpFrame, pContext)
            }
        }
        
        //MARK: -
        //MARK: Public - Accessors
        
        public var bounds: CGRect {
            return m_Bounds
        }
        
        public var range: CFRange {
            return m_Range
        }
    }
}