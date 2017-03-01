//
//  UserListViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit
import Firebase

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    //MARK: Data
    var users = [User]()
    var loginTime = Date()
    //MARK: Outlet
    @IBOutlet weak var userListTableView: UITableView!
    
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Fetch
    func fetchAllUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                self.userListTableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    //MARK: TableViews
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: "userCell") as! userCell
        
//        let user = users[indexPath.row]
//        let ref = FIRDatabase.database().reference().child("users").child(user.username!)
//        ref.observe(.value, with: { (snapshot) in
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                print(snapshot.value)
//                if let integer = Int(loginTime)! {
//                    let timeInterval = NSNumber(value: integer)
//                    let seconds = timeInterval.doubleValue
//                    let timeStampDate = NSDate(timeIntervalSince1970: seconds)
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "hh:mm:ss a"
//                    let date = dateFormatter.string(from: timeStampDate as Date)
//                }
//            }
//        }, withCancel: nil)
        
        cell.usernameOutlet.text = "hey"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let directMessageController = self.storyboard?.instantiateViewController(withIdentifier: "DirectMessageController")
        navigationController?.pushViewController(directMessageController!, animated: true)
    }

}
