//
//  NSColorWell+Rx.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/13.
//

import Foundation
import RxSwift

// MARK: -
extension Reactive where Base == NSColorWell {
    var currentValue: Observable<NSColor> {
        observe(\.color, options: [.new])
            .asObservable()
    }
}


