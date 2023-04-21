//
//  KeyboardTestViewController+Delegate.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/14.
//

import Foundation

extension KeyboardTestViewController: KeyboardRenderDelegate {

    func onSelected(keycaps: [Keycap], in render: KeyboardRender) {
//        self.reactor?.action.onNext(.hitKeycaps(keycaps))
    }
    
    func configureKeycapSelectedStyle(_ keycap: KeycapView) {
        keycap.setBackgroundColor(.systemGreen)
        keycap.setBorder(.systemGreen, width: 1, cornerRadius: 4)
    }
}
