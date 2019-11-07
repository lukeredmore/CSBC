//
//  ModalMenuViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/29/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

/// Common methods for halfscreen modal view controllers
class ModalMenuViewController: CSBCViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    var isPresenting = false
    let menuView : UIView!
    let menuHeight : CGFloat!
    
    
    init(menu : UIView, height : CGFloat) {
        self.menuView = menu
        self.menuHeight = height
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        
        menuView.layer.cornerRadius = 10
        menuView.layer.masksToBounds = true
        view.addSubview(menuView)
        view.addConstraints([
            menuView.heightAnchor.constraint(equalToConstant: menuHeight),
            menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ModalMenuViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    private func configure() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        passBackData()
        dismiss(animated: true, completion: nil)
    }
    
    func passBackData() { }
    
    
    //MARK: Delegate Methods
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting.toggle()
        
        if isPresenting {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }) { transitionContext.completeTransition($0) }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }) { transitionContext.completeTransition($0) }
        }
    }
    
    
    
}
