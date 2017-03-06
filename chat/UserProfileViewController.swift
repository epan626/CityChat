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
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField?.delegate = self
        usernameTextField?.delegate = self
        updatePasswordTextField?.delegate = self
        confirmPasswordTextField?.delegate = self
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
        guard let updatedEmail = emailTextField?.text else{
            return
        }
        let result = isValidEmail(emailString: updatedEmail)
        if result != true{
            let alert = UIAlertController(title: "Invalid Form", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        guard let newUsername = usernameTextField.text else{
            let alert = UIAlertController(title: "Invalid Form", message: "Please enter a valid username.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if let loggedUser = FIRAuth.auth()?.currentUser?.uid{
            let ref = FIRDatabase.database().reference().child("users")
        }
        
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
