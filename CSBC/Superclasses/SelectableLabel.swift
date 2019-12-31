//
//  SelectableLabel.swift
//  CSBC
//
//  Created by Luke Redmore on 12/30/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

/// Label that allows selection with long-press gesture, e.g. for copy-paste.
class SelectableLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = true
        addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPress(_:))
            )
        )
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    // MARK: - UIResponderStandardEditActions

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }

    // MARK: - Long-press Handler

    @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .began,
            let recognizerView = recognizer.view,
            let recognizerSuperview = recognizerView.superview {
            UIMenuController.shared.setTargetRect(recognizerView.frame, in: recognizerSuperview)
            UIMenuController.shared.setMenuVisible(true, animated:true)
            recognizerView.becomeFirstResponder()
        }
    }

}
