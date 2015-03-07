//
//  CFText.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
     File: CFText.h
     File: CFText.mm
 Abstract:
 Utility toolkit for managing mutable attributed strings.

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

// Mac OS X frameworks
import Cocoa

extension CF {
    // Text reference type definition representing a CF mutable attributed string
    // opaque data reference
    typealias Text = NSMutableAttributedString
}

//MARK: -
//MARK: Private - Constants
extension CF {
    
    // Size constants
    private static let TextSizeCTTextAlignment = strideof(CTTextAlignment)
    private static let TextSizeCGFloat = strideof(CGFloat)
    
    // Array counts
    private static let TextAttribsCount = 3
    private static let TextStyleCount = 2
}

//MARK: -
//MARK: Private - utilities - Paragraph Styles
extension CF.Text {
    public typealias ColorComponent = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    
    // Create a paragraph style with line height and alignment
    private class func createParagraphStyle(nLineHeight: CGFloat,
        _ nAlignment: CTTextAlignment) -> NSParagraphStyle
    {
        let paragraphStyle = NSMutableParagraphStyle()
        let alignment = NSTextAlignment(rawValue: UInt(nAlignment.rawValue))!
        paragraphStyle.alignment = alignment
        paragraphStyle.lineHeightMultiple = nLineHeight
        
        // Paragraph settings with alignment and style
        
        // Create a paragraph style
        return paragraphStyle
    }
    
    //MARK: -
    //MARK: Private - utilities - Colors
    
    // Return a color reference if valid, else get the clear color
    private class func createColor(pComponents: ColorComponent) -> CGColor {
        return CGColorCreateGenericRGB(pComponents.r, pComponents.g, pComponents.b, pComponents.a)
    }
    
    //MARK: -
    //MARK: Private - utilities - Attributes
    
    // Create an attributes dictionary with paragraph style, font, and colors
    private class func createAttributes(pStyle: NSParagraphStyle,
        _ pFont: NSFont,
        _ pColor: CGColor) -> [NSObject: AnyObject]
    {
        
        // Create a dictionary of attributes for our string
        //let nsColor = NSColor(CGColor: pColor)!
        return [
            NSParagraphStyleAttributeName: pStyle,
            NSFontAttributeName: pFont,
            //NSForegroundColorAttributeName: nsColor,
            kCTForegroundColorAttributeName: pColor,
        ]
    }
    
    //MARK: -
    //MARK: Private - utilities - Mutable Attributed Strings
    
    // Create an attributed string from a CF string, font, justification, and font size
    private convenience init(string pString: String,
        font pFont: NSFont,
        lineHeight nLineHeight: CGFloat,
        alignment nAlignment: CTTextAlignment,
        color pColor: CGColor)
    {
        
        // Create a paragraph style
        let pStyle = CF.Text.createParagraphStyle(nLineHeight, nAlignment)
        
        // Create a dictionary of attributes for our string
        let pAttributes = CF.Text.createAttributes(pStyle, pFont, pColor)
        
        // Creating a mutable attributed string
        self.init(string: pString, attributes: pAttributes)
        
    }
    
    //MARK: -
    //MARK: Public - Constructors
    
    // Create an attributed string from a stl string, font, justification, and font size
    public convenience init?(string rString: String,
        fontName rFontName: String,
        fontSize nFontSize: CGFloat,
        lineHeight nLineHeight: CGFloat,
        alignment nAlignment: CTTextAlignment,
        color pComponents: ColorComponent = (1.0, 1.0, 1.0, 1.0))
    {
        // Create a font reference
        if let pFont = NSFont(name: rFontName, size: nFontSize) {
            
            // Create a white color reference
            let pColor = CF.Text.createColor(pComponents)
            
            // Create a mutable attributed string
            self.init(string: rString,
                font: pFont,
                lineHeight: nLineHeight,
                alignment: nAlignment,
                color: pColor)
            return
            
        }
        
        self.init()
        return nil
    }
    
    // Create an attributed string from a stl string, font, justification, and font size
    public convenience init?(string rString: String,
        fontName rFontName: String,
        fontSize nFontSize: CGFloat,
        alignment nAlignment: CTTextAlignment)
    {
        self.init(string: rString, fontName: rFontName, fontSize: nFontSize, lineHeight: 1.0, alignment: nAlignment)
    }
}