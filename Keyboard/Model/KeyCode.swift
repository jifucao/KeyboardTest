//
//  KeyCode.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/11.
//

import Foundation

struct Keycode: RawRepresentable, Equatable {
    var rawValue: UInt
    
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    struct Arrow {
        static let left = Keycode(rawValue: 123)
        static let right = Keycode(rawValue: 124)
        static let down = Keycode(rawValue: 125)
        static let up = Keycode(rawValue: 126)
    }
}

extension Keycode: CustomStringConvertible {
    var description: String {
        "keycode: \(self.rawValue)"
    }
}
