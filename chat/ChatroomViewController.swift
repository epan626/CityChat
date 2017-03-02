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
    var user: User?
    var flag = true
    var inputContainerViewBottomAnchor: NSLayoutConstraint?
    
    //Outlets
    @IBOutlet weak var sideMenuViewLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var inputContainerView: UIView!
    
    //MARK: View
    override func viewDidLoad() {
        msgTextField.delegate = self
        super.viewDidLoad()
        setupKeyboardObservers()

        print("WE ARE IN THE ALL CHAT CONTROLLER")
        chatCollectionView?.register(AllChatMessageCell.self, forCellWithReuseIdentifier: "allChatCell")
        inputContainerViewBottomAnchor = self.inputContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
        inputContainerViewBottomAnchor?.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        if let userCity = self.city?["city"] as? String{
            if userCity == "Burbank"{
                self.cityChat = "burbankMessages"
            } else if userCity == "Santa Monica"{
                self.cityChat = "santaMonicaMessages"
            } else if userCity == "San Francisco"{
                self.cityChat = "sanFranciscoMessages"
            } else if userCity == "San Diego"{
                self.cityChat = "sanDiegoMessages"
            } else{
                self.cityChat = "noCityNearby"
            }
        }
        if flag == true{
            fetchAllUsers()
            observeMessages()
            self.flag = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Helper
    func observeMessages(){
        let ref = FIRDatabase.database().reference().child(self.cityChat!)
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
        guard let current = FIRAuth.auth()?.currentUser?.uid else{
            completion()
            return
        }
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(current).updateChildValues(["loggedOn": "false"])
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
        let ref = FIRDatabase.database().reference().child(cityChat!)
        let childRef = ref.childByAutoId()
        let sender = FIRAuth.auth()!.currentUser!.uid
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        guard let username = self.user?.username else{
            return
        }
        let values = ["text": msgTextField.text!, "sender": sender, "timestamp": timestamp, "username": username] as [String : Any]
        childRef.updateChildValues(values)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        chatCollectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allChatCell", for: indexPath) as! AllChatMessageCell
        let message = messages[indexPath.row]
        
        let sender = message.sender
        if let integer = Int((message.timestamp)!) {
            let timeInterval = NSNumber(value: integer)
            let seconds = timeInterval.doubleValue
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            let date = dateFormatter.string(from: timeStampDate as Date)
            if sender == self.user?.id {
                cell.detailTextLabel.text = date
                cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
                cell.textView.textColor = UIColor.white
                cell.detailTextLabel.textColor = UIColor.white
                cell.bubbleViewRightAnchor?.isActive = true
                cell.bubbleViewLeftAnchor?.isActive = false
                cell.bubbleWidthAnchor?.constant = self.estimateFrameForText(text: message.text!).width + 42
                
            } else{
                cell.detailTextLabel.text = message.username! + " - " + date
                cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
                cell.textView.textColor = UIColor.black
                cell.detailTextLabel.textColor = UIColor.black
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
                cell.bubbleWidthAnchor?.constant = self.estimateFrameForText(text: message.text!).width + 80
            }
        }
        
        cell.textView.text = message.text
        return cell
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
    
    //MARK: Keyboard
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            chatCollectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        inputContainerViewBottomAnchor?.constant = -keyboardFrame!.height
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: 0.5, animations: {
            self.handleKeyboardDidShow()
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        inputContainerViewBottomAnchor?.constant = -60
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: 0.5, animations: {
            self.handleKeyboardDidShow()
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
