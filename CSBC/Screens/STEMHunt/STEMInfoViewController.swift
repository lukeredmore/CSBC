//
//  STEMInfoViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 1/12/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class STEMInfoViewController: UIViewController, UITextFieldDelegate {

    let model : STEMTableModel!
    private let completion : (() -> Void)?
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var answerLabel: UITextField!
    @IBOutlet weak var keyboardSpacingConstraint: NSLayoutConstraint!
    
    init(for model : STEMTableModel, completion : (() -> Void)? = nil) {
        self.model = model
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionLabel.text = model.question
        organizationLabel.text = model.organization
        titleLabel.text = model.title
        headerImageView.image = UIImage(named: "\(model.imageIdentifier)header") ?? UIImage(named: "setonBuilding")
        descriptionTextView.text = model.description
        
        answerLabel.returnKeyType = .send
        
        if model.answered {
            answerLabel.delegate = nil
            answerLabel.isEnabled = false
            answerLabel.text = model.answer.components(separatedBy: ", ")[0]
        } else {
            answerLabel.delegate = self
            answerLabel.isEnabled = true
            answerLabel.text = ""
            answerLabel.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string == "\n" else { return true }
        if model.answer.lowercased().components(separatedBy: ", ").contains(textField.text?.lowercased() ?? "") {
            completion?()
            answerLabel.delegate = nil
            answerLabel.isEnabled = false
            answerLabel.text = model.answer
            dismiss(animated: true)
        } else {
            answerLabel.shake()
            answerLabel.text = ""
        }
        return false
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardSpacingConstraint.constant = keyboardRectangle.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 16
        }
    }
}

extension UIView {
    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
