//
//  KeyboardEditorViewController+Rx.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import Foundation
import RxSwift

extension Reactive where Base == KeyboardEditorViewController {
    var toast: Binder<ToastMessage> {
        Binder<ToastMessage>.init(self.base.view) { view, toast in
            view.makeToast(message: toast)
        }
    }
    
    var fileName: Binder<String> {
        Binder<String>.init(self.base.view) { view, fileName in
            view.window?.title = fileName
        }
    }
}

