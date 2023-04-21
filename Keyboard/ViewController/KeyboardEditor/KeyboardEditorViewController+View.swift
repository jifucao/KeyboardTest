//
//  KeyboardEditorViewController+View.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import Foundation
// MARK: -
import RxCocoa
import ReactorKit

extension KeyboardEditorViewController: StoryboardView {
    func bind(reactor: KeyboardEditor) {
        reactor.delegate = self
        /// State Bindings
        reactor.state
            .map(\.fileName)
            .distinctUntilChanged()
            .bind(to: rx.fileName)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.needsLayoutKeyboard)
            .filter { $0 }
            .withLatestFrom(reactor.state.map(\.keyboard))
            .observe(on: MainScheduler.instance)
            .bind(to: keyboardView.rx.keyboard)
            .disposed(by: disposeBag)

        
        reactor.state
            .map(\.lock)
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to:  keyboardView.rx.canEdit,
                  sizeWidthLabel.rx.isEnabled,
                  sizeHeightLabel.rx.isEnabled,
                  paddingTopLabel.rx.isEnabled,
                  paddingLeftLabel.rx.isEnabled,
                  paddingRightLabel.rx.isEnabled,
                  paddingBottomLabel.rx.isEnabled,
                  keycapBorderColorWell.rx.isEnabled,
                  keycapLegendColorWell.rx.isEnabled,
                  keycapBackgroundColorWell.rx.isEnabled,
                  keyboardBackgroundColorWell.rx.isEnabled
            )
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.lock)
            .distinctUntilChanged()
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .bind(to: editorLockButton.rx.state)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.canSave)
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.toast)
            .bind(to: rx.toast)
            .disposed(by: disposeBag)
        
        /// padding
        reactor.state
            .map(\.keyboard.margin.top)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingTopLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.margin.left)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.margin.right)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.margin.bottom)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingBottomLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// size
        reactor.state
            .map(\.keyboard.size.height)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: sizeHeightLabel.rx.text)
            .disposed(by: disposeBag)
       
        reactor.state
            .map(\.keyboard.size.width)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: sizeWidthLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// color
        reactor.state
            .map(\.keyboard.backgroundColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keyboardBackgroundColorWell.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.keycapLegendColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keycapLegendColorWell.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.keycapBorderColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keycapBorderColorWell.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keyboard.keycapBackgroundColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keycapBackgroundColorWell.rx.color)
            .disposed(by: disposeBag)
        
        /// Actoin Bindings
        editorLockButton.rx.tap.asObservable()
            .mapTo(Reactor.Action.toggleLockState)
            .merge(with: keyboardBackgroundColorWell.rx
                .currentValue
                .mapToHex()
                .distinctUntilChanged()
                .map { Reactor.Action.setKeyboardColor($0) })
            .merge(with: keycapLegendColorWell.rx
                .currentValue
                .mapToHex()
                .distinctUntilChanged()
                .map { Reactor.Action.setKeycapLegendColor($0) })
            .merge(with: keycapBackgroundColorWell.rx
                .currentValue
                .mapToHex()
                .distinctUntilChanged()
                .map { Reactor.Action.setKeycapColor($0) })
            .merge(with: keycapBorderColorWell.rx
                .currentValue
                .mapToHex()
                .distinctUntilChanged()
                .map { Reactor.Action.setKeycapBorderColor($0) })
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
