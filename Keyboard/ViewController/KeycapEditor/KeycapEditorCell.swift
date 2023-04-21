//
//  KeycapEditorCell.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/7.
//

import Cocoa

class KeycapEditorCell: NSTableCellView {
   

    var nameObserver: ((String) -> Void)?
    var layoutObserver: ((LegendLayout) -> Void)?
    
    @IBOutlet weak var typeButton: NSPopUpButton! {
        didSet {
            typeButton.target = self
            typeButton.action = #selector(onSelectionChange(_:))
            typeButton.removeAllItems()
            typeButton.addItems(withTitles: LegendLayout.allTypeNames)
        }
    }
    
    @IBOutlet weak var nameLabel: NSTextField! {
        didSet {
            nameLabel.delegate = self
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(legend: LegendLayout) {
        switch legend {
        case .topLeft(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "TopLeft")
        case .topCenter(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "TopCenter")
        case .topRight(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "TopRight")
        case .centerLeft(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "CenterLeft")
        case .center(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "Center")
        case .centerRight(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "CenterRight")
        case .bottomLeft(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "BottomLeft")
        case .bottomCenter(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "BottomCenter")
        case .bottomRight(let legend):
            nameLabel.stringValue = legend.text
            typeButton.selectItem(withTitle: "BottomRight")
        }
    }
    
    @objc
    private func onSelectionChange(_ sender: NSButton!) {
        guard let layout = typeButton.selectedItem?.title else { return }
        guard let legend = LegendLayout.makeLegend(with: layout, text: nameLabel.stringValue) else { return }
        layoutObserver?(legend)
    }
}

// MARK: -
extension KeycapEditorCell: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        nameObserver?(nameLabel.stringValue)
    }
}
