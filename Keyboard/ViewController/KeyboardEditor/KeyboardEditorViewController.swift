//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import AppKit
import Then
import SnapKit
import RxSwift


// MARK: -
final class KeyboardEditorViewController: NSViewController {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var keyboardView: KeyboardRender! {
        didSet {
            keyboardView.delegate = self
        }
    }
    
    @IBOutlet weak var saveButton: NSButton!

    @IBOutlet weak var loadButton: NSButton!

    @IBOutlet weak var editorLockButton: NSButton!

    @IBOutlet weak var keyboardTestButton: NSButton!

    /// Padding
    @IBOutlet weak var paddingTopLabel: NSTextField!
    @IBOutlet weak var paddingLeftLabel: NSTextField!
    @IBOutlet weak var paddingBottomLabel: NSTextField!
    @IBOutlet weak var paddingRightLabel: NSTextField!
    /// Size
    @IBOutlet weak var sizeWidthLabel: NSTextField!
    @IBOutlet weak var sizeHeightLabel: NSTextField!
    
    /// color
    @IBOutlet weak var keyboardBackgroundColorWell: NSColorWell!
    @IBOutlet weak var keycapBackgroundColorWell: NSColorWell!
    @IBOutlet weak var keycapLegendColorWell: NSColorWell!
    @IBOutlet weak var keycapBorderColorWell: NSColorWell!

    /// popup
    @IBOutlet weak var layoutFilesButton: NSPopUpButton!

    
    /// Menu
    private(set) lazy var menuControl = MenuControl<KeyboardMenuItem>(selectionObserver: { [weak self] item in
        guard let self = self else { return }
        guard let reactor = self.reactor else { return  }
        switch item {
        case .rearrange:
            reactor.action.onNext(.rearrangeSelectedKeys)
        case .deSelectAll:
            reactor.action.onNext(.selectKeycaps([]))
        case .selectAll:
            reactor.action.onNext(.selecteAllKeycaps)
        case .edit:
            reactor.action.onNext(.showSheet(.keycapEditor))
        case .delete:
            reactor.action.onNext(.deleteSelectedKeys)
        case .copy:
            reactor.action.onNext(.copy)
        case .paste:
            reactor.action.onNext(.paste)
        case .cut:
            reactor.action.onNext(.cut)
        case .new:
            reactor.action.onNext(.newKeyboard)
        case .add:
            reactor.action.onNext(.addKeycap)
        case .record:
            reactor.action.onNext(.showSheet(.keycodeRecorder))
        }
    }, validationMenuItem: { [weak reactor = self.reactor] item  in
        guard let reactor = reactor else { return false }
        switch item {
        case .add: return true
        case .deSelectAll: return true
        case .selectAll:  return true
        case .edit, .record: return reactor.currentState.keyboard.selectedKeycapIDs.count == 1
        case .copy, .rearrange, .delete:
            return !reactor.currentState.keyboard.selectedKeycapIDs.isEmpty
        case .paste:
            return true
        case .new:
            return true
        case .cut:
            return !reactor.currentState.keyboard.selectedKeycapIDs.isEmpty
        }
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = KeyboardEditor()
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: "layouts")
        let urls = paths.map(URL.init(fileURLWithPath:))
        reactor?.action.onNext(.setLayoutFiles(urls))
        
        if view.isDarkMode {
            reactor?.action.onNext(.load(.init(fileURLWithPath: paths.last!)))
        } else {
            reactor?.action.onNext(.load(.init(fileURLWithPath: paths.first!)))
        }
        
        layoutFilesButton.removeAllItems()
        layoutFilesButton.addItems(withTitles: urls.map(\.lastPathComponent))
        layoutFilesButton.itemArray.forEach { item in
            item.target = self
            item.action = #selector(onClickLayoutItem(_:))
        }
        
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            onClickPresentation(NSButton());
        }
#endif
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.title = reactor?.currentState.fileName ?? "-"
    }
    
    
    @IBAction func onClickPresentation(_ sender: Any) {
        guard var keyboard  = reactor?.currentState.keyboard else  { return }
        keyboard.selectedKeycapIDs = []
        let vc = KeyboardTestViewController()
        vc.reactor = .init(keyboard: keyboard)
        presentAsSheet(vc)
    }
    
    @IBAction
    func saveFile(_ sender: NSButton!) {
        let openPanel = NSSavePanel()
        openPanel.nameFieldStringValue = reactor?.currentState.fileName ?? "-"
        openPanel.beginSheetModal(for: NSApp.mainWindow!) {[weak self, weak openPanel] resp in
            guard resp == .OK else { return }
            guard let url = openPanel?.url else { return }
            self?.reactor?.action.onNext(.save(url))
        }
    }
    
    @IBAction
    func loadFile(_ sender: NSButton!) {
        let openPanel = NSOpenPanel()
        openPanel.beginSheetModal(for: NSApp.mainWindow!) {[weak self, weak openPanel] resp in
            guard resp == .OK else { return }
            guard let url = openPanel?.url else { return }
            self?.reactor?.action.onNext(.load(url))
        }
    }
    
    @IBAction
    func newLayoutFile(_ sender: NSButton!) {
        reactor?.action.onNext(.newKeyboard)
    }
    
    @IBAction
    func addKeycap(_ sender: NSButton) {
        reactor?.action.onNext(.addKeycap)
    }
    
    @objc
    private func onClickLayoutItem(_ sender: NSMenuItem) {
        let title = sender.title
        reactor?.action.onNext(.loadLayoutFile(title))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
    }
}

