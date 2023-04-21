//
//  NSPopupButton+Rx.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/13.
//

import Foundation
import RxSwift

extension Reactive where Base == NSPopUpButton {
    func titles(target: AnyObject, action: Selector) -> Binder<[String]> {
        .init(self.base) { [weak target] base, titles in
            base.removeAllItems()
            base.addItems(withTitles: titles)
            base.itemArray.forEach { item in
                item.action = action
                item.target = target
            }
        }
    }
   
    func selectedItem() -> Observable<String> {
        observe(\.titleOfSelectedItem, options: [.new])
            .compactMap { $0 }
            .asObservable()
    }
    
}
