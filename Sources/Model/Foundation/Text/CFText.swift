//
//  CFText.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/29.
//
//
/*
<codex>
<abstract>
Utility toolkit for managing mutable attributed strings.
</abstract>
</codex>
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
    private static let TextSizeCTTextAlignment = MemoryLayout<CTTextAlignment>.stride
    private static let TextSizeCGFloat = MemoryLayout<CGFloat>.stride
    
    // Array counts
    private static let TextAttribsCount = 3
    private static let TextStyleCount = 2
}

//MARK: -
//MARK: Private - utilities - Paragraph Styles
extension CF.Text {
    public typealias ColorComponent = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    
    // Create a paragraph style with line height and alignment
    private class func createParagraphStyle(_ nLineHeight: CGFloat,
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
    private class func createColor(_ pComponents: ColorComponent) -> CGColor {
        return CGColor(red: pComponents.r, green: pComponents.g, blue: pComponents.b, alpha: pComponents.a)
    }
    
    //MARK: -
    //MARK: Private - utilities - Attributes
    
    // Create an attributes dictionary with paragraph style, font, and colors
    private class func createAttributes(_ pStyle: NSParagraphStyle,
        _ pFont: NSFont,
        _ pColor: CGColor) -> [String: AnyObject]
    {
        
        // Create a dictionary of attributes for our string
        //let nsColor = NSColor(CGColor: pColor)!
        return [
            NSParagraphStyleAttributeName as String: pStyle,
            NSFontAttributeName: pFont,
            //NSForegroundColorAttributeName: nsColor,
            kCTForegroundColorAttributeName as String: pColor,
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
