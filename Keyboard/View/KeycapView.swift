//
//  KeycapView.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/8.
//

import AppKit

// MARK: -
final class KeycapView: NSView {
    
    var selectedStyleProvider: (KeycapView) -> Void = { view in
        view.setBorder(Keycap.Preferred.selectedBorderColorValue.mapToColor(),
                       width: 2,
                       cornerRadius: view.keycap.cornerRadius)
    }
    
    var keycap: Keycap {
        didSet {
            render()
        }
    }
    
    init(keycap: Keycap) {
        self.keycap = keycap
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                selectedStyleProvider(self)
            } else {
                render()
            }
            layer?.masksToBounds = isSelected
        }
    }
    
    func render() {
        wantsLayer = true
        frame = .init(x: keycap.x, y: keycap.y, width: keycap.width, height: keycap.height)
        setBackgroundColor(keycap.keyColor.mapToColor())
        setBorder(keycap.borderColor.mapToColor(),
                  width: keycap.borderWidth,
                  cornerRadius: keycap.cornerRadius)
        layer?.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        keycap.legendLayouts.forEach { legend in
            layoutLegend(legend)
        }
    }
    
    private func rendLegend(_ legend: Legend) -> CALayer {
        switch legend {
        case .image(let string):
            let image = NSImage(contentsOf: URL(fileURLWithPath: string))
            let layer = CALayer()
            layer.contents = image
            return layer
        case .text(let string):
            let layer = CATextLayer()
            layer.string = string
            layer.fontSize = keycap.fontSize
            layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
            layer.foregroundColor = keycap.legendColor.mapToColor().cgColor
            layer.alignmentMode = .center
            return layer
        }
    }
    
    private func layoutLegend(_ legendLayout: LegendLayout) {
        let bounds = bounds
        let vUnit = bounds.height / 3
        let hUnit = bounds.width / 3
        let maxHeight: CGFloat = keycap.fontSize * 1.2
        let layer: CALayer
        switch legendLayout {
        case .center(let legend):
             layer = rendLegend(legend)
            self.layer?.addSublayer(layer)
            layer.frame = .init(x: keycap.legendOffset.x,
                                y: keycap.legendOffset.y + vUnit,
                                width: bounds.size.width,
                                height: maxHeight)
        case .bottomCenter(let legend):
             layer = rendLegend(legend)
            layer.frame = .init(x: keycap.legendOffset.x,
                                y: keycap.legendOffset.y + keycap.padding.bottom,
                                width: bounds.size.width,
                                height: maxHeight)
        case .topLeft(let legend):
             layer = rendLegend(legend)
            (layer as? CATextLayer)?.alignmentMode = .left
            layer.frame = .init(x: keycap.legendOffset.x + keycap.padding.left,
                                y: keycap.legendOffset.y + vUnit * 2 - keycap.padding.top,
                                width: bounds.size.width,
                                height: maxHeight)
        case .topCenter(let legend):
             layer = rendLegend(legend)
            layer.frame = .init(x: keycap.legendOffset.x,
                                y: keycap.legendOffset.y + vUnit * 2 - keycap.padding.top,
                                width: bounds.size.width,
                                height: maxHeight)
        case .topRight(let legend):
             layer = rendLegend(legend)
            (layer as? CATextLayer)?.alignmentMode = .right
            layer.frame = .init(x: keycap.legendOffset.x - keycap.padding.right,
                                y: keycap.legendOffset.y + vUnit * 2 - keycap.padding.top,
                                width: bounds.size.width,
                                height: maxHeight)
        case .centerLeft(let legend):
             layer = rendLegend(legend)
            self.layer?.addSublayer(layer)
            (layer as? CATextLayer)?.alignmentMode = .left
            layer.frame = .init(x: keycap.legendOffset.x,
                                y: keycap.legendOffset.y + vUnit,
                                width: bounds.size.width,
                                height: maxHeight)
        case .centerRight(let legend):
             layer = rendLegend(legend)
            (layer as? CATextLayer)?.alignmentMode = .right
            layer.frame = .init(x: keycap.legendOffset.x + hUnit * 2,
                                y: keycap.legendOffset.y + vUnit,
                                width: bounds.size.width,
                                height: maxHeight)
        case .bottomLeft(let legend):
             layer = rendLegend(legend)
            (layer as? CATextLayer)?.alignmentMode = .left
            layer.frame = .init(x: keycap.legendOffset.x + keycap.padding.left,
                                y: keycap.legendOffset.y + keycap.padding.bottom,
                                width: bounds.size.width,
                                height: maxHeight)
        case .bottomRight(let legend):
             layer = rendLegend(legend)
            (layer as? CATextLayer)?.alignmentMode = .right
            layer.frame = .init(x: keycap.legendOffset.x - keycap.padding.right,
                                y: keycap.legendOffset.y + keycap.padding.bottom,
                                width: bounds.size.width,
                                height: maxHeight)
        }
        self.layer?.addSublayer(layer)
    }
}

