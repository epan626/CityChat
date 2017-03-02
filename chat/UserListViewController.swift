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
    var user: User?
    var loginTime = String(Int(NSDate().timeIntervalSince1970))
    var loggedOnUsers = [User]()
    
    //MARK: Outlet
    @IBOutlet weak var userListTableView: UITableView!
    
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAllUsers()
    }
    
    //MARK: Fetch
    func fetchAllUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
//                self.userListTableView.reloadData()
                if user.loggedOn == "true" {
                    if user.id != FIRAuth.auth()?.currentUser?.uid {
                        self.loggedOnUsers.append(user)
                        self.userListTableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    
    //MARK: TableViews
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(users.count)
        return loggedOnUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: "userCell") as! userCell
        let user = loggedOnUsers[indexPath.row]
        cell.usernameOutlet.text = user.username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toUser = loggedOnUsers[indexPath.row]
        print(toUser.id)
        print(self.user?.id)
        let directMessageController = self.storyboard?.instantiateViewController(withIdentifier: "DirectMessageController") as? DirectMessageViewController
        directMessageController?.user = self.user
        directMessageController?.toUser = toUser
        navigationController?.pushViewController(directMessageController!, animated: true)
    }

}
