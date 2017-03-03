//
//  TransitionDelegate.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionDismissalAnimator()
    }
    
}
