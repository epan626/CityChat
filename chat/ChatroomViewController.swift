//
//  ChatroomViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class ChatroomViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldBar: UITextField!
    
    //MARK: Views
    override func viewDidLoad() {
        textFieldBar.delegate = self
        super.viewDidLoad()
    }
    
    //MARK: Actions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            print("logout pressed")
            self.performSegue(withIdentifier: "unwindToMain", sender: self)
        } catch let logoutError {
            print(logoutError)
        }
        
    }

    @IBAction func swipeFromRightEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        UIView.animate(withDuration: 2.0, animations: {
            self.sideMenuLeadingConstraint.constant = 235
        })
    }
    @IBAction func swipeLeftGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.sideMenuLeadingConstraint.constant = 375
        }
        
    }
    
    //MARK: Dismiss
    func dismissKeyboard(){
        textFieldBar.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldBar.resignFirstResponder()
        return true
    }

}
