//
//  ButtonWithActivityIndicator.swift
//  CSBC
//
//  Created by Luke Redmore on 8/1/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ButtonWithActivityIndicator: UIButton {

        private var originalButtonText: String?

        private lazy var activityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.color = .white
            addSubview(activityIndicator)

            NSLayoutConstraint.activate([
                activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])

            return activityIndicator
        }()

        func loading(_ isLoading: Bool) {
            isEnabled = !isLoading

            if isLoading {
                originalButtonText = titleLabel?.text
                setTitle("", for: .normal)
                activityIndicator.startAnimating()
            } else {
                setTitle(originalButtonText, for: .normal)
                activityIndicator.stopAnimating()
            }
        }
    }


