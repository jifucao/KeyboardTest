//
//  LegendLayout.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import Foundation
import AppKit

// 铭文
enum Legend: Codable {
    /// 图片(path)
    case image(String)
    /// 文字
    case text(String)
    
    var text: String {
        switch self {
        case .image(let path): return path
        case .text(let str): return str
        }
    }
}

/// 铭文布局数据
enum LegendLayout: Codable {
    /// 第一行 左上
    case topLeft(Legend)
    /// 第一行  中上
    case topCenter(Legend)
    /// 第一行  右上
    case topRight(Legend)

    /// 第二行  中左
    case centerLeft(Legend)
    /// 第二行  中
    case center(Legend)
    /// 第二行  中右
    case centerRight(Legend)

    /// 第三行 下左
    case bottomLeft(Legend)
    /// 第三行 下中
    case bottomCenter(Legend)
    /// 第三行 下右边
    case bottomRight(Legend)
    
    
    var legend: Legend {
        switch self {
        case .topLeft(let legend): return legend
        case .topCenter(let legend): return legend
        case .topRight(let legend): return legend
        case .centerLeft(let legend): return legend
        case .center(let legend): return legend
        case .centerRight(let legend): return legend
        case .bottomLeft(let legend): return legend
        case .bottomCenter(let legend): return legend
        case .bottomRight(let legend): return legend
        }
    }
}

// MARK: -
extension LegendLayout: Equatable {
    static func == (lhs: LegendLayout, rhs: LegendLayout) -> Bool {
        lhs.description == rhs.description
    }
}

// MARK: -
extension LegendLayout: CustomStringConvertible {
    var description: String {
        switch self {
        case .topLeft(let legend):
            return "TopLeft/\(legend.text)"
        case .topCenter(let legend):
            return "TopCenter/\(legend.text)"
        case .topRight(let legend):
            return "TopRight/\(legend.text)"
        case .centerLeft(let legend):
            return "CenterLeft/\(legend.text)"
        case .center(let legend):
            return "Center/\(legend.text)"
        case .centerRight(let legend):
            return "CenterRight/\(legend.text)"
        case .bottomLeft(let legend):
            return "BottomLeft/\(legend.text)"
        case .bottomCenter(let legend):
            return "BottomCenter/\(legend.text)"
        case .bottomRight(let legend):
            return "BottomRight/\(legend.text)"
        }
    }
}

// MARK: -
extension LegendLayout {
    static func makeLegend(with layout: String, text: String) -> LegendLayout? {
        switch layout {
        case "TopLeft": return .topLeft(.text(text))
        case "TopCenter": return .topCenter(.text(text))
        case "TopRight": return .topRight(.text(text))
        case "CenterLeft": return .centerLeft(.text(text))
        case "Center": return .center(.text(text))
        case "CenterRight": return .centerRight(.text(text))
        case "BottomLeft": return .bottomLeft(.text(text))
        case "BottomCenter": return .bottomCenter(.text(text))
        case "BottomRight": return .bottomRight(.text(text))
        default:
            return nil
        }
    }
    
    func with(_ text: String) -> LegendLayout {
        switch self {
        case .topLeft(_):
            return .topLeft(.text(text))
        case .topCenter(_):
            return .topCenter(.text(text))
        case .topRight(_):
            return .topRight(.text(text))
        case .centerLeft(_):
            return .centerLeft(.text(text))
        case .center(_):
            return .center(.text(text))
        case .centerRight(_):
            return .centerRight(.text(text))
        case .bottomLeft(_):
            return .bottomLeft(.text(text))
        case .bottomCenter(_):
            return .bottomCenter(.text(text))
        case .bottomRight(_):
            return .bottomRight(.text(text))
        }
    }
}

extension LegendLayout {
    static let allTypeNames: [String] =
    ["TopLeft", "TopCenter", "TopRight",
     "CenterLeft", "Center", "CenterRight",
     "BottomLeft", "BottomCenter", "BottomRight"]
}
