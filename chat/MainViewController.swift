//
//  ViewController.swift
//  chat
//
//  Created by Eric Pan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var segmentedControllerOutlet: UISegmentedControl!
    @IBOutlet weak var goButtonLabel: UIButton!
    @IBOutlet var inputFieldCollections: [UITextField]!
    
    
    //MARK: Views
    override func viewDidLoad() {
        nameOutlet.placeholder = "Email"
        emailOutlet.placeholder = "Password"
        emailOutlet.isSecureTextEntry = true
        passwordOutlet.isHidden = true
        passwordOutlet.isEnabled = false
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Actions
    
    //sign in / register button
    @IBAction func goButtonPressed(_ sender: UIButton) {

        //logs in
        if goButtonLabel.title(for: .normal) == "Sign in" {
            guard let email = nameOutlet.text, let password = emailOutlet.text else {
                print("Form is not valid")
                return
            }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    return
                } else {
                    self.performSegue(withIdentifier: "cityChatSegue", sender: user!)
                }
            })
            
        //registers
        } else {
            guard let email = emailOutlet.text, let password = passwordOutlet.text, let name = nameOutlet.text else {
                print("Form is not valid")
                return
            }
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    print(error!)
                    return
                }
                guard let uid = user?.uid else {
                    return
                }
                let ref = FIRDatabase.database().reference(fromURL: "https://citychat-f1d4f.firebaseio.com/")
                let usersReference = ref.child("users").child(uid)
                let values = ["name": name, "email": email]
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err!)
                        return
                    }
                })
            })
        }
    }
    
    //swap between sign in / register views
    @IBAction func signRegisterButtonPressed(_ sender: Any) {
        if segmentedControllerOutlet.selectedSegmentIndex == 0 {
            goButtonLabel.setTitle("Sign in", for: .normal)
            nameOutlet.placeholder = "Email"
            emailOutlet.placeholder = "Password" // on purpose
            emailOutlet.isSecureTextEntry = true
            passwordOutlet.isHidden = true
            passwordOutlet.isEnabled = false
            for x in 0...inputFieldCollections.count-1 {
                inputFieldCollections[x].text = ""
            }
        } else {
             goButtonLabel.setTitle("Register", for: .normal)
            for x in 0...inputFieldCollections.count-1 {
                inputFieldCollections[x].text = ""
            }
            nameOutlet.placeholder = "Username"
            emailOutlet.placeholder = "Email"
            passwordOutlet.isHidden = false
            passwordOutlet.isEnabled = true
            emailOutlet.isSecureTextEntry = false
        }
    }
    

    //MARK: Unwind Segue

    @IBAction func unwindToMain(segue: UIStoryboardSegue){}
   

}

