//
//  CircleDisplayTransitionAnimator.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class CircleDisplayTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate{
    
    var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! LoadingViewController
        let destinationController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let destinationView = destinationController.view
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(destinationView!)
        
        let buttonFrame = fromViewController.continueButton.frame
        let endFrame = CGRect(x: -(destinationView?.frame)!.width/2, y: -(destinationView?.frame)!.height/2, width: (destinationView?.frame)!.width*2, height: (destinationView?.frame)!.height*2)
        
        let maskPath = UIBezierPath(ovalIn: buttonFrame)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = (destinationView?.frame)!
        maskLayer.path = maskPath.cgPath
        destinationController.view.layer.mask = maskLayer
        
        let bigCirclePath = UIBezierPath(ovalIn: endFrame)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.delegate = self
        pathAnimation.fromValue = maskPath.cgPath
        pathAnimation.toValue = bigCirclePath
        pathAnimation.duration = transitionDuration(using: transitionContext)
        maskLayer.path = bigCirclePath.cgPath
        maskLayer.add(pathAnimation, forKey: "pathAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let transitionContext = self.transitionContext{
            transitionContext.completeTransition(true)
        }
    }
    
}
