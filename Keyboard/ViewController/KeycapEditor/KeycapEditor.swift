//
//  KeycapEditor.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/4.
//

import Foundation
import ReactorKit
import Then

extension Keycap: Then {}

final class KeycapEditor: Reactor {
    enum Padding {
        case top, left, bottom, right
    }
    struct State {
        var selectedIndex: Int?
        var selectedLegendLayout: LegendLayout?
        var keycap: Keycap
    }
    
    enum Action {
        case reset
        case mergePadding(Padding, CGFloat)
        case setKeycapColor(NSColor)
        case setLegendColor(NSColor)
        case setKeycapBorderColor(NSColor)
        
        ///  fraction
        case setKeycapWidthFraction(CGFloat)
        case setKeycapHeightFraction(CGFloat)
        
        /// font size
        case setKeycapFontSize(CGFloat)
        /// border width
        case setKeycapBorderWidth(CGFloat)
        /// offset
        case setKeycapLegendOffsizeX(CGFloat)
        case setKeycapLegendOffsizeY(CGFloat)

        case setKeycapPositionX(CGFloat)
        case setKeycapPositionY(CGFloat)

        case setLegendLayouts([LegendLayout])
        
        case load(keycap: Keycap)
        case addLegendcapLayout
        case removeSelectedLegendLayout
        case selectLegendLayoutIndex(Int?)
    }
    
    enum Mutation {
        case setLegendLayouts([LegendLayout])
        case setSelectedLegendLayout(LegendLayout?, index: Int?)
        case setKeycap(Keycap)
    }
   
    var initialState: State
   
    var scheduler: Scheduler = MainScheduler.instance
    
    private var keycapObserver: (Keycap) -> Void = { _ in }
    private var rawKeycap: Keycap
    
    init(keycap: Keycap,
         keycapObserver: @escaping (Keycap) -> Void) {
        self.rawKeycap = keycap
        self.initialState = .init(keycap: keycap)
        self.keycapObserver = keycapObserver
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reset:
            return .just(.setKeycap(rawKeycap))
        case .mergePadding(let padding, let value):
            var keycap = currentState.keycap
            switch padding {
            case .top:keycap.padding.top = value
            case .right: keycap.padding.right = value
            case .left: keycap.padding.left = value
            case .bottom: keycap.padding.bottom = value
            }
            return .just(.setKeycap(keycap))
        case .load(let keycap):
            return .just(.setKeycap(keycap))
        case .setKeycapLegendOffsizeX(let offsetX):
            return .just(.setKeycap(currentState.keycap.with {
                $0.legendOffset = .init(x: offsetX, y: $0.legendOffset.y)
            }))
        case .setKeycapLegendOffsizeY(let offsetY):
            return .just(.setKeycap(currentState.keycap.with {
                $0.legendOffset = .init(x: $0.legendOffset.x, y: offsetY)
            }))
        case .setKeycapBorderWidth(let value):
            return .just(.setKeycap(currentState.keycap.with { $0.borderWidth = value }))
        case .setKeycapFontSize(let size):
            return .just(.setKeycap(currentState.keycap.with { $0.fontSize = size }))
        case .setLegendLayouts(let layouts):
            return .just(.setKeycap(currentState.keycap.with { $0.legendLayouts = layouts }))
        case .setKeycapColor(let color):
            return .just(.setKeycap(currentState.keycap.with { $0.keyColor = color.hexValue }))
        case .setLegendColor(let color):
            return .just(.setKeycap(currentState.keycap.with { $0.legendColor = color.hexValue }))
        case .setKeycapWidthFraction(let fraction):
            return .just(.setKeycap(currentState.keycap.with { $0.width = Keycap.Preferred.size.width * fraction }))
        case .setKeycapHeightFraction(let fraction):
            return .just(.setKeycap(currentState.keycap.with { $0.height = Keycap.Preferred.size.height * fraction }))
        case .setKeycapPositionX(let value):
            return .just(.setKeycap(currentState.keycap.with { $0.x += value }))
        case .setKeycapPositionY(let value):
            return .just(.setKeycap(currentState.keycap.with { $0.y += value }))
        case .setKeycapBorderColor(let color):
            return .just(.setKeycap(currentState.keycap.with { $0.borderColor = color.hexValue }))
        case .addLegendcapLayout:
            var legendLayouts = currentState.keycap.legendLayouts
            legendLayouts.append(LegendLayout.center(.text("A")))
            return .just(.setLegendLayouts(legendLayouts))
        case .removeSelectedLegendLayout:
            guard let selectedLayout = currentState.selectedLegendLayout else { return .empty()}
            var legendLayouts = currentState.keycap.legendLayouts
            legendLayouts.removeAll(where: { $0 == selectedLayout })
            return .just(.setLegendLayouts(legendLayouts))
        case .selectLegendLayoutIndex(let index):
            guard let index = index else { return .just(.setSelectedLegendLayout(nil, index: nil))}
            guard currentState.selectedIndex != index else { return .empty() }
            return .just(.setSelectedLegendLayout(currentState.keycap.legendLayouts[index], index: index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setSelectedLegendLayout(let layout, let idx):
            state.selectedLegendLayout = layout
            state.selectedIndex = idx
        case .setKeycap(let keycap):
            keycapObserver(keycap)
            state.keycap = keycap
        case .setLegendLayouts(let layouts):
            state.keycap.legendLayouts = layouts
            keycapObserver(state.keycap)
        }
        return state
    }
}
