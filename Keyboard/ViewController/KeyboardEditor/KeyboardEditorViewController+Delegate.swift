//
//  KeyboardEditorViewController+Delegate.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import AppKit

// MARK: -
extension KeyboardEditorViewController: KeyboardRenderDelegate {
    var primaryMenu: NSMenu? {
        let isAllSelected = reactor?.currentState.keyboard.isAllSelected ?? false
        return menuControl.makeMenu(for: [
            .title(.edit),
            .title(.record),
            .divider,
            .title(.rearrange),
            .divider,
            .title(.add),
            .title(.new),
            .divider,
            .title(.copy), .title(.paste),
            .title(.cut),
            .title(.delete),
            .divider,
            isAllSelected ? .title(.deSelectAll) : .title(.selectAll)
        ])
    }
    
    var contextMenu: NSMenu? {
        let isAllSelected = reactor?.currentState.keyboard.isAllSelected ?? false
        return menuControl.makeMenu(for: [
            .title(.add),
            .title(.new),
            .divider,
            .title(.copy), .title(.paste),
            .title(.cut),
            .title(.delete),
            .divider,
            isAllSelected ? .title(.deSelectAll) : .title(.selectAll)
        ])
    }
    
    func onSelected(keycaps: [Keycap], in render: KeyboardRender) {
        reactor?.action.onNext(.selectKeycaps(keycaps))
    }
    
    func onKeycapDoubleClicked(_ keycap: Keycap, in render: KeyboardRender) {
        reactor?.action.onNext(.showSheet(.keycapEditor))
    }
    
    func keycapPositionDidUpdate(_ keycap: Keycap, position: NSPoint, in render: KeyboardRender) {
        var keycap = keycap
        keycap.x = position.x
        keycap.y = position.y
        reactor?.action.onNext(.updateKeycap(keycap))
    }
    
    func configureKeycapSelectedStyle(_ keycap: KeycapView) {
        keycap.setBorder(.red, width: 2, cornerRadius: 4)
    }
}

// MARK: -
extension KeyboardEditorViewController: KeyboardEditDelegate {
    func showsKeycapEditor(for keycap: Keycap) {
        let vc = KeycapEditorViewController()
        vc.reactor = KeycapEditor(keycap: keycap) { [weak self] keycap in
            self?.reactor?.action.onNext(.updateKeycap(keycap))
        }
        self.presentAsSheet(vc)
    }
    
    func showsKeycodeRecorder(for keycap: Keycap) {
        let vc = RecordKeycodesViewController()
        vc.reactor = KeycodeRecorder(keycap: keycap) { [weak self] keycap in
            self?.reactor?.action.onNext(.updateKeycap(keycap))
        }
        self.presentAsSheet(vc)
    }
}
