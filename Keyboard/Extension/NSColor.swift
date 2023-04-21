//
//  NSColor.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/31.
//

import Foundation
import AppKit

extension NSColor {
    convenience
    init(rgb: Int, alpha: CGFloat = 1.0) {
        let r: CGFloat = CGFloat((rgb & 0xFF0000) >> 16) / CGFloat(0xFF)
        let g: CGFloat = CGFloat(((rgb & 0xFF00) >> 8)) / CGFloat(0xFF)
        let b: CGFloat = CGFloat((rgb & 0xFF)) / CGFloat(0xFF)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension Int {
    static let whiteColorHexValue = 0xFFFFFF
    static let blackColorHexValue = 0x000000
    static let grayColorHexValue = 0xEBEBEB
    static let redColorHexValue = 0xFF0000
    func mapToColor() -> NSColor {
        NSColor.init(rgb: self)
    }
}

extension NSColor {
    var hexValue: Int {
        var r :CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let red = Int(r * 255.0) << 16
        let green = Int(g * 255.0) << 8
        let blue = Int(b * 255.0)
        return (red + green + blue)
    }
}
