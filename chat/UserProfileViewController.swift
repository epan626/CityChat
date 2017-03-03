//
//  UserProfileViewController.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import Firebase

class UserProfileViewController: UIViewController{
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.purple
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))

    }
    
    func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
}
