//
//  KeycapEditorViewController.swift
//  Keyboard
//
//  Created by Jifu Cao on 2023/4/6.
//

import Cocoa
import RxSwift

class KeycapEditorViewController: NSViewController {
    var disposeBag: DisposeBag = .init()
    @IBOutlet weak var xPostionLabel: NSTextField!
    @IBOutlet weak var yPostionLabel: NSTextField!
    
    @IBOutlet weak var xPostionStep: NSStepper!
    @IBOutlet weak var yPostionStep: NSStepper!

    
    @IBOutlet weak var heightLabel: NSTextField!
    @IBOutlet weak var widthLabel: NSTextField!
    
    @IBOutlet weak var fontSizeLabel: NSTextField!
    @IBOutlet weak var fontSizeStep: NSStepper!

    @IBOutlet weak var borderWidthLabel: NSTextField!
    @IBOutlet weak var borderWidthStep: NSStepper!
    
    @IBOutlet weak var widthStep: NSStepper!
    @IBOutlet weak var heightStep: NSStepper!

    @IBOutlet weak var horizontalSlider: NSSlider!
    @IBOutlet weak var verticalSlider: NSSlider!

    @IBOutlet weak var paddingTopLabel: NSTextField!
    @IBOutlet weak var paddingRightLabel: NSTextField!
    @IBOutlet weak var paddingBottomLabel: NSTextField!
    @IBOutlet weak var paddingLeftLabel: NSTextField!
    
    @IBOutlet weak var paddingTopStepper: NSStepper!
    @IBOutlet weak var paddingRightStepper: NSStepper!
    @IBOutlet weak var paddingBottomStepper: NSStepper!
    @IBOutlet weak var paddingLeftStepper: NSStepper!
    
    
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.register(.init(nibNamed: "KeycapEditorCell", bundle: nil), forIdentifier: .init("KeycapEditorCell"))
        }
    }
    
    @IBOutlet weak var legendColorWell: NSColorWell!
    @IBOutlet weak var keycapColorWell: NSColorWell!
    @IBOutlet weak var keycapBorderColorWell: NSColorWell!

    @IBOutlet weak var removeButton: NSButton!

    
    @IBOutlet weak var preview: KeycapPreview!

    
    override var nibName: NSNib.Name? {
        "KeycapEditorViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickAdd(_ sender: Any) {
        reactor?.action.onNext(.addLegendcapLayout)
    }
    
    @IBAction func onClickRemove(_ sender: Any) {
        reactor?.action.onNext(.removeSelectedLegendLayout)
    }
    
    @IBAction func onClickReset(_ sender: Any) {
        reactor?.action.onNext(.reset)
    }
    
    var datasource: [LegendLayout] = [] {
        didSet {
            tableView.reloadData()
        }
    }
}

// MARK: -
extension KeycapEditorViewController: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let rowIndex = tableView.selectedRow
        reactor?.action.onNext(.selectLegendLayoutIndex( datasource.indices.contains(rowIndex) ? rowIndex : nil))
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard datasource.indices.contains(row) else { return nil }
        let legendlayout = datasource[row]
        let view = tableView.makeView(withIdentifier: .init("KeycapEditorCell"), owner: self)
        if let cell = view as? KeycapEditorCell {
            cell.setup(legend: legendlayout)
            cell.nameObserver = { [weak self] name in
                guard var layouts = self?.datasource else { return }
                layouts[row] = legendlayout.with(name)
                self?.reactor?.action.onNext(.setLegendLayouts(layouts))
            }
            
            cell.layoutObserver = { [weak self] layout in
                guard var layouts = self?.datasource else { return }
                layouts[row] = layout
                self?.reactor?.action.onNext(.setLegendLayouts(layouts))
            }
        }
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
}

// MARK: -

import ReactorKit

