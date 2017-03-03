//
//  TransitionDismissalAnimator.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class TransitionDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let destinationController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView as UIView
        
        destinationController.view.alpha = 0.0
        containerView.addSubview(destinationController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            destinationController.view.alpha = 1.0
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            UIApplication.shared.keyWindow?.addSubview(destinationController.view)
        }
    }
}
