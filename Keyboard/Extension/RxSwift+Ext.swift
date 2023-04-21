//
//  RxSwift+Ext.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/31.
//

import Foundation
import RxSwift

extension ObservableType {
    func mapTo<Result>(_ value: Result) -> Observable<Result> {
        map { _ in value }
    }
}

extension Observable {
    func merge(with other: Observable<Element>) -> Observable<Element> {
        Observable.merge(self, other)
    }
    
    func merge(with others: [Observable<Element>]) -> Observable<Element> {
        return Observable.merge([self] + others)
    }
}

extension ObservableType where Element == Int {
    func mapToColor() -> Observable<NSColor> {
        self.map { $0.mapToColor()}
    }
}

extension ObservableType where Element == NSColor {
    func mapToHex() -> Observable<Int> {
        self.map { $0.hexValue}
    }
}

extension ObservableType where Element == CGFloat {
    func mapToString() -> Observable<String> {
        map {
           "\($0)"
        }
    }
}
