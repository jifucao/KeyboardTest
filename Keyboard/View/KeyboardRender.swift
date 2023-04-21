//
//  KeyboardRender.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/3/30.
//

import Foundation
import AppKit

func kb_debg(_ content: @autoclosure () -> String) {
#if DEBUG
    print("\(content())")
#endif
}

// MARK: -
protocol KeyboardRenderDelegate: AnyObject {
    /// 选中时的主菜单
    var primaryMenu: NSMenu? { get }
    /// 非选中时的附加菜单
    var contextMenu: NSMenu? { get }
    /// 双击
    func onKeycapDoubleClicked(_ keycap: Keycap, in render: KeyboardRender)
    /// 选中
    func onSelected(keycaps: [Keycap], in render: KeyboardRender)
    /// 更新位置
    func keycapPositionDidUpdate(_ keycap: Keycap, position:  NSPoint, in render: KeyboardRender)
    //// 按键选择样式
    func configureKeycapSelectedStyle(_ keycap: KeycapView)
}

// MARK: -
extension KeyboardRenderDelegate {
    var primaryMenu: NSMenu?  { nil }
    var contextMenu: NSMenu? { nil }
    
    func configureKeycapSelectedStyle(_ keycap: KeycapView) {}
    func onKeycapDoubleClicked(_ keycap: Keycap, in render: KeyboardRender) {}
    func keycapPositionDidUpdate(_ keycap: Keycap, position: NSPoint, in render: KeyboardRender) {}
}

// MARK: -
extension KeyboardRender {
    /// 键盘重新布局
    func layout(with keyboard: Keyboard) {
        keyboardSize = keyboard.size
        keyboardPadding = keyboard.margin
        setBackgroundColor(keyboard.backgroundColor.mapToColor())
        subviews.forEach {
            $0.removeFromSuperview()
        }
        keyboard.keycaps.forEach { kc in
            let key = KeycapView(keycap: kc)
            key.selectedStyleProvider = { [weak self] keycap in
                self?.delegate?.configureKeycapSelectedStyle(keycap)
            }
            addSubview(key)
            key.render()
            key.isSelected = keyboard.selectedKeycapIDs.contains(kc.id)
        }
        needsLayout = true
    }
}

// MARK: -
final class KeyboardRender: NSView {
    
    weak var delegate: KeyboardRenderDelegate?
    
    /// 是否允许编辑
    var canEdit: Bool = true
    /// 显示边距线
    var showsBoundary: Bool = true
    /// 键盘边距
    var keyboardPadding: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    /// 键盘大小
    var keyboardSize: NSSize = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// 最近点击按键的位置坐标（相对按键坐标系）
    private var clickedKeycapsLocation: NSPoint = .zero
    
    /// 最近鼠标右键点击的位置坐标
    private var mouseDownloadLocation: NSPoint = .zero
    
    /// 最近选择的按键
    private var hitFirstKeycap: KeycapView?
    
    /// 边界框位置
    private var boudndaryFrame: CGRect = .zero {
        didSet {
            drawsBoundary()
        }
    }
    
    /// 选中点按键
    var selectedKeycapViews: [KeycapView] {
        subviews.compactMap { $0 as? KeycapView }
            .filter(\.isSelected)
    }
    
