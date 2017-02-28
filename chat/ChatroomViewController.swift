//
//  ChatroomViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class ChatroomViewController: UIViewController {

    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            self.performSegue(withIdentifier: "unwindToMain", sender: self)
        } catch let logoutError {
            print(logoutError)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
}
