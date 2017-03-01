//
//  ChatroomViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase


class allChatController: UIViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: Data
    var containerViewBottomAnchor: NSLayoutConstraint?
    var users = [User]()
    var messages = [Message]()
    var city: Dictionary<String, Any>?
    var messageDictionary = [String: Message]()
    var loginTime = Date()
    var cityChat: String?
    
    //Outlets
    @IBOutlet weak var sideMenuViewLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var msgTextField: UITextField!
    
    
    //MARK: View
    override func viewDidLoad() {
        print(loginTime)
        msgTextField.delegate = self
        super.viewDidLoad()
        setupKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let userCity = self.city?["city"] as? String{
            if userCity == "Burbank"{
                cityChat = "burbankMessages"
            } else if userCity == "Santa Monica"{
                cityChat = "santaMonicaMessages"
            } else if userCity == "San Francisco"{
                cityChat = "sanFranciscoMessages"
            } else if userCity == "San Diego"{
                cityChat = "sanDiegoMessages"
            } else{
                cityChat = "noCityNearby"
            }
        }
        fetchAllUsers()
        observeMessages()
    }
    
    //MARK: Helper
    func observeMessages(){
        let ref = FIRDatabase.database().reference().child(cityChat!)
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                if let integer = Int((message.timestamp)!) {
                    let timeInterval = NSNumber(value: integer)
                    let seconds = timeInterval.doubleValue
                    let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                    if self.loginTime < timeStampDate as Date {
                         self.messages.append(message)
                    }
                }
                self.messages.sort(by: { (message1, message2) -> Bool in
                    return Int(message1.timestamp!)! < Int(message2.timestamp!)!
                })
                self.chatCollectionView.reloadData()
            }
        },  withCancel: nil)
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    //MARK: Fetch
    
    func fetchAllUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                print(dictionary)
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                self.chatCollectionView.reloadData()
            }
        }, withCancel: nil)
    }

    
    
    //MARK: Actions
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        handleLogoutAndSegue(completion: {
            self.performSegue(withIdentifier: "unwindToMain", sender: self)
        })
    }
    
    
    func handleLogoutAndSegue(completion: @escaping () -> ()){
//        let ref = FIRDatabase.database().reference().child("users")
//        let user = FIRAuth.auth()!.currentUser!.uid.
        
        do{
            try FIRAuth.auth()?.signOut()
        } catch {
            let alert = UIAlertController(title: "Invalid", message: "There was an issue logging out. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        completion()
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let ref = FIRDatabase.database().reference().child("burbankMessages")
        let childRef = ref.childByAutoId()
        let sender = FIRAuth.auth()!.currentUser!.uid
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        let values = ["text": msgTextField.text!, "sender": sender, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values)
        
    }
    @IBAction func swipeFromRightEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        UIView.animate(withDuration: 2.0, animations: {
            self.sideMenuViewLeadingContraint.constant = 250
        })
    }
    @IBAction func swipeLeftGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.sideMenuViewLeadingContraint.constant = 375
        }
    }
    
    //MARK: CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! chatCell
        let message = messages[indexPath.row]
        
        if let user = message.sender {
            let ref = FIRDatabase.database().reference().child("users").child(user)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    if let integer = Int((message.timestamp)!) {
                        let timeInterval = NSNumber(value: integer)
                        let seconds = timeInterval.doubleValue
                        let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm:ss a"
                        let date = dateFormatter.string(from: timeStampDate as Date)
                            if message.sender == FIRAuth.auth()?.currentUser?.uid {
                                cell.usernameOutlet.text  = date
                                cell.messageOutlet.textAlignment = .right
                                cell.usernameOutlet.textAlignment = .right
                            } else {
                                cell.messageOutlet.textAlignment = .left
                                cell.usernameOutlet.textAlignment = .left
                                cell.usernameOutlet.text = (dictionary["username"] as? String)! + " - " + date
                            }
                    }
                }
            }, withCancel: nil)
        }
        cell.messageOutlet.text = message.text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
    
    //MARK: Keyboard
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        containerViewBottomAnchor?.constant = -5
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: Dismiss
    func dismissKeyboard(){
        msgTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        msgTextField.resignFirstResponder()
        return true
    }

}


//    lazy var inputContainerView: UIView = {
//        let containerView = UIView()
//        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
//        containerView.backgroundColor = UIColor.yellow
//
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = "Enter message..."
//        textField.delegate = self
//        containerView.addSubview(textField)
//
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(sendButton)
//        sendButton.backgroundColor = UIColor.red
//
//        //button constraints
//        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//
//        containerView.addSubview(textField)
//
//        //input field constraints
//        textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
//        textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
//        textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        textField.placeholder = "Enter a message..."
//
//        let separatorLineView = UIView()
//        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha:1)
//        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(separatorLineView)
//
//        //separator constraints
//        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
//        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//
//        return containerView
//    }()