    /// 选择框图层
    private lazy var selectionFrameLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 1.0
        layer.borderColor = NSColor.gray.cgColor
        layer.masksToBounds = true
        return layer
    }()
    
    /// 边界框图层
    private lazy var boundaryLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = NSColor.blue.withAlphaComponent(0.5).cgColor
        layer.lineDashPattern = [2, 2]
        self.layer?.addSublayer(layer)
        return layer
    }()
    
    override var intrinsicContentSize: NSSize {
        keyboardSize
    }
    
    /// 绘制选择框
    private func drawsSelectionFrame(from start: NSPoint, to end: NSPoint) {
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        let x: CGFloat = min(start.x, end.x)
        let y: CGFloat = min(start.y, end.y)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        selectionFrameLayer.frame = .init(x: x, y: y, width: width, height: height)
        CATransaction.commit()
    }
    
    /// 绘制边界框
    private func drawsBoundary() {
        guard showsBoundary else { boundaryLayer.frame = .zero; return }
        boundaryLayer.frame = boudndaryFrame
        boundaryLayer.path = CGPath.init(rect: boundaryLayer.bounds, transform: nil)
    }
    
    /// 有效绘制点
    private func validPointOfBoundary(origin: CGPoint, size: CGSize) -> CGPoint {
        let x = min((bounds.size.width - size.width - keyboardPadding.right), max(keyboardPadding.left, origin.x))
        let y = min((bounds.size.height - size.height - keyboardPadding.top), max(keyboardPadding.bottom, origin.y))
        return CGPoint(x: x, y: y)
    }

    override func layout() {
        super.layout()
        boudndaryFrame = .init(x: keyboardPadding.left,
                               y: keyboardPadding.bottom,
                               width: frame.size.width - keyboardPadding.left - keyboardPadding.right,
                               height: frame.size.height - keyboardPadding.bottom - keyboardPadding.top)
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        let location = event.locationInWindow
        if let v = hitTest(location) as? KeycapView {
            if !v.isSelected {
                hitFirstKeycap = v
                let allSelectedKeycaps = selectedKeycapViews.map(\.keycap) + [v.keycap]
                delegate?.onSelected(keycaps: allSelectedKeycaps, in: self)
            }
            
            if let primaryMenu = delegate?.primaryMenu {
                primaryMenu.popUp(positioning: nil, at: convert(location, from: nil), in: self)
            }
        } else {
            if let contextMenu = delegate?.contextMenu {
                contextMenu.popUp(positioning: nil, at: convert(location, from: nil), in: self)
            }
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        mouseDownloadLocation = convert(location, from: nil)
        if let v = hitTest(location) as? KeycapView {
            hitFirstKeycap = v
            clickedKeycapsLocation = v.convert(location, from: nil)
        } else {
            hitFirstKeycap = nil
            clickedKeycapsLocation = .zero
            layer?.addSublayer(selectionFrameLayer)
        }
        if event.clickCount == 2, let keycap = hitFirstKeycap?.keycap {
            delegate?.onKeycapDoubleClicked(keycap, in: self)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if canEdit, let v = hitFirstKeycap {
            let keycap = v.keycap
            let location = event.locationInWindow
            let mouseLocation = self.convert(location, from: nil)
            let xPos = mouseLocation.x - clickedKeycapsLocation.x
            let yPos = mouseLocation.y - clickedKeycapsLocation.y
            let pos = validPointOfBoundary(origin: .init(x: xPos, y: yPos), size: v.frame.size)
            delegate?.keycapPositionDidUpdate(keycap,
                                              position: pos,
                                              in: self)
        }
        
        if let selectedKeycapView = hitFirstKeycap {
            delegate?.onSelected(keycaps: [selectedKeycapView.keycap], in: self)
        } else {
            let frame = selectionFrameLayer.frame
            let keycaps = subviews.compactMap { v -> Keycap? in
                guard let keycapView = v as? KeycapView else { return nil }
                guard frame.intersects(keycapView.frame) else { return nil}
                return keycapView.keycap
            }
            selectionFrameLayer.removeFromSuperlayer()
            selectionFrameLayer.frame = .zero
            delegate?.onSelected(keycaps: keycaps, in: self)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard canEdit else { return }
        guard let v = hitFirstKeycap else {
            let windowLocation = event.locationInWindow
            let location = convert(windowLocation, from: nil)
            drawsSelectionFrame(from: mouseDownloadLocation, to: location)
            return
        }
        let location = event.locationInWindow
        let mouseLocation = self.convert(location, from: nil)
        let xPos = mouseLocation.x - clickedKeycapsLocation.x
        let yPos = mouseLocation.y - clickedKeycapsLocation.y
        v.frame.origin = validPointOfBoundary(origin: .init(x: xPos, y: yPos), size: v.frame.size)
    }
}
