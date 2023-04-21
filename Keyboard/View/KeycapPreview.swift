//
//  KeycapPreview.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/7.
//

import Cocoa
import SnapKit

class KeycapPreview: NSView {
    private var key: KeycapView?
    private func setupKeycapView(keycap: Keycap) {
        let k = KeycapView(keycap: keycap)
        addSubview(k)
        key = k
    }
    
    func preview(keycap: Keycap?) {
        key?.removeFromSuperview()
        key = nil
        guard var keycap = keycap else { return }
        setupKeycapView(keycap: keycap)
        /// reset frame origin
        keycap.x = (bounds.size.width - keycap.width)/2
        keycap.y = (bounds.size.height - keycap.height)/2
        key?.keycap = keycap
        
        setBackgroundColor(.lightGray)
    }
}
