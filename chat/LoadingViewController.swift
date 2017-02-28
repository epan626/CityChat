//
//  LoadingViewController.swift
//  chat
//
//  Created by Eric Pan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class LoadingViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var progressView: UIProgressView!
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // progress bar animation
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.progressView.setProgress(0.0, animated: true)
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
             self.checkIfUserIsLoggedIn()
        }
       
    }
    
    //MARK: Helpers
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                self.performSegue(withIdentifier: "cityChatSegue", sender: snapshot)
            }, withCancel: nil)
            
        } else {
            let when = DispatchTime.now() + 1.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                let mvc = self.storyboard?.instantiateViewController(withIdentifier: "logRegController")
                self.present(mvc!, animated: true, completion: nil)
            }
            
        }
    }
}
