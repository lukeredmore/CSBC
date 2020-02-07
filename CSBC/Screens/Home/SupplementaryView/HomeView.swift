//
//  HomeView.swift
//  CSBC
//
//  Created by Luke Redmore on 9/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


protocol SegueDelegate : class {
    func performSegue(withIdentifier identifier: String, sender: Any?)
    var lastSeguedWebView : WebViewController? { get }
    func stemViewTapped()
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
    }
    func rebuild() {
        print("Building home view with alert message of: ", alertMessage ?? "nil")
        subviews.forEach { $0.removeFromSuperview() }
        alertBannerHeight = nil
        backgroundColor = .csbcNavBarBackground
        if let alertMessage = alertMessage, alertMessage != "" {
            let alertLabel = UILabel()
            alertLabel.numberOfLines = 0
            alertLabel.text = alertMessage
            let height = alertMessage.height(withConstrainedWidth: UIScreen.main.bounds.width, font: UIFont(name: "gotham-bold", size: 18)!)
            alertLabel.font = UIFont(name: "gotham-bold", size: 18)
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
        
        let barView = UIView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 119 + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: 14))
        barView.backgroundColor = .csbcYellow
        addSubview(barView)
        
        let stemViewHeight = createStemView()
        
        let collectionView = HomeScreenCollectionView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 131 + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - safeAreaInsets.top - 131 - (alertBannerHeight ?? 0) - stemViewHeight))
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
        SnowFallView.overlay(onView: self, count: 2)
    }
    @objc func stemViewTapped() {
        segueDelegate.stemViewTapped()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createStemView() -> CGFloat {
        let startDateString = "02/20/2020 17:00:00"
        let endDateString = "02/21/2020 06:00:00"
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let startDate = fmt.date(from: startDateString)!
        let endDate = fmt.date(from: endDateString)!
        if Date() < startDate || Date() > endDate { return 0.0 }
        
        let stemViewHeight : CGFloat = 180
        let backgroundView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - stemViewHeight, width: UIScreen.main.bounds.width, height: stemViewHeight))
        backgroundView.backgroundColor = .csbcBackground
        addSubview(backgroundView)
        
        let stemView = UIView(frame: backgroundView.frame)
//        stemView.backgroundColor = .csbcGreen
        stemView.layer.cornerRadius = 20
        stemView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        stemView.layer.addSublayer(CAGradientLayer.stemNight(superview: stemView))
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "STEM NIGHT"
        titleLabel.font = UIFont(name: "DINCondensed-Bold", size: 87)
        titleLabel.textColor = .orange
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .orange
        let imageAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            imageAttachment.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))?
                .withTintColor(.orange, renderingMode: .alwaysOriginal)
        }
        
        let fullString = NSMutableAttributedString(string: "Join the scavenger hunt ")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        subtitleLabel.attributedText = fullString
        subtitleLabel.font = UIFont(name: "Gotham-Medium", size: 24)
        subtitleLabel.numberOfLines = 0
        stemView.addSubview(titleLabel)
        stemView.addSubview(subtitleLabel)
        stemView.addConstraints([
            subtitleLabel.bottomAnchor.constraint(equalTo: stemView.bottomAnchor, constant: -40),
            subtitleLabel.leadingAnchor.constraint(equalTo: stemView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: stemView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: stemView.centerYAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: stemView.centerXAnchor)
        ])
        
        UIView.animate(withDuration: 1.3, delay: 0, options: [.repeat, .autoreverse, .beginFromCurrentState], animations: {
            subtitleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        
        stemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stemViewTapped)))
        addSubview(stemView)
        return stemViewHeight
    }
    
}
