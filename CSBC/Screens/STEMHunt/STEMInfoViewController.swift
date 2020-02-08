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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var answerLabel: UITextField!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var keyboardSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    init(for model : STEMTableModel, completion : (() -> Void)? = nil) {
        self.model = model
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        registerForKeyboardNotifications()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        
        //Add data
        view.addVerticalGradient(from: .stemAccentBlue, to: .stemBaseBlue)
        questionLabel.text = model.question
        organizationLabel.text = model.organization
        titleLabel.text = model.title
        let headerName = model.imageIdentifier == nil ? model.identifier : model.imageIdentifier!
        headerImageView.image = UIImage(named: "\(headerName)header") ?? UIImage(named: "setonBuilding")
        descriptionLabel.text = model.description
        answerLabel.returnKeyType = .send
        descriptionHeightConstraint.constant = model.description.height(withConstrainedWidth: UIScreen.main.bounds.width - 16, font: UIFont(name: "Gotham-Book", size: 15)!)
    }
    deinit { unregisterForKeyboardNotifications() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    override func viewDidLoad() {
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
    
    
    //MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string == "\n" else { return true }
        if model.answer.lowercased().replacingOccurrences(of: " ", with: "").components(separatedBy: ",").contains(textField.text?.lowercased().replacingOccurrences(of: " ", with: "") ?? "") {
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
    
    
    //MARK: Keyboard Spacing
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    

    @objc func onKeyboardAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardSpacingConstraint.constant = keyboardFrame.cgRectValue.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
    }

    @objc func onKeyboardDisappear(_ notification: Notification) {
        keyboardSpacingConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
}
