//
//  KeycodeRecorder.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/14.
//

import Foundation
import ReactorKit

protocol KeycodeRecordDelegate: AnyObject {
    func dismiss(_ sender: Any?)
}

// MARK: -
final class KeycodeRecorder: Reactor {
    struct State {
        var keycap: Keycap
        var hint: String = "Please press the actual keycap to start record"
        var specifiedKeycodes: [String: NSEvent.ModifierFlags] = [
            "capslock"  : .capsLock,
            "shift": .shift,
            "control": .control,
            "option": .option,
            "command": .command,
            "numericPad": .numericPad,
            "help": .help,
            "function": .function,
            "deviceIndependentFlagsMask": .deviceIndependentFlagsMask
        ]
        
        var specifiedKeys: [String] {
           ["unspecified"] + Array(specifiedKeycodes.keys)
        }
    }
    
    enum Action {
        case setKeyPressedCode(UInt)
    }
    
    enum Mutation {
        case setKeyPressedCode(UInt)
    }
    
    var initialState: State
    private var keycapObserver: (Keycap) -> Void = { _ in }
    
    weak var delegate: KeycodeRecordDelegate?
    
    init(keycap: Keycap, keycapObserver: @escaping (Keycap) -> Void) {
        self.initialState = .init(keycap: keycap)
        self.keycapObserver = keycapObserver
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setKeyPressedCode(let code):
            state.keycap.keycode = code
            keycapObserver(state.keycap)
            delegate?.dismiss(nil)
        }
        return state
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setKeyPressedCode(let code):
            return .just(.setKeyPressedCode(code))
        }
    }
    
}
