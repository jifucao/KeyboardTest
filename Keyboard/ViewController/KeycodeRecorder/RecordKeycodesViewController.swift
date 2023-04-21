//
//  RecordKeycodesViewController.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/13.
//

import Foundation
import AppKit
import RxSwift

final class RecordKeycodesViewController: NSViewController, KeycodeRecordDelegate {
    var disposeBag: DisposeBag = .init()
    
    @IBOutlet weak var hintsLabel: NSTextField!
    @IBOutlet weak var keycapPreview: KeycapPreview!
   
    override var nibName: NSNib.Name? {
        "RecordKeycodesViewController"
    }
    
    private var didRecord: Bool = false
    private var monitor: Any?
    override func viewDidLoad() {
        super.viewDidLoad()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {[weak self] event in
            guard let self = self else { return nil }
            guard !self.didRecord else { return nil }
            self.reactor?.action.onNext(.setKeyPressedCode(UInt(event.keyCode)))
            self.didRecord = true
            return event
        }
    }
   
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
    }
    
    override func becomeFirstResponder() -> Bool {
        true
    }
    
    override func keyDown(with event: NSEvent) {
        reactor?.action.onNext(.setKeyPressedCode(UInt(event.keyCode)))
        kb_debg("keyDown: \(event.keyCode), modifier: \(event.modifierFlags.rawValue)")
    }
    
    override func keyUp(with event: NSEvent) {
        let keycode = Keycode(rawValue: UInt(event.keyCode))
        kb_debg("keyUp: \(keycode), modifier: \(event.modifierFlags.rawValue)")
    }
    
    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor( monitor )
        }
        kb_debg("~deinit ~\(Self.self)")
    }
}

// MARK: -
import ReactorKit
extension RecordKeycodesViewController: StoryboardView {
    
    func bind(reactor: KeycodeRecorder) {
        reactor.delegate = self
        reactor.state
            .map(\.keycap)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keycap in
                guard let self = self else { return }
                self.keycapPreview.preview(keycap: keycap)
            })
            .disposed(by: disposeBag)

    }
}
