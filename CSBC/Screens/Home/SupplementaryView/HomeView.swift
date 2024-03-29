//
//  HomeView.swift
//  CSBC
//
//  Created by Luke Redmore on 9/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase

protocol SegueDelegate : class {
    func performSegue(withIdentifier identifier: String, sender: Any?)
    var lastSeguedWebView : WebViewController? { get }
    func modalHoverViewTapped()
    var navigationController : UINavigationController? { get }
}

class HomeView: UIView, AlertDelegate {
    private lazy var collectionController = HomeCollectionController(segueDelegate: segueDelegate)
    
    var alertMessage : String? {
        didSet { rebuild() }
    }
    private var alertBannerHeight : CGFloat? = nil
    private weak var segueDelegate : SegueDelegate!
    private var splashView : CSBCSplashView? = nil
    
    init(segueDelegate : SegueDelegate) {
        self.segueDelegate = segueDelegate
        super.init(frame: .zero)
        rebuild()
        splashView = CSBCSplashView(addToView: self)
        UserDefaults.standard.set(nil, forKey: "customNavBarColor")
        UserDefaults.standard.set(nil, forKey: "customSearchFieldColor")
        UserDefaults.standard.set(nil, forKey: "customBarColor")
    }
    func rebuild() {
        print("Building home view with alert message of: ", alertMessage ?? "nil")
        subviews.forEach { $0.removeFromSuperview() }
        alertBannerHeight = nil
        backgroundColor = .csbcNavBarBackground
        if let alertText = alertMessage?.replacingOccurrences(of: "--include-covid-modal--", with: ""), alertText != "" {
            let alertLabel = UILabel()
            alertLabel.numberOfLines = 0
            alertLabel.text = alertText
            let font = UIFont(name: "gotham-bold", size: 18)!
            let height = alertText.height(withConstrainedWidth: UIScreen.main.bounds.width, font: font)
            alertLabel.font = font
            alertLabel.textColor = .white
            alertLabel.frame = CGRect(x: (UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0), y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0), width: (UIScreen.main.bounds.width - (2*(UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0))), height: height)
            alertLabel.textAlignment = NSTextAlignment.center
            let alertView = UIView()
            alertView.backgroundColor = .csbcAlertRed
            alertView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: safeAreaInsets.top + alertLabel.frame.height + 8)
            alertBannerHeight = alertLabel.frame.height + 13
            alertView.addSubview(alertLabel)
            alertView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerTapped)))
            addSubview(alertView)
        }
        
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: 109))
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.image = UIImage(named: "wordmark")
        headerImageView.isUserInteractionEnabled = true
        addSubview(headerImageView)
        
        let barHeight : CGFloat = CovidViewController.showCovidCheckIn ? 56.0 : 14.0
        
        
        let barView = UIView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 119 + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: barHeight))
        barView.backgroundColor = .csbcYellow
        addSubview(barView)
        
        //MARK: COVID-SPECIFIC
        let modalHoverViewHeight = alertMessage?.contains("--include-covid-modal--") ?? false ? createCOVIDView() : 0.0
        
        if CovidViewController.showCovidCheckIn {
            let questionaireLabel = UILabel()
            questionaireLabel.numberOfLines = 0
            questionaireLabel.text = "COVID-19 Check-In ►"
            questionaireLabel.font = UIFont(name: "gotham-bold", size: 24)!
            questionaireLabel.textColor = .white
            questionaireLabel.translatesAutoresizingMaskIntoConstraints = false
            questionaireLabel.textAlignment = NSTextAlignment.center
            
            barView.addSubview(questionaireLabel)
            barView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(covidQuestionnaireTapped)))
            barView.addConstraints([
                barView.bottomAnchor.constraint(equalTo: questionaireLabel.bottomAnchor),
                barView.leadingAnchor.constraint(equalTo: questionaireLabel.leadingAnchor),
                barView.trailingAnchor.constraint(equalTo: questionaireLabel.trailingAnchor),
                barView.topAnchor.constraint(equalTo: questionaireLabel.topAnchor)
            ])
        }
        
        let collectionView = HomeScreenCollectionView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 117 + barHeight + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - safeAreaInsets.top - 117 - barHeight - (alertBannerHeight ?? 0) - modalHoverViewHeight))
        addSubview(collectionView)
        collectionView.dataSource = collectionController
        collectionView.delegate = collectionController
        
        if let spl = splashView {
            self.addSubview(spl)
            spl.startAnimation { self.splashView = nil }
            bannerTapped()
        }
        
    }
    
    @objc func bannerTapped() {
        guard alertMessage != nil, alertMessage != "" else { return }
        Database.database().reference(withPath: "BannerAlert/shouldSnow").observeSingleEvent(of: .value) { (snapshot) in
            if let shouldSnow = snapshot.value as? Bool, shouldSnow {
                SnowFallView.overlay(onView: self, count: 2)
            }
        }
    }
    
    @objc func covidQuestionnaireTapped() {
        segueDelegate.performSegue(withIdentifier: "CovidSegue", sender: nil)
    }
    
    @objc func modalHoverViewTapped() {
        segueDelegate.modalHoverViewTapped()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCOVIDView() -> CGFloat {
        
        let covidViewHeight : CGFloat = 180
        let backgroundView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - covidViewHeight, width: UIScreen.main.bounds.width, height: covidViewHeight))
        backgroundView.backgroundColor = .csbcBackground
        addSubview(backgroundView)
        
        let covidView = UIView(frame: backgroundView.frame)
        covidView.layer.cornerRadius = 20
        covidView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        covidView.addVerticalGradient(from: .csbcAlertRed, to: .red)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "COVID-19"
        titleLabel.font = UIFont(name: "DINCondensed-Bold", size: 87)
        titleLabel.textColor = .white
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .white
        let imageAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            imageAttachment.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        
        let fullString = NSMutableAttributedString(string: "View Updates ")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        subtitleLabel.attributedText = fullString
        subtitleLabel.font = UIFont(name: "Gotham-Medium", size: 24)
        subtitleLabel.numberOfLines = 0
        covidView.addSubview(titleLabel)
        covidView.addSubview(subtitleLabel)
        covidView.addConstraints([
            subtitleLabel.bottomAnchor.constraint(equalTo: covidView.bottomAnchor, constant: -40),
            subtitleLabel.leadingAnchor.constraint(equalTo: covidView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: covidView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: covidView.centerYAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: covidView.centerXAnchor)
        ])
        
        covidView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modalHoverViewTapped)))
        addSubview(covidView)
        return covidViewHeight
    }
    
}
