//
//  chatCell.swift
//  chat
//
//  Created by Eric Pan on 2/28/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class chatCell: UICollectionViewCell {
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var timeStampOutlet: UILabel!
    @IBOutlet weak var messageOutlet: UILabel!
    
    @IBOutlet weak var usernameLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timestampLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var timestampTrailingConstraint: NSLayoutConstraint!
}
