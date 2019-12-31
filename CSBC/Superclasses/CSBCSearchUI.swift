//
//  CSBCSearchUI.swift
//  CSBC
//
//  Created by Luke Redmore on 12/11/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CSBCSearchUI : UIView {
    lazy var headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: SearchScrollDelegate.maxHeaderHeight)
    lazy var backgroundButton = createBackgroundButton()
    let emptyDataLabel = UILabel()
    
    private let header = UIView()
    private let bar = UIView()
    private var backgroundButtonPressed : () -> Void
    private var configuration : CSBCSearchConfiguration
    
    init(tableView : UITableView, searchController : UISearchController, configuration : CSBCSearchConfiguration, backgroundButtonPressed : @escaping () -> Void) {
        self.configuration = configuration
        self.backgroundButtonPressed = backgroundButtonPressed
        super.init(frame: UIScreen.main.bounds)
        translatesAutoresizingMaskIntoConstraints = true
        backgroundColor = .csbcNavBarBackground
        configureHeader(header)
        configureBackgroundView()
        configureBackgroundLabel(emptyDataLabel)
        configureBackgroundButton(backgroundButton)
        configureYellowBar(bar)
        configureSearchBar(controller: searchController)
        configureTableView(tableView)
        sendSubviewToBack(header)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHeader(_ header : UIView) {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .csbcNavBarBackground
        addSubview(header)
        addConstraints([
            header.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            headerHeightConstraint,
            header.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private func configureBackgroundView() {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bgView)
        addConstraints([
            bgView.topAnchor.constraint(equalTo: header.bottomAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        bgView.backgroundColor = .csbcBackground
    }
   private func configureBackgroundLabel(_ label : UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "Gotham-BookItalic", size: 18)!
        label.numberOfLines = 0
        label.clipsToBounds = false
        label.textColor = .csbcGrayLabel
        label.text = configuration.emptyDataMessage
        addSubview(label)
        addConstraints([
            label.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            label.heightAnchor.constraint(equalToConstant: label.text?.height(withConstrainedWidth: frame.width - 20, font: UIFont(name: "Gotham-BookItalic", size: 18)!) ?? 30),
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    private func configureBackgroundButton(_ button : UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        addConstraints([
            button.topAnchor.constraint(equalTo: emptyDataLabel.bottomAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureYellowBar(_ bar : UIView) {
        bar.backgroundColor = .csbcYellow
        bar.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(bar)
        header.addConstraints([
            bar.heightAnchor.constraint(equalToConstant: 8),
            bar.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            bar.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: header.trailingAnchor)
        ])
    }
    private func configureSearchBar(controller : UISearchController) {
        controller.searchBar.translatesAutoresizingMaskIntoConstraints = false
        controller.searchBar.removeFromSuperview()
        header.addSubview(controller.searchBar)
        header.addConstraints([
            controller.searchBar.bottomAnchor.constraint(equalTo: bar.topAnchor),
            controller.searchBar.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            controller.searchBar.trailingAnchor.constraint(equalTo: header.trailingAnchor)
        ])
        
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.tintColor = .white
        controller.searchBar.isTranslucent = false
        controller.searchBar.barTintColor = .csbcNavBarBackground
        controller.searchBar.searchField.backgroundColor = .csbcLightGreen
        controller.searchBar.searchField.textColor = .white
        controller.searchBar.backgroundImage = UIImage()
        controller.searchBar.clipsToBounds = true
        controller.searchBar.placeholder = configuration.searchPlaceholder
        controller.searchBar.setPlaceholder(textColor: .white)
        controller.searchBar.setSearchImage(color: .white)
        controller.searchBar.searchField.clearButtonMode = .never
    }
    private func configureTableView(_ tableView : UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addConstraints([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
        tableView.allowsSelection = configuration.allowSelection
        tableView.backgroundColor = .clear
        bringSubviewToFront(tableView)
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54))
        let button = createBackgroundButton()
        button.frame = footer.frame
        footer.addSubview(button)
        footer.backgroundColor = .csbcBackground
        tableView.tableFooterView = footer
        
    }
    
    func resetSearchBarUI(controller : UISearchController) {
        configureSearchBar(controller: controller)
    }
    
    private func createBackgroundButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "gotham", size: 18)!
        button.setTitle(configuration.backgroundButtonText, for: .normal)
        button.setTitleColor(.csbcAlwaysGray, for: .normal)
        button.addTarget(self, action: #selector(bkgButtonPressed), for: .touchUpInside)
        return button
    }
    @objc private func bkgButtonPressed() {
        self.backgroundButtonPressed()
    }
}

fileprivate extension UISearchBar {

    func setPlaceholder(textColor: UIColor) { searchField.setPlaceholder(textColor: textColor) }

    func setSearchImage(color: UIColor) {
        guard let imageView = searchField.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

fileprivate extension UITextField {

    private class ColoredLabel: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }

        init(_ label : UILabel, textColor : UIColor) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }
        
        required init?(coder: NSCoder) { super.init(coder: coder) }
    }
    
    
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = value(forKey: "placeholderLabel") as? UILabel else { return }
        let coloredLabel = ColoredLabel(placeholderLabel, textColor: textColor)
        setValue(coloredLabel, forKey: "placeholderLabel")
    }
}
