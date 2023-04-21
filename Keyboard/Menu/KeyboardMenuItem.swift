//
//  KeyboardMenuItem.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import Foundation

enum KeyboardMenuItem: String, MenuItemBuilder {
    
    case selectAll = "Select All"
    case deSelectAll = "Deselect All"
    case delete = "Delete"
    case new = "New Keybord"
    case add = "Add Keycap"
    case edit = "Edit"
    case copy = "Copy"
    case paste = "Paste"
    case cut = "Cut"
    case record = "Record Keycode"
    case rearrange = "ReArrange keycaps"
    static func makeItem(with title: String) -> KeyboardMenuItem? {
        KeyboardMenuItem.init(rawValue: title)
    }
    
    var title: String {
        rawValue
    }
}