extension NSView {
    var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            if effectiveAppearance.name == .darkAqua {
                return true
            }
        }
        return false
    }
}

// MARK: -
extension KeyboardEditorViewController {
    @objc
    func copy(_ sender: Any) {
        reactor?.action.onNext(.copy)
    }
    
    @objc
    func paste(_ sender: Any) {
        reactor?.action.onNext(.paste)
    }
    
    @objc
    func cut(_ sender: Any) {
        reactor?.action.onNext(.cut)
    }
    
    @objc
    func delete(_ sender: Any) {
        reactor?.action.onNext(.deleteSelectedKeys)
    }
  
    override func selectAll(_ sender: Any?) {
        reactor?.action.onNext(.selecteAllKeycaps)
    }
    
    override func keyDown(with event: NSEvent) {
        let keycode = Keycode(rawValue: UInt(Int(event.keyCode)))
        switch keycode {
        case .Arrow.down:
            reactor?.action.onNext(.ajustPosition(offset: .init(x: 0, y: -1)))
        case .Arrow.up:
            reactor?.action.onNext(.ajustPosition(offset: .init(x: 0, y: 1)))
        case .Arrow.left:
            reactor?.action.onNext(.ajustPosition(offset: .init(x: -1, y: 0)))
        case .Arrow.right:
            reactor?.action.onNext(.ajustPosition(offset: .init(x: 1, y: 0)))
        default:
            super.keyDown(with: event)
        }
        kb_debg("keyDown: \(keycode), modifier: \(event.modifierFlags.rawValue)")
    }
    
    override func keyUp(with event: NSEvent) {
        let keycode = Keycode(rawValue: UInt(Int(event.keyCode)))
        kb_debg("keyUp: \(keycode), modifier: \(event.modifierFlags.rawValue)")
    }
}

// MARK: -
extension KeyboardEditorViewController {
    var keyboardSize: NSSize? {
        guard let width = Double(sizeWidthLabel.stringValue),
              let height = Double(sizeHeightLabel.stringValue) else { return nil }
        return .init(width: width, height: height)
    }
    
    var keyboardPadding: NSEdgeInsets? {
        guard let top = Double(paddingTopLabel.stringValue),
              let bottom = Double(paddingBottomLabel.stringValue),
              let left = Double(paddingLeftLabel.stringValue),
              let right = Double(paddingRightLabel.stringValue)
        else { return nil }
        return .init(top: top, left: left, bottom: bottom, right: right)
    }
}

// MARK: -
extension KeyboardEditorViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField == paddingTopLabel ||
            textField == paddingLeftLabel ||
            textField == paddingRightLabel ||
            textField == paddingBottomLabel {
            guard let keyboardPadding = keyboardPadding else { return }
            reactor?.action.onNext(.setKeyboardPadding(keyboardPadding))
            
        } else if textField == sizeWidthLabel || textField == sizeHeightLabel {
            guard let keyboardSize = keyboardSize else { return }
            reactor?.action.onNext(.setKeyboardSize(keyboardSize))
        }
    }
}
