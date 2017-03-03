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
    let viewTransitionDelegate = TransitionDelegate()
    
    //Outlets
    @IBOutlet weak var parentSideMenuView: UIView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var containerViewOutlet: UIView!
    @IBOutlet weak var sideMenuViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenu: UIView!
    
    //MARK: View
    override func viewDidLoad() {
        msgTextField.delegate = self
        super.viewDidLoad()
        print("WE ARE IN THE ALL CHAT CONTROLLER")
        chatCollectionView?.register(AllChatMessageCell.self, forCellWithReuseIdentifier: "allChatCell")
        inputContainerViewBottomAnchor = self.inputContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
        inputContainerViewBottomAnchor?.isActive = true
        sideMenu.layer.cornerRadius = 20
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
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Helper
    func observeMessages(){
        if let city = self.cityChat{
            let ref = FIRDatabase.database().reference().child(city)
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
        } else{
            return
        }
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
        self.handleLogoutAndSegue(completion: {
            self.performSegue(withIdentifier: "logoutUserSegue", sender: self)
        })
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        let profileViewController = UserProfileViewController()
        profileViewController.transitioningDelegate = viewTransitionDelegate
        profileViewController.modalPresentationStyle = .custom
        present(profileViewController, animated: true, completion: nil)
    }
    
    func handleLogoutAndSegue(completion: @escaping () -> ()){
        if let current = FIRAuth.auth()?.currentUser?.uid {
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
        return
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if self.msgTextField.text != "" {
            guard let cityChatroom = self.cityChat as String? else{
                return
            }
            let ref = FIRDatabase.database().reference().child(cityChatroom)
            let childRef = ref.childByAutoId()
            guard let sender = FIRAuth.auth()?.currentUser?.uid else{
                return
            }
            let timestamp = String(Int(NSDate().timeIntervalSince1970))
            guard let username = self.user?.username else{
                return
            }
            let values = ["text": msgTextField.text!, "sender": sender, "timestamp": timestamp, "username": username] as [String : Any]
            childRef.updateChildValues(values)
            if messages.count > 0{
                let indexPath = IndexPath(row: messages.count - 1, section: 0)
                chatCollectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
            self.msgTextField.text = nil
        }
    }
    
    @IBAction func swipeFromRightEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerViewOutlet.sendSubview(toBack: self.chatCollectionView)
            self.containerViewOutlet.bringSubview(toFront: self.parentSideMenuView)
            self.sideMenuViewTrailingConstraint.constant = -20
            self.parentSideMenuView.alpha = 1.0
             self.chatCollectionView.alpha = 0.3
            self.chatCollectionView.backgroundColor = UIColor.init(red: 144/255, green: 238/255, blue: 144/255, alpha: 0.3)
            self.parentSideMenuView.backgroundColor = UIColor.init(red: 144/255, green: 238/255, blue: 144/255, alpha: 0.0)
            self.sideMenuView.alpha = 1.0
            self.sideMenuView.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)
            self.parentSideMenuView.widthAnchor.constraint(equalToConstant: 0)
        })
    }
    @IBAction func swipeLeftGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.containerViewOutlet.sendSubview(toBack: self.parentSideMenuView)
            self.containerViewOutlet.bringSubview(toFront: self.chatCollectionView)
             self.sideMenuViewTrailingConstraint.constant = -122
            self.parentSideMenuView.alpha = 0
            self.chatCollectionView.alpha = 1
             self.parentSideMenuView.widthAnchor.constraint(equalToConstant: 375)
            self.chatCollectionView.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
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
                cell.bubbleView.backgroundColor = UIColor.init(red: 144/255, green: 238/255, blue: 144/255, alpha: 1.0)
                cell.textView.textColor = UIColor.white
                cell.detailTextLabel.textColor = UIColor.white
                cell.bubbleViewRightAnchor?.isActive = true
                cell.bubbleViewLeftAnchor?.isActive = false
                cell.bubbleWidthAnchor?.constant = self.estimateFrameForText(text: message.text!, date: cell.detailTextLabel.text!).width + 16
                
            } else{
                cell.detailTextLabel.text = message.username! + " - " + date
                cell.bubbleView.backgroundColor = UIColor.init(red: 144/255, green: 238/255, blue: 144/255, alpha: 0.3)
                cell.textView.textColor = UIColor.black
                cell.detailTextLabel.textColor = UIColor.black
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
                cell.bubbleWidthAnchor?.constant = self.estimateFrameForText(text: message.text!, date: cell.detailTextLabel.text!).width + 16
            }
        }
        
        cell.textView.text = message.text
        return cell
    }
    
    private func estimateFrameForText(text: String, date: String) -> CGRect{
        let boxWidth = text.characters.count > date.characters.count ? text : date
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: boxWidth).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
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
            chatCollectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        inputContainerViewBottomAnchor?.constant = -keyboardFrame!.height
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.handleKeyboardDidShow()
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        inputContainerViewBottomAnchor?.constant = -60
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
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
