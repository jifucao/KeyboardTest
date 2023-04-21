//
//  KeyboardRender+Rx.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/14.
//

import Foundation
import RxSwift

extension Reactive where Base == KeyboardRender {
    var keyboard: Binder<Keyboard> {
        Binder<Keyboard>.init(self.base) { base, kb in
            base.layout(with: kb)
        }
    }
}
