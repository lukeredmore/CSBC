//
//  ModalMenuViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/29/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ModalMenuViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    var superMenuView: UIView!
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ModalMenuViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    func setupMenuView(_ menuView: UIView) {
        superMenuView = menuView
        superMenuView.layer.cornerRadius = 5
        superMenuView.layer.masksToBounds = true
        view.addSubview(superMenuView)
    }
    
    func configure() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
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
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            superMenuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.superMenuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.superMenuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
