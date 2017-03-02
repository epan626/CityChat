//
//  AllChatMessageCell.swift
//  chat
//
//  Created by Charles Paisan on 3/2/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import AVFoundation

class AllChatMessageCell: UICollectionViewCell{
    
    var message: Message?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let detailTextLabel: UITextField = {
        let detailLabel = UITextField()
        detailLabel.textColor = UIColor.white
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.layer.masksToBounds = true
        return detailLabel
    }()
    
    
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(detailTextLabel)
        
        //bubbleView constraints
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        bubbleViewRightAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //textView constraints
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: detailTextLabel.bottomAnchor, constant: 4).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 8).isActive = true
//        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        detailTextLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8).isActive = true
//        detailTextLabel.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -8).isActive = true
        detailTextLabel.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        detailTextLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        detailTextLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
