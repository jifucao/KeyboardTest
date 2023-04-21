//
//  MenuControl.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//
//

import AppKit

protocol MenuItemBuilder {
    static func makeItem(with title: String) -> Self?
    var title: String { get }
}

// MARK: -
final class MenuControl<Item: MenuItemBuilder>: NSObject, NSMenuItemValidation {

    enum ItemType {
        case divider
        case title(Item)
        case subMenu(String)
    }

    @objc
    private func onMenuItemClick(_ sender: NSMenuItem) {
        guard let item: Item = .makeItem(with: sender.title) else { return }
        selectionObserver(item)
    }

    func makeMenuItems(for items: [ItemType]) -> [NSMenuItem] {
        items.map { item in
            switch item {
            case .divider:
                return NSMenuItem.separator()
            case .title(let name):
                let menuItem = NSMenuItem(title: name.title,
                                          action: #selector(onMenuItemClick(_:)),
                                          keyEquivalent: "")
                menuItem.target = self
                return menuItem
            case .subMenu(let title):
                let menuItem = NSMenuItem(title: title,
                                          action: nil,
                                          keyEquivalent: "")
                menuItem.target = self
                let subMenu = NSMenu()
                let subMenuItem = NSMenuItem(title: "-", action: nil, keyEquivalent: "")
                menuItem.submenu = subMenu
                subMenu.addItem(subMenuItem)
                return menuItem
            }
        }
    }

    func makeMenu(for items: [ItemType]) -> NSMenu {
        NSMenu().then { menu in
            items.forEach { item in
                switch item {
                case .divider: menu.addItem(NSMenuItem.separator())
                case .title(let name):
                    let menuItem = NSMenuItem(title: name.title,
                                              action: #selector(onMenuItemClick(_:)),
                                              keyEquivalent: "")
                    menu.addItem(menuItem)
                    menuItem.target = self
                case .subMenu(let title):
                    let menuItem = NSMenuItem(title: title,
                                              action: nil,
                                              keyEquivalent: "")
                    menu.addItem(menuItem)
                    menuItem.target = self
                    let subMenu = NSMenu()
                    let subMenuItem = NSMenuItem(title: "-", action: nil, keyEquivalent: "")
                    menuItem.submenu = subMenu
                    subMenu.addItem(subMenuItem)
                }
            }
        }
    }

    private var validationMenuItem: (Item) -> Bool
    private var selectionObserver: (Item) -> Void
    init(selectionObserver: @escaping (Item) -> Void, validationMenuItem: @escaping (Item) -> Bool) {
        self.selectionObserver = selectionObserver
        self.validationMenuItem = validationMenuItem
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
         guard let item: Item = Item.makeItem(with: menuItem.title) else { return false }
         return validationMenuItem(item)
     }
}
