//
//  CTFrame.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/28.
//
//
/*
<codex>
<abstract>
Utility calss for generating frames from attributed strings.
</abstract>
</codex>
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
        
        private func create(rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ nTextAlign: CTTextAlignment) -> CTFramesetter? {
                var pFrameSetter: CTFramesetter? = nil
                
                if let pText = CF.Text(string: rText, fontName: rFont, fontSize: nFontSize, alignment: nTextAlign) {
                    
                    m_Range = CFRangeMake(0, CFAttributedStringGetLength(pText))
                    
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
        
        private func create(rOrigin: CGPoint,
            _ rSize: CGSize,
            _ pFrameSetter: CTFramesetter) -> CTFrame?
        {
            m_Bounds = CGRectMake(rOrigin.x,
                rOrigin.y,
                rSize.width,
                rSize.height)
            
            return create(pFrameSetter)
        }
        
        private func create(nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ pFrameSetter: CTFramesetter) -> CTFrame?
        {
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
            -> CTFrame?
        {
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
            -> CTFrame?
        {
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
        public init(_ rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment)
        {
            mpFrame = create(rText, rFont, nFontSize, rOrigin, nTextAlign)
        }
        
        /// Create a frame with bounds derived from the input width and height.
        public init(_ rText: String,
            _ rFont: String,
            _ nFontSize: CGFloat,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment)
        {
            mpFrame = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign)
        }
        
        /// Create a frame with bounds derived from the text size using
        /// helvetica bold or helvetica bold oblique font.
        public init(_ rText: String,
            _ nFontSize: CGFloat,
            _ bIsItalic: Bool,
            _ rOrigin: CGPoint,
            _ nTextAlign: CTTextAlignment)
        {
            let font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold"
            
            mpFrame = create(rText, font, nFontSize, rOrigin, nTextAlign)
        }
        
        /// Create a frame with bounds derived from input width and height,
        /// and using helvetica bold or helvetica bold oblique font.
        public init(_ rText: String,
            _ nFontSize: CGFloat,
            _ bIsItalic: Bool,
            _ nWidth: GLsizei,
            _ nHeight: GLsizei,
            _ nTextAlign: CTTextAlignment)
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
                CTFrameDraw(mpFrame, pContext!)
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