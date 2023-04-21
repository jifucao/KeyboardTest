//
//  KeyboardEditor.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/31.
//

import Foundation
import RxSwift
import ReactorKit

protocol KeyboardEditDelegate: AnyObject {
    func showsKeycapEditor(for keycap: Keycap)
    func showsKeycodeRecorder(for keycap: Keycap)
}

// MARK: -
final class KeyboardEditor: Reactor {
    enum SheetKind {
        case keycapEditor
        case keycodeRecorder
    }
    
    struct State {
        var layoutFiles: [URL] = []
        var toast: ToastMessage = .none
        ///  键盘配置信息
        var keyboard: Keyboard = Keyboard()
        /// 文件名
        var fileName: String = ""
        /// 是否需要重新键盘布局
        var needsLayoutKeyboard: Bool = true
        /// 是否可以编辑
        var lock: Bool = false
        /// 是否能删除当前选择按键
        var canEdit: Bool  {
            !lock && !keyboard.selectedKeycapIDs.isEmpty
        }
        /// 是否能保存
        var canSave: Bool  {
            !keyboard.keycaps.isEmpty
        }
    }
    
    enum Action {
        case showSheet(SheetKind)
        /// 复制
        case copy
        /// 粘贴
        case paste
        /// 剪切
        case cut
        /// 键盘背景色
        case setKeyboardColor(Int)
        case setKeycapColor(Int)
        case setKeycapBorderColor(Int)
        case setKeycapLegendColor(Int)
        /// 键盘边距
        case setKeyboardPadding(NSEdgeInsets)
        /// 键盘大小
        case setKeyboardSize(NSSize)
        
        /// 编辑锁的状态反转
        case toggleLockState
        /// 开始新的键盘编辑
        case newKeyboard
        /// 添加一个按键
        case addKeycap
        /// 删除当前选择的按钮
        case deleteSelectedKeys
        /// 重新排列选中的按键
        case rearrangeSelectedKeys
        /// 按键选择
        case selectKeycaps([Keycap])
        /// 全选
        case selecteAllKeycaps
        /// 更新按钮
        case updateKeycap(Keycap)
        /// 保存文件
        case save(URL)
        /// 加载文件
        case load(URL)
        /// 加载多文件
        case setLayoutFiles([URL])
        /// 加载文件名
        case loadLayoutFile(String)
        /// 调整位置
        case ajustPosition(offset : CGPoint)
    }
    
    enum Mutation {
        case setLayoutsFiles([URL])
        /// 更新文件名
        case setFileName(String)
        /// 提示文案
        case setToast(ToastMessage)
        /// 是否允许编辑
        case setLock(Bool)
        /// 更新键盘
        case setKeyboard(Keyboard)
        /// 更新按键
        case updateKeycaps([Keycap])
        /// 设置选中的按键
        case setSelectedKeycaps([Keycap])
        /// 新增按键
        case addKeycaps([Keycap])
        /// 删除一个按键
        case deleteKeycapIds([String])
        /// 批量接口
        case mutations([Mutation])
    }
    
    weak var delegate: KeyboardEditDelegate?
    
    var initialState: State = .init()
    var scheduler: Scheduler = MainScheduler.instance
    
    private func updateColor(_ color: Int,
                             keybaordPath: WritableKeyPath<Keyboard, Int>,
                             keycapPath: WritableKeyPath<Keycap, Int>) -> Observable<Mutation> {
        var keyboard = currentState.keyboard
        if keyboard.selectedKeycapIDs.isEmpty {
            return .empty()
        } else {
            keyboard[keyPath: keybaordPath] = color
            let selectedId = keyboard.selectedKeycapIDs
            let keycaps = keyboard.keycaps.map { key -> Keycap in
                guard selectedId.contains(key.id) else { return key }
                return key.with {
                    $0[keyPath: keycapPath] = color
                }
            }
            keyboard.keycaps = keycaps
            return .just(.setKeyboard(keyboard))
        }
    }
    
    private func loadFile(from url: URL) -> Observable<Mutation> {
        do {
            var keyboard = try Keyboard.load(from: url)
            keyboard.selectedKeycapIDs = []
            let fileName = url.lastPathComponent
            return .just(.mutations([
                .setFileName(fileName),
                .setLock(true),
                .setKeyboard(keyboard)
            ]))
        } catch let err {
            kb_debg("err: \(err)")
            return .just(.setToast(.plainText("Load data failure")))
        }
    }
    
    private func ensureKeyboardUnlock(stopOnSelectedKeycapsEmpty: Bool = false , action: () -> Observable<Mutation>) -> Observable<Mutation> {
        guard !currentState.lock else { return .just(.setToast(.plainText("Unlock keyboard first!"))) }
        if stopOnSelectedKeycapsEmpty, currentState.keyboard.keycaps.isEmpty {
            return .empty()
        }
        return action()
    }
    
    private func showsSheet(for kind: SheetKind) -> Observable<Mutation> {
        ensureKeyboardUnlock {
            guard let keycap = currentState.keyboard.selectedKeycaps.first else { return .empty() }
            switch kind {
            case .keycapEditor:
                delegate?.showsKeycapEditor(for: keycap)
            case .keycodeRecorder:
                delegate?.showsKeycodeRecorder(for: keycap)
            }
            return .empty()
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .showSheet(let kind):
            return showsSheet(for: kind)
        case .newKeyboard:
            return .just(.mutations([.setKeyboard(.init()),
                                     .setFileName("untitled-layout.json"),
                                     .setLock(false)]))
        case .loadLayoutFile(let name):
            guard let url = currentState.layoutFiles.first(where: {$0.lastPathComponent == name}) else {
                return .empty()
            }
            return loadFile(from: url)
        case .setLayoutFiles(let urls):
            return .just(.setLayoutsFiles(urls))
        case .ajustPosition(let offset):
            return ensureKeyboardUnlock(stopOnSelectedKeycapsEmpty: true) {
                let adjustKeycaps = currentState.keyboard.selectedKeycaps.map {  key in
                    return key.with {
                        $0.x += offset.x
                        $0.y += offset.y
                    }
                }
                return .just(.updateKeycaps(adjustKeycaps))
            }
        case .rearrangeSelectedKeys:
            var keyboard = currentState.keyboard
            let selectedIds = keyboard.selectedKeycapIDs
            keyboard.rearrangeKeycaps(with: selectedIds)
            return .just(.setKeyboard(keyboard))
        case .addKeycap:
            return ensureKeyboardUnlock {
                guard let key = currentState.keyboard.makeKeycap(title: "A") else {
                    return .just(.setToast(.plainText("No More Space")))
                }
                return .just(.addKeycaps([key]))
            }
        case .deleteSelectedKeys:
            return ensureKeyboardUnlock(stopOnSelectedKeycapsEmpty: true)  {
                let selectedKeyIds = currentState.keyboard.selectedKeycapIDs
                return .just(.deleteKeycapIds(selectedKeyIds))
            }
        case .selectKeycaps(let keycaps):
            return .just(.setSelectedKeycaps(keycaps))
        case .selecteAllKeycaps:
            return .just(.setSelectedKeycaps(currentState.keyboard.keycaps))
        case .updateKeycap(let newKey):
            return .just(.updateKeycaps([newKey]))
        case .save(let url):
            do {
                try currentState.keyboard.write(to: url)
                let fileName = url.lastPathComponent
                return .just(.mutations([
                    .setFileName(fileName),
                    .setToast(.plainText("Save Success"))
                ]))
            } catch let err {
                kb_debg("err: \(err)")
                return .just(.setToast(.plainText("Save failure")))
            }
        case .load(let url):
          return loadFile(from: url)
        case .toggleLockState:
            return .just(.setLock(!currentState.lock))
        case .setKeyboardColor(let color):
            var keyboard = currentState.keyboard
            keyboard.backgroundColor = color
            return .just(.setKeyboard(keyboard))
        case .setKeycapColor(let color):
            return updateColor(color, keybaordPath: \.keycapBackgroundColor, keycapPath: \.keyColor)
        case .setKeycapBorderColor(let color):
            return updateColor(color, keybaordPath: \.keycapBorderColor, keycapPath: \.borderColor)
        case .setKeycapLegendColor(let color):
            return updateColor(color, keybaordPath: \.keycapLegendColor, keycapPath: \.legendColor)
        case .setKeyboardPadding(let padding):
            var keyboard = currentState.keyboard
            if keyboard.margin != padding {
                keyboard.margin = padding
                keyboard.relayoutKeycaps()
                return .just(.setKeyboard(keyboard))
            }
            return .empty()
        case .setKeyboardSize(let size):
            guard size.width > 600,  size.width < 1600,
                  size.height > 200 , size.height < 1000 else {
                return .just(.setToast(.plainText("Invalid keyboard size")))}
            var keyboard = currentState.keyboard
            if keyboard.size != size {
                keyboard.size = size
                keyboard.relayoutKeycaps()
                return .just(.setKeyboard(keyboard))
            }
            return .empty()
        case .copy:
            guard !currentState.keyboard.selectedKeycaps.isEmpty else { return .empty() }
            do {
                try currentState.keyboard.selectedKeycaps.writesToPastboard()
            } catch let err {
                kb_debg("err: \(err)")
                return .just(.setToast(.plainText("Copy failure:\(err)")))
            }
            return .just(.setToast(.plainText("Copy Success")))
        case .paste:
            guard let data = NSPasteboard.general.data(forType: .keycap) else { return .empty() }
            return ensureKeyboardUnlock {
                do {
                    let keycaps = try JSONDecoder().decode([Keycap].self, from: data)
                    var keyboard = currentState.keyboard
                    keyboard.pasteKeycaps(keycaps)
                    return .just(.setKeyboard(keyboard))
                } catch let err {
                    kb_debg("err: \(err)")
                    return .just(.setToast(.plainText("Paste failure:\(err)")))
                }
            }
        case .cut:
            return ensureKeyboardUnlock(stopOnSelectedKeycapsEmpty: true)  {
                do {
                    try currentState.keyboard.selectedKeycaps.writesToPastboard()
                } catch let err {
                    kb_debg("err: \(err)")
                    return .just(.setToast(.plainText("Cut failure:\(err)")))
                }
                return .just(
                    .mutations([.deleteKeycapIds(currentState.keyboard.selectedKeycapIDs),
                                .setToast(.plainText("Cut Success"))])
                )
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.needsLayoutKeyboard = false
        state.toast = .none
        switch mutation {
        case .setLayoutsFiles(let urls):
            state.layoutFiles = urls
        case .mutations(let mutations):
            state = mutations.reduce(state) { state, mutation in
                switch mutation {
                case .mutations: return state
                default:
                    return reduce(state: state, mutation: mutation)
                }
            }
            state.needsLayoutKeyboard = true
        case .setFileName(let name):
            state.fileName = name
        case .setToast(let toast):
            state.toast = toast
        case .addKeycaps(let keycaps):
            state.keyboard.keycaps.append(contentsOf: keycaps)
            state.needsLayoutKeyboard = true
        case .deleteKeycapIds(let keycaps):
            state.keyboard.keycaps.removeAll(where: {keycaps.contains($0.id)})
            state.needsLayoutKeyboard = !keycaps.isEmpty
        case .updateKeycaps(let keycaps):
            state.keyboard.keycaps = state.keyboard.keycaps.map { key in
                return keycaps.first(where: { $0.id == key.id }) ?? key
            }
            state.needsLayoutKeyboard = true
        case .setSelectedKeycaps(let keycaps):
            state.keyboard.selectedKeycapIDs = keycaps.map(\.id)
            state.needsLayoutKeyboard = true
        case .setKeyboard(let keyboard):
            state.keyboard = keyboard
            state.needsLayoutKeyboard = true
        case .setLock(let value):
            state.lock = value
        }
        return state
    }
}

// MARK: -
extension Array where Element == Keycap {
    func writesToPastboard() throws {
        let data = try JSONEncoder().encode(self)
        NSPasteboard.general.declareTypes([.keycap], owner: self)
        NSPasteboard.general.setData(data, forType: .keycap)
    }
}

// MARK: -
extension Keyboard {
    func write(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }
    
    static func load(from url: URL) throws ->  Keyboard  {
        let data = try Data.init(contentsOf: url)
        return try JSONDecoder().decode(Keyboard.self, from: data)
    }
}
