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
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    var navigationController : UINavigationController? { get }
}

class HomeView: UIView, AlertDelegate {
    private lazy var collectionController = HomeCollectionController(segueDelegate: segueDelegate)
    
    var alertMessage : String? {
        didSet { rebuild() }
    }
    private var alertBannerHeight : CGFloat? = nil
    private weak var segueDelegate : SegueDelegate!
    
    init(segueDelegate : SegueDelegate) {
        self.segueDelegate = segueDelegate
        super.init(frame: .zero)
        rebuild()
    }
    func rebuild() {
        print("Building home view with alert message of: ", alertMessage ?? "nil")
        subviews.forEach({ $0.removeFromSuperview() })
        alertBannerHeight = nil
        backgroundColor = .csbcNavBarBackground
        if let alertMessage = alertMessage, alertMessage != "" {
            let alertLabel = UILabel()
            alertLabel.numberOfLines = 0
            alertLabel.text = alertMessage
            let height = alertMessage.height(withConstrainedWidth: UIScreen.main.bounds.width, font: UIFont(name: "gotham-bold", size: 18)!)
            alertLabel.font = UIFont(name: "gotham-bold", size: 18)
            alertLabel.textColor = .white
            alertLabel.frame = CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0), width: UIScreen.main.bounds.width, height: height)
            alertLabel.textAlignment = NSTextAlignment.center
            let alertView = UIView()
            alertView.backgroundColor = .csbcAlertRed
            alertView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: safeAreaInsets.top + alertLabel.frame.height + 8)
            alertBannerHeight = alertLabel.frame.height + 13
            alertView.addSubview(alertLabel)
            addSubview(alertView)
        }
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: 109))
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.image = UIImage(named: "wordmark")
        addSubview(headerImageView)
        let barView = UIView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 119 + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: 14))
        barView.backgroundColor = .csbcYellow
        addSubview(barView)
        let collectionView = HomeScreenCollectionView(frame: CGRect(x: 0, y: (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) + 131 + (alertBannerHeight ?? 0), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - safeAreaInsets.top - 131 - (alertBannerHeight ?? 0)))
        addSubview(collectionView)
        collectionView.dataSource = collectionController
        collectionView.delegate = collectionController
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
