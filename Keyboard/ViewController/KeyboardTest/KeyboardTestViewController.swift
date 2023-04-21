//
//  KeyboardTestViewController.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/14.
//

import Cocoa
import RxSwift

class KeyboardTestViewController: NSViewController {
    var disposeBag: DisposeBag = .init()
    
    @IBOutlet weak var keyboardRender: KeyboardRender! {
        didSet {
            keyboardRender.canEdit = false
            keyboardRender.showsBoundary = false
            keyboardRender.wantsLayer = true
            keyboardRender.layer?.cornerRadius = 8
            keyboardRender.delegate = self
        }
    }
    
    override var nibName: NSNib.Name? {
        "KeyboardTestViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    private var monitor: Any?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return nil }
            guard event.keyCode < 0xff else { return event }
            let modifierValue = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue
            kb_debg("keyDown: \(event.keyCode), modifier: \(modifierValue)")
            switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
            case [.capsLock]:
                kb_debg("capsLock key is pressed")
                if modifierValue == 0x10000 {
                    self.reactor?.action.onNext(.keydown(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
                } else {
                    self.reactor?.action.onNext(.keyup(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
                }
            default:
                if modifierValue == 0 || modifierValue == 0x10000  {
                    self.reactor?.action.onNext(.keyup(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
                } else {
                    self.reactor?.action.onNext(.keydown(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
                }
            }
            return event
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        true
    }
    
    override func keyDown(with event: NSEvent) {
        reactor?.action.onNext(.keydown(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
        kb_debg("keyDown: \(event.keyCode), modifier: \(event.modifierFlags.rawValue)")
    }
    
    override func keyUp(with event: NSEvent) {
        reactor?.action.onNext(.keyup(.init(rawValue: UInt(event.keyCode)), event.modifierFlags))
        kb_debg("keyUp: \(event.keyCode), modifier: \(event.modifierFlags.rawValue)")
    }
    
    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        kb_debg("~deinit ~\(Self.self)")
    }
}


import ReactorKit

extension KeyboardTestViewController: StoryboardView {
    func bind(reactor: KeyboardPresentation) {
        reactor.state
            .map(\.keyboard)
            .bind(to: keyboardRender.rx.keyboard)
            .disposed(by: disposeBag)
    }
}
