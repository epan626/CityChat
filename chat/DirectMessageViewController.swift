//
//  DirectMessageViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class DirectMessageViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var messageCollectionView: UICollectionView!
    var messageContainerViewBottomAnchor: NSLayoutConstraint?
    @IBOutlet weak var directMessageTextField: UITextField!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    
    var messages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        directMessageTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        setupKeyboardObservers()
        
        messageContainerViewBottomAnchor = messageContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -55)
        messageContainerViewBottomAnchor?.isActive = true
        
        messageCollectionView?.keyboardDismissMode = .interactive
    }
    
    func dismissKeyboard(){
        directMessageTextField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func handleKeyboardDidShow(){
//        if messages.count > 0{
//            let indexPath = IndexPath(row: messages.count - 1, section: 0)
//            messageCollectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
//        }
        print("keyboard showed up-------")
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        messageContainerViewBottomAnchor?.constant = -keyboardFrame!.height
        messageContainerViewBottomAnchor?.isActive = true
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
        messageContainerViewBottomAnchor?.constant = -55
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messageCollectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath)
        cell.backgroundColor = UIColor.blue
        return cell
    }
}
