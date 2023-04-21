//
//  NSSlider+Rx.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/13.
//

import Foundation
import RxSwift

// MARK: -
extension Reactive where Base == NSSlider {
    var currentValue: Observable<Double> {
        controlEvent.asObservable()
            .compactMap { [weak control = self.base] _ in control?.doubleValue }
    }
}
