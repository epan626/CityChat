//
//  DirectMessageViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class DirectMessageViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var messages = [Message]()
    var user: User?
    var toUser: User?
    let textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "chatCell")

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        observeMessages()
    }
    
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = toUser?.id else{
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                print(dictionary)
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
//
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
    }
    
    func sendMessage(){
        if self.textField.text != ""{
            let ref = FIRDatabase.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toId = self.toUser?.id
            let fromId = self.user?.id

            let timestamp = String(Int(NSDate().timeIntervalSince1970))
            let message = self.textField.text!
            let values: [String: AnyObject] = ["receiver": toId as AnyObject, "sender": fromId as AnyObject, "timestamp": timestamp as AnyObject, "text": message as AnyObject]
            
            childRef.updateChildValues(values) { (error, ref) in
                if error != nil{
                    print(error!)
                    return
                }
                self.textField.text = nil
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
                let toOtherUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                toOtherUserMessagesRef.updateChildValues([messageId: 1])
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func dismissKeyboard(){
        inputContainerView.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        if message.sender == self.user?.id{
            cell.bubbleView.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else{
            cell.bubbleView.backgroundColor = UIColor.init(red: 144/255, green: 238/255, blue: 144/255, alpha: 0.3)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.placeholder = "Enter message..."
        self.textField.delegate = self
        containerView.addSubview(self.textField)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 20
        containerView.addSubview(sendButton)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.backgroundColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)

        //button constraints
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        
        //input field constraints
        self.textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        self.textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        self.textField.placeholder = "Enter a message..."
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha:1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        //separator constraints
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
}
