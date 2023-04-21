//
//  NSEdgeInsets+Ext.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/9.
//

import Foundation

extension NSEdgeInsets: Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        lhs.top == rhs.top && lhs.bottom == rhs.bottom && lhs.right == rhs.right && lhs.left == rhs.left
    }
}

// MARK: -
extension NSEdgeInsets: Codable {
    enum CodingKyes: String, CodingKey {
        case top, left, bottom, right
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKyes.self)
        self.top = CGFloat(try container.decode(Float.self, forKey: .top))
        self.left = CGFloat(try container.decode(Float.self, forKey: .left))
        self.right = CGFloat(try container.decode(Float.self, forKey: .right))
        self.bottom = CGFloat(try container.decode(Float.self, forKey: .bottom))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKyes.self)
        try container.encode(top, forKey: .top)
        try container.encode(left, forKey: .left)
        try container.encode(right, forKey: .right)
        try container.encode(bottom, forKey: .bottom)
    }
}
