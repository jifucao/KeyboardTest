//
//  Keycap.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import Foundation
import AppKit


/// 按键数据
struct Keycap: Codable {
    /// 铭文
    var legendLayouts: [LegendLayout]
    /// 按键的x坐标
    var x: CGFloat
    /// 按键的y坐标
    var y: CGFloat
    /// 按键的宽度
    var width: CGFloat = Keycap.Preferred.size.width
    /// 按键的高度
    var height: CGFloat = Keycap.Preferred.size.height
    /// 铭文字体大小
    var fontSize: CGFloat = 12
    /// 按键颜色
    var keyColor: Int = .blackColorHexValue
    /// 铭文颜色
    var legendColor: Int = .whiteColorHexValue
    /// 边框颜色
    var borderColor: Int = .blackColorHexValue
    /// 边框宽
    var borderWidth: CGFloat = 1.0
    /// 圆角
    var cornerRadius: CGFloat = 4.0
    /// 铭文偏移量
    var legendOffset: CGPoint = .init(x: 0, y: 0)
    /// 内边距
    var padding: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    /// 按键代码
    var keycode: UInt?
    /// id
    var id: String = UUID().uuidString

}

/// 按键大小
extension Keycap {
    struct Preferred {
        /// 默认大小
        static let size: CGSize = .init(width: 46, height: 46)
        /// 选择时的边框色
        static let selectedBorderColorValue: Int = .redColorHexValue
    }
}

// MARK: -
extension Keycap {
    var size: CGSize {
        get { .init(width: width, height: height) }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    var origin: NSPoint {
        get { .init(x: x, y: y) }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    var frame: CGRect {
        get { .init(x: x, y: y, width: width, height: height) }
        set {
            self.x = newValue.origin.x
            self.y = newValue.origin.y
            self.width = newValue.size.width
            self.height = newValue.size.height
        }
    }
}

// MARK: -
extension Keycap: Equatable {
    static func == (lhs: Keycap, rhs: Keycap) -> Bool {
        lhs.id == rhs.id && lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: -
extension Keycap: CustomStringConvertible {
    var description: String {
        legendLayouts.description
    }
}

extension NSPasteboard.PasteboardType {
    static let keycap = NSPasteboard.PasteboardType.init("keycap")
}

