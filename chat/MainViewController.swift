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
    
    //MARK: Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var username = String()
    
    
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
        passwordOutlet.isHidden = true
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    //MARK: Actions
    @IBAction func goButtonPressed(_ sender: UIButton) {
        if goButtonLabel.title(for: .normal) == "Login" {
            print("trying to log in")
            
        } else {
            print("trying to register")
            guard let email = emailOutlet.text, let password = passwordOutlet.text, let name = nameOutlet.text else {
                print("Form is not valid")
                return
            }
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                let ref = FIRDatabase.database().reference(fromURL: "https://citychat-f1d4f.firebaseio.com/")
                let usersReference = ref.child("users")
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
    
    @IBAction func signRegisterButtonPressed(_ sender: Any) {
        if segmentedControllerOutlet.selectedSegmentIndex == 0 {
            print("sign in pressed")
            goButtonLabel.setTitle("Login", for: .normal)
            nameOutlet.placeholder = "Email"
            emailOutlet.placeholder = "Password"
            emailOutlet.isSecureTextEntry = true
            passwordOutlet.isHidden = true
            for x in 0...inputFieldCollections.count-1 {
                inputFieldCollections[x].text = ""
            }
        } else {
             goButtonLabel.setTitle("Register", for: .normal)
            print("register pressed")
            for x in 0...inputFieldCollections.count-1 {
                inputFieldCollections[x].text = ""
            }
            nameOutlet.placeholder = "Username"
            emailOutlet.placeholder = "Email"
            passwordOutlet.isHidden = false
            emailOutlet.isSecureTextEntry = false
        }
    }
    

   

}

