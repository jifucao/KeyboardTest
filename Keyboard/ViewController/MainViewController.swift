//
//  MainViewController.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import Cocoa
import Then
import SnapKit

final class MainViewController: NSViewController {
    override func loadView() {
        view = NSView().then {
            $0.setBackgroundColor(.clear)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let keyboardViewController = KeyboardEditorViewController()
        addChild(keyboardViewController)
        view.addSubview(keyboardViewController.view)
        keyboardViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
