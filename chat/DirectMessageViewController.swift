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
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
    }
    
    func sendMessage(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = self.toUser?.id
        let fromId = self.user?.id
        let timestamp = String(Int(NSDate().timeIntervalSince1970))
        let message = self.textField.text!
        let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "message": message as AnyObject]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            
            self.textField.text = nil
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath)
        let message = messages[indexPath.row]
        if message.sender == self.user?.id{
            
        } else{
            
        }
        cell.backgroundColor = UIColor.blue
        return cell
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.yellow
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.placeholder = "Enter message..."
        self.textField.delegate = self
        containerView.addSubview(self.textField)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        sendButton.backgroundColor = UIColor.red
        
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
