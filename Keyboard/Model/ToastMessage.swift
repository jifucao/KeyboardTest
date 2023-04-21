//
//  ToastMessage.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import Foundation

enum ToastMessage {
    case none
    case success
    case failure
    case plainText(String, ts: Date = Date())
}
