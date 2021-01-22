//
//  NSTextField+PlaceHolder.swift
//  quannu
//
//  Created by davide on 22/01/21.
//

import Cocoa

extension NSTextField {
    func setPlaceHolderTextColor(color: NSColor) {
        let text = placeholderString ?? placeholderAttributedString?.string ?? ""
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font!
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        
        let attributedString = NSMutableAttributedString(string: text, attributes: placeholderAttributes)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0,length: attributedString.length))
        
        placeholderAttributedString =  attributedString
    }
}

