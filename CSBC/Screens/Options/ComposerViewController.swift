//
//  ComposerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/12/2019.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, UIAdaptivePresentationControllerDelegate, UITextViewDelegate {
    
    static let notificationConfiguration = ComposerConfiguration(submitButtonTitle: "Send", placeholderText: "Enter a message", allowParagraphBreaks: false)
    static let reportIssueConfiguration = ComposerConfiguration(submitButtonTitle: "Submit", placeholderText: "Please give a detailed description of the issue you would like to report or the suggestion you would like to submit:", allowParagraphBreaks: false)
    
    private let titleBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let bar = UIView()
    private let textView = UITextView()
    private let configuration : ComposerConfiguration!
    private let completion : ((String) -> Void)?
    
    private var placeholderTextColor : UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return .darkGray
        }
    }
    
    init(configuration : ComposerConfiguration, completion : ((String) -> Void)? = nil) {
        self.completion = completion
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        presentationController!.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .csbcBackground
        view.addSubview(titleBar)
        titleBar.backgroundColor = .csbcNavBarFlipside
        titleBar.tintColor = .csbcNavBarText
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            view.topAnchor.constraint(equalTo: titleBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        createCancelButton()
        createSubmitButton()
        createBar()
        createTextView()
    }
    
    private let cancelTitle = "Cancel"
    private let buttonFont = UIFont(name: "gotham", size: 20)!
    
    private func createCancelButton() {
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(cancelTitle, for: .normal)
        cancelButton.titleLabel?.font = buttonFont
        let width = cancelTitle.width(withConstrainedHeight: 45, font: buttonFont)
        let height = cancelTitle.height(withConstrainedWidth: width, font: buttonFont)
        titleBar.addSubview(cancelButton)
        titleBar.addConstraints([
            cancelButton.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: width),
            cancelButton.heightAnchor.constraint(equalToConstant: height)
        ])
        
    }
    private func createSubmitButton() {
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle(configuration.submitButtonTitle, for: .normal)
        submitButton.titleLabel?.font = buttonFont
        let width = configuration.submitButtonTitle.width(withConstrainedHeight: 45, font: buttonFont)
        let height = configuration.submitButtonTitle.height(withConstrainedWidth: width, font: buttonFont)
        titleBar.addSubview(submitButton)
        titleBar.addConstraints([
            submitButton.trailingAnchor.constraint(equalTo: titleBar.trailingAnchor, constant: -16),
            submitButton.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: width),
            submitButton.heightAnchor.constraint(equalToConstant: height)
        ])
        
    }
    private func createBar() {
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .csbcYellow
        view.addSubview(bar)
        view.addConstraints([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    private func createTextView() {
        textView.delegate = self
        textView.returnKeyType = configuration.allowParagraphBreaks ? .default : .send
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = configuration.placeholderText
        textView.font = UIFont(name: "gotham-book", size: 17)
        textView.textColor = placeholderTextColor
        textView.tintColor = .csbcYellow
        textView.backgroundColor = .csbcBackground
        view.addSubview(textView)
        view.addConstraints([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 5),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        guard submittableText(textView.text) else { dismiss(animated: true); return }
        confirmCancellation()
    }
    @objc func submitButtonPressed(_ sender: UIButton) {
        submit(textView.text)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard submittableText(textView.text) else { return true }
        confirmCancellation()
        return false
    }
    
    
    //MARK: UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == configuration.placeholderText && textView.textColor == placeholderTextColor {
            textView.text = ""
            textView.textColor = .csbcDefaultText
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if !submittableText(textView.text) {
            textView.text = configuration.placeholderText
            textView.textColor = placeholderTextColor
        }
        textView.resignFirstResponder()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        if configuration.allowParagraphBreaks {
            return true
        } else {
            confirmSubmisssion()
            return false
        }
    }
    
    private func confirmSubmisssion() {
        guard submittableText(textView.text) else { return }
        let keepEditing = UIAlertAction(title: "Keep Editing", style: .cancel)
        let send = UIAlertAction(title: "Submit", style: .default) { action in
            self.submit(self.textView.text)
        }
        let menu = UIAlertController(title: "Ready to submit?", message: nil, preferredStyle: .alert)
        menu.addAction(keepEditing)
        menu.addAction(send)
        present(menu, animated: true)
    }
    private func submit(_ text : String) {
        guard submittableText(textView.text) else { return }
        submitButton.isEnabled = false
        self.dismiss(animated: true)
        completion?(text)
    }
    private func submittableText(_ text : String) -> Bool {
        return textView.text != "" && textView.text != configuration.placeholderText && textView.text != "\n"
    }
    
    private func confirmCancellation() {
        let discard = UIAlertAction(title: "Discard Changes", style: .destructive) { action in
            self.dismiss(animated: true)
        }
        let keepEditing = UIAlertAction(title: "Keep Editing", style: .cancel)
        let menu = UIAlertController(title: "Are you sure you want to discard?", message: nil, preferredStyle: .actionSheet)
        menu.addAction(discard)
        menu.addAction(keepEditing)
        present(menu, animated: true)
    }
}

struct ComposerConfiguration {
    let submitButtonTitle : String
    let placeholderText : String
    let allowParagraphBreaks : Bool
}
