//
//  ViewController.swift
//  chat
//
//  Created by Eric Pan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var segmentedControllerOutlet: UISegmentedControl!
    @IBOutlet weak var goButtonLabel: UIButton!
    @IBOutlet var inputFieldCollections: [UITextField]!
    var city: Dictionary<String, Any>?
    var errorText: String?
    
    //MARK: Views
    override func viewDidLoad() {
        nameOutlet.placeholder = "Email"
        emailOutlet.placeholder = "Password"
        emailOutlet.isSecureTextEntry = true
        passwordOutlet.isHidden = true
        passwordOutlet.isEnabled = false
        nameOutlet.delegate = self
        emailOutlet.delegate = self
        passwordOutlet.delegate = self
        super.viewDidLoad()
        print(self.city)
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
                    let alert = UIAlertController(title: "Invalid", message: "Email or password is incorrect!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code){
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.errorText = "Please enter a valid email."
                        case .errorCodeEmailAlreadyInUse:
                            self.errorText = "Email is already in use."
                        case .errorCodeWeakPassword:
                            self.errorText = "Password must be at least 6 characters."
                        default:
                            self.errorText = "All fields are required for registrations."
                        }
                    }
                    
                    let alert = UIAlertController(title: "Invalid", message: self.errorText, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let uid = user?.uid else {
                    return
                }
                let ref = FIRDatabase.database().reference()
                let usersReference = ref.child("users").child(uid)
                let values = ["username": name, "email": email, "loggedOn": "true"] as [String : Any]
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err!)
                        return
                    } else {
                        print(ref)
                    }
                    self.performSegue(withIdentifier: "cityChatSegue", sender: user!)
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
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cityChatSegue" {
            if let tabVC = segue.destination as? UITabBarController {
                tabVC.selectedIndex = 1
                if let chatroomController = tabVC.viewControllers?[1] as? allChatController{
                    print("I'M SETTING THE CHATROOM CONTROLLER CITY")
                    chatroomController.city = self.city
                }
            }
        }

    }
    
    //MARK: Unwind Segue

    @IBAction func unwindToMain(segue: UIStoryboardSegue){}
    
    //MARK: Dismiss
    func dismissKeyboard(){
        nameOutlet.resignFirstResponder()
        emailOutlet.resignFirstResponder()
        passwordOutlet.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameOutlet.resignFirstResponder()
        emailOutlet.resignFirstResponder()
        passwordOutlet.resignFirstResponder()
        return true
    }
   
}

