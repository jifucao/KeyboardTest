//
//  NSView+Toast.swift
//  Keyboard
//
//  Created by Jifu on 2023/4/10.
//

import AppKit


// MARK: -
extension NSView {
    enum ToastStyle {
        case textPlain
        case success
        case failure
        
        var image: NSImage? {
            nil
        }
        
        var contentTintColor: NSColor { .white }
    }
    
    enum ToastPosition {
        case top
        case center
        case bottom
    }

    private func _makeToastView(text: String, style: ToastStyle) -> NSView {
        let label = NSTextField.init(labelWithString: text)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        let stackView = NSStackView.init(views: [label])
        stackView.orientation = .horizontal
        stackView.spacing = 10
        if let image = style.image {
            image.isTemplate = true
            let imageView = NSImageView.init(image: image)
            imageView.contentTintColor = style.contentTintColor
            stackView.insertArrangedSubview(imageView, at: 0)
        }
        stackView.edgeInsets = .init(top: 16, left: 26, bottom: 16, right: 26)
        let backgroundColor = NSColor.black
        let borderColor = NSColor.black
        /// wrapper
        let containerView = NSView()
        containerView.addSubview(stackView)
        containerView.frame.size = stackView.fittingSize
        containerView.autoresizingMask = [.width,.height]
        containerView.wantsLayer = true
        containerView.shadow = NSShadow()
        containerView.shadow = NSShadow()
        containerView.layer?.backgroundColor = backgroundColor.cgColor
        containerView.layer?.cornerRadius = 5.0
        containerView.layer?.shadowOpacity = 1.0
        containerView.layer?.shadowColor = NSColor.init(white: 0, alpha: 0.15).cgColor
        containerView.layer?.shadowOffset = NSMakeSize(0, 0)
        containerView.layer?.shadowRadius = 10
        containerView.setBackgroundColor(backgroundColor)
        containerView.setBorder(borderColor, width: 1, cornerRadius: 24)
        return containerView
    }
    
    func makeToast(message: ToastMessage, duration: CGFloat = 2.0) {
        switch message {
        case .none: break
        case .plainText(let text, _):
            makeToast(text, style: .textPlain, position: .top, duration: duration)
        case .success:
            makeToast("Success", style: .success, position: .top, duration: duration)
        case .failure:
            makeToast("Failure", style: .failure, position: .top, duration: duration)
        }
    }
    
    func makeToast(_ text: String,
                   style: ToastStyle = .textPlain,
                   position: ToastPosition = .top,
                   duration: CGFloat = 2.0) {
        guard let contentView = window?.contentView else { return }
        let toastView = _makeToastView(text: text, style: style)
        contentView.addSubview(toastView)
        let toastFrame = toastView.frame
        let contentFrame = contentView.frame
        toastView.frame.origin = .init(x: (contentFrame.size.width - toastFrame.size.width)/2, y: contentFrame.size.height - toastFrame.size.height - 88 + 48)
        toastView.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.33
            context.timingFunction = .init(name: .easeIn)
            toastView.animator().alphaValue = 1.0
            toastView.animator().frame.origin.y -= 48
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            NSAnimationContext.runAnimationGroup ({ context in
                context.duration = 0.33
                context.timingFunction = .init(name: .easeOut)
                toastView.animator().alphaValue = 0
                toastView.animator().frame.origin.y += 48
            }) {
                toastView.removeFromSuperview()
            }
        }
    }
}
