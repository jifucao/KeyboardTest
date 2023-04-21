//
//  AppDelegate.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/18.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private lazy var window: NSWindow = {
        let win = NSWindow(contentViewController: MainViewController())
        win.contentMinSize = .init(width: 900, height: 680)
        win.setContentSize(.init(width: 900, height: 680))
        return win
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.orderFront(nil)
        window.center()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

