//
//  KeyboardPresentation.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/14.
//

import Foundation
import ReactorKit

final class KeyboardPresentation: Reactor {
    struct State {
        var keyboard: Keyboard
    }
    
    enum Action {
        case hitKeycaps([Keycap])
        case keydown(Keycode, NSEvent.ModifierFlags)
        case keyup(Keycode, NSEvent.ModifierFlags)
    }
    
    enum Mutation {
        case setSelectedKeycapIds([String])
    }
    
    var initialState: State
    
    init(keyboard: Keyboard) {
        initialState = .init(keyboard: keyboard)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .keyup:
            return .just(.setSelectedKeycapIds([]))
        case .keydown(let keycode, let modifier):
            guard modifier.rawValue > 0,
                  let keycap = currentState.keyboard.keycaps.first(where: { $0.keycode == keycode.rawValue}) else {
                return .empty()
            }
            return .just(.setSelectedKeycapIds([keycap.id]))
        case .hitKeycaps(let keycaps):
            return .just(.setSelectedKeycapIds(keycaps.map(\.id)))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setSelectedKeycapIds(let ids):
            state.keyboard.selectedKeycapIDs = ids
        }
        return state
    }
}