extension KeycapEditorViewController: StoryboardView {
    func bind(reactor: KeycapEditor) {
        
        keycapColorWell.rx.currentValue
            .map { Reactor.Action.setKeycapColor($0) }
            .merge(with: keycapBorderColorWell.rx.currentValue.map { Reactor.Action.setKeycapBorderColor($0) })
            .merge(with: legendColorWell.rx.currentValue.map { Reactor.Action.setLegendColor($0) })
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
       
        widthStep.rx.currentValue
            .map { Reactor.Action.setKeycapWidthFraction($0)}
            .merge(with: heightStep.rx.currentValue.map { Reactor.Action.setKeycapHeightFraction($0)} )
            .merge(with: xPostionStep.rx.currentValue.map { Reactor.Action.setKeycapPositionX($0)} )
            .merge(with: yPostionStep.rx.currentValue.map { Reactor.Action.setKeycapPositionY($0)} )
            .merge(with: horizontalSlider.rx.currentValue.map { Reactor.Action.setKeycapLegendOffsizeX(CGFloat($0))} )
            .merge(with: verticalSlider.rx.currentValue.map { Reactor.Action.setKeycapLegendOffsizeY(CGFloat($0))} )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
           fontSizeStep.rx
            .currentValue.map { Reactor.Action.setKeycapFontSize($0)}
            .merge(with: borderWidthStep.rx.currentValue.map { Reactor.Action.setKeycapBorderWidth(CGFloat($0))} )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        ///
        paddingTopStepper.rx
            .currentValue
            .map { Reactor.Action.mergePadding(.top, $0) }
            .merge(with: paddingLeftStepper.rx.currentValue
                .map { Reactor.Action.mergePadding(.left, $0)})
            .merge(with: paddingBottomStepper.rx.currentValue
                .map { Reactor.Action.mergePadding(.bottom, $0)})
            .merge(with: paddingRightStepper.rx.currentValue
                .map { Reactor.Action.mergePadding(.right, $0)} )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.keycap.fontSize)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] value in
                self?.fontSizeLabel.stringValue = "\(value)"
                self?.fontSizeStep.doubleValue = value
            })
            .disposed(by: disposeBag)
        
        /// board
        reactor.state
            .map(\.keycap.borderWidth)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in
                self?.borderWidthLabel.stringValue = "\(value)"
                self?.borderWidthStep.doubleValue = value
            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map(\.keycap.legendOffset.y)
            .distinctUntilChanged()
            .map {Double($0)}
            .bind(to: verticalSlider.rx.value)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.legendOffset.x)
            .distinctUntilChanged()
            .map {Double($0)}
            .bind(to: horizontalSlider.rx.value)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.keycap.x)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: xPostionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.y)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: yPostionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.width)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: widthLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.height)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: heightLabel.rx.text)
            .disposed(by: disposeBag)
        
        ///  padding
        reactor.state
            .map(\.keycap.padding.top)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingTopLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.padding.bottom)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingBottomLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.padding.left)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingLeftLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.padding.right)
            .distinctUntilChanged()
            .mapToString()
            .bind(to: paddingRightLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.keyColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keycapColorWell.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.borderColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: keycapBorderColorWell.rx.color)
            .disposed(by: disposeBag)

        reactor.state
            .map(\.keycap.legendColor)
            .distinctUntilChanged()
            .mapToColor()
            .bind(to: legendColorWell.rx.color)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keycap in
                guard let self = self else { return }
                self.preview.preview(keycap: keycap)
                self.widthStep.doubleValue = keycap.size.width / Keycap.Preferred.size.width
                self.heightStep.doubleValue = keycap.size.height / Keycap.Preferred.size.height
                self.paddingLeftStepper.doubleValue = keycap.padding.left
                self.paddingRightStepper.doubleValue = keycap.padding.right
                self.paddingTopStepper.doubleValue = keycap.padding.top
                self.paddingBottomStepper.doubleValue = keycap.padding.bottom
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.keycap.legendLayouts)
            .bind(to: rx.datasource)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.selectedIndex)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] selectedIndex in
                self?.tableView.selectRowIndexes(.init(integer: selectedIndex), byExtendingSelection: false)
            })
            .disposed(by: disposeBag)

        
        reactor.state
            .map(\.selectedLegendLayout)
            .map { $0 != nil}
            .bind(to: removeButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
}
