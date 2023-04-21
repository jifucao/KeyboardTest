//
//  Keyboard.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import Foundation

struct Keyboard: Codable  {
    /// 选中的按键
    var selectedKeycapIDs: [String] = []
    /// 所有的按键
    var keycaps: [Keycap] = []
    /// 键盘大小
    var size: CGSize = .init(width: 860, height: 380)
    /// 键盘 背景色
    var backgroundColor: Int = .grayColorHexValue
    /// 键帽 背景色
    var keycapBackgroundColor: Int = .blackColorHexValue
    /// 键帽 边框色
    var keycapBorderColor: Int = .blackColorHexValue
    /// 键帽 上的铭文色
    var keycapLegendColor: Int = .whiteColorHexValue
    /// 每个按键固定的间隔
    var keycapEdgeInset: NSEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
    /// 键盘外边距
    var margin: NSEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
}

// MARK: -
extension Keyboard {
    /// 已选择的按键
    var selectedKeycaps: [Keycap] {
        get {
            keycaps.filter { self.selectedKeycapIDs.contains($0.id) }
        }
        
        mutating set {
            self.selectedKeycapIDs = newValue.map(\.id)
        }
       
    }
    /// 是否全部选中
    var isAllSelected: Bool {
        !selectedKeycapIDs.isEmpty && selectedKeycapIDs.count == keycaps.count
    }
    
    /// 新建一个按键
    func makeKeycap(title: String) -> Keycap? {
        guard let preferredPosition = preferredLayoutPosition(for: Keycap.Preferred.size) else { return nil}
        return .init(legendLayouts: [.center(.text(title))],
                     x: preferredPosition.x,
                     y: preferredPosition.y,
                     keyColor: keycapBackgroundColor,
                     legendColor: keycapLegendColor,
                     borderColor: keycapBorderColor
        )
    }
    
    /// 推荐按键位置
    func preferredLayoutPosition(for keycapSize: CGSize) -> CGPoint? {
        var position: CGPoint = .zero
        if let lastKeycap = keycaps.last {
            var xpos = lastKeycap.x + lastKeycap.width + keycapEdgeInset.right + keycapEdgeInset.left
            var ypos = lastKeycap.y
            if (xpos + keycapSize.width + keycapEdgeInset.right + margin.right) > size.width {
                // 换行
                xpos = keycapEdgeInset.left + margin.left
                ypos = lastKeycap.y - keycapEdgeInset.bottom - keycapEdgeInset.top - keycapSize.height
                // 如果按键已填满
                guard ypos >= margin.bottom else {  return nil }
            }
            position = .init(x: xpos, y: ypos)
        } else {
            position = .init(x:  keycapEdgeInset.left + margin.left,
                             y: size.height - keycapEdgeInset.top - keycapSize.height - margin.top)
        }
        return position
    }
    
    /// 重新排序按键
    mutating func rearrangeKeycaps(with keycapIds: [String]) {
        let selectedKeycaps = keycaps.filter({keycapIds.contains($0.id)})
        keycaps.removeAll(where: { keycapIds.contains($0.id)})
        selectedKeycaps.forEach { keycap in
            if let position = self.preferredLayoutPosition(for: keycap.size) {
                self.keycaps.append(keycap.with { $0.x = position.x ;$0.y = position.y})
            }
        }
    }
    
    /// 重新布局 但是 不排序
    mutating func relayoutKeycaps() {
        let boundary = CGRect.init(x: margin.left,
                                   y: margin.bottom,
                                   width: size.width - margin.left - margin.right,
                                   height: size.height - margin.bottom - margin.top)
        keycaps = keycaps.map { keycap -> Keycap in
            let keycapFrame = CGRect.init(x: keycap.x, y: keycap.y, width: keycap.width, height: keycap.height)
            guard !boundary.contains(keycapFrame) else { return keycap }
            let x = min((boundary.origin.x + boundary.size.width - keycapFrame.size.width), max(margin.left, keycap.x))
            let y = min((size.height - keycap.height - margin.top), max(margin.bottom, keycap.y))
            return keycap.with { $0.x = x; $0.y = y }
        }
    }
    
    /// 复制按键
    mutating func pasteKeycaps(_ keycaps: [Keycap]) {
        keycaps.forEach { key in
            guard let p = self.preferredLayoutPosition(for: key.size) else { return }
            var keycap = key
            keycap.id = UUID().uuidString
            keycap.origin = p
            self.keycaps.append(keycap)
        }
    }
    
}

