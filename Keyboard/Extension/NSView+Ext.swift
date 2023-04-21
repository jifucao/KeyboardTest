//
//  NSView+Ext.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import AppKit

extension NSView {
    func setBackgroundColor(_ color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
    
    func setBorder(_ color: NSColor, width: CGFloat = 0, cornerRadius: CGFloat = 0) {
        wantsLayer = true
        layer?.cornerRadius = cornerRadius
        layer?.borderWidth = width
        layer?.borderColor = color.cgColor
    }
}

