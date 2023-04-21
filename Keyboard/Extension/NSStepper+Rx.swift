//
//  NSStepper+Rx.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/13.
//

import Foundation
import RxSwift

// MARK: -
extension Reactive where Base == NSStepper {
    var currentValue: Observable<CGFloat> {
        controlEvent.asObservable()
            .compactMap { [weak control = self.base] _ in control?.floatValue }
            .map { CGFloat($0)}
    }
}

