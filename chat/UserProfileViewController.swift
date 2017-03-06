//
//  UserProfileViewController.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import Firebase

class UserProfileViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var updatePasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    var user: User?
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField?.delegate = self
        usernameTextField?.delegate = self
        updatePasswordTextField?.delegate = self
        confirmPasswordTextField?.delegate = self
        emailTextField?.text = user?.email
        usernameTextField?.text = user?.username
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        var newPassword: String?
        guard let updatedEmail = emailTextField?.text else{
            let alert = UIAlertController(title: "Invalid Form", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let result = isValidEmail(emailString: updatedEmail)
        if result != true{
            let alert = UIAlertController(title: "Invalid Form", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let newUsername = usernameTextField?.text else{
            let alert = UIAlertController(title: "Invalid Form", message: "Please enter a valid username.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if updatePasswordTextField.text != "" && confirmPasswordTextField.text != "" && updatePasswordTextField.text == confirmPasswordTextField.text{
            newPassword = updatePasswordTextField.text
        }
        
        FIRAuth.auth()?.currentUser?.updateEmail(updatedEmail, completion: { (error) in
            if error != nil{
                print("There was an error while updating the email: \(error)")
                return
            }
            if let password = newPassword{
                FIRAuth.auth()?.currentUser?.updatePassword(password, completion: { (error) in
                    if error != nil{
                        print("There was an error while updating the password: \(error)")
                    }
                    if let currentUser = FIRAuth.auth()?.currentUser?.uid{
                        let ref = FIRDatabase.database().reference().child("users").child(currentUser)
                        let newUserValues = ["email": updatedEmail, "username": newUsername]
                        ref.updateChildValues(newUserValues)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            } else{
                if let currentUser = FIRAuth.auth()?.currentUser?.uid{
                    let ref = FIRDatabase.database().reference().child("users").child(currentUser)
                    let newUserValues = ["email": updatedEmail, "username": newUsername]
                    ref.updateChildValues(newUserValues)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        })
        
    }
    
    @IBAction func handleCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func isValidEmail(emailString:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: emailString)
    }
}
