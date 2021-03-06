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
    var offlineDmUsers = [User]()
    var flag = true
    
    
    //MARK: Outlet
    @IBOutlet weak var userListTableView: UITableView!
    
    @IBOutlet weak var offlineDmUserListTable: UITableView!
    
    //MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAllUsers()
    }
    
    //MARK: Fetch
    func fetchAllUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let removeID = snapshot.key
            print("HERE===================================================")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                if user.loggedOn == "true" {
                    if user.id != FIRAuth.auth()?.currentUser?.uid {
                        self.loggedOnUsers.append(user)
                        self.userListTableView.reloadData()
                    }
                }
                
            }
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("users").observe(.childChanged, with: { (snapshot5) in
            if let dictionary5 = snapshot5.value as? [String : AnyObject] {
                let user = User()
                user.id = snapshot5.key
                user.setValuesForKeys(dictionary5)
                if user.loggedOn == "true" {
                    if user.id != FIRAuth.auth()?.currentUser?.uid {
                        self.loggedOnUsers.append(user)
                        self.userListTableView.reloadData()
                    }
                }

                if user.loggedOn == "false" && self.loggedOnUsers.contains(where: {$0.id == snapshot5.key}) {
                    print(snapshot5.key)
                    self.loggedOnUsers.forEach({ (user) in
                        print(user.id)
                    })
                    
                    let filter = self.loggedOnUsers.filter({ $0.id == user.id})
                    let logoutUser = filter[0]
//                    self.loggedOnUsers.remove(at: self.loggedOnUsers.index(of: logoutUser)!)
                    if let removeIDIndex = self.loggedOnUsers.index(of: logoutUser) {
                        print("hey")
                        self.loggedOnUsers.remove(at: removeIDIndex)
                        self.userListTableView.reloadData()
                    }
            }
            }
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("user-messages").child((FIRAuth.auth()?.currentUser?.uid)!).observe(.childAdded, with: { (snapshot2) in
                    let user2 = User()
                    user2.id = snapshot2.key
                    FIRDatabase.database().reference().child("users").child(user2.id!).observe(.value, with: { (snapshot3) in
                        if let dictionary2 = snapshot3.value as? [String: AnyObject] {
                            let user3 = User()
                            user3.id = snapshot3.key
                            user3.setValuesForKeys(dictionary2)
                            if self.offlineDmUsers.contains(where: {$0.id == snapshot3.key}) {
                                return
                            }
                            self.offlineDmUsers.append(user3)
                            let when = DispatchTime.now() + 1.0
                            DispatchQueue.main.asyncAfter(deadline: when) {
                            self.offlineDmUserListTable.reloadData()
                            }
                        }
                    }, withCancel: nil)
                }, withCancel: nil)
                

        
    }

    
    //MARK: TableViews
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        if tableView == self.userListTableView {
            count = loggedOnUsers.count
        }
        if tableView == self.offlineDmUserListTable {
            count = offlineDmUsers.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell1: userCell?
        var cell2: offlineUserCell?
        var check = true
        if tableView == self.userListTableView {
            cell1 = userListTableView.dequeueReusableCell(withIdentifier: "userCell") as? userCell
            let user = loggedOnUsers[indexPath.row]
            cell1?.usernameOutlet.text = user.username
        }
        else if tableView == self.offlineDmUserListTable {
            cell2 = offlineDmUserListTable.dequeueReusableCell(withIdentifier: "offlineUserCell") as? offlineUserCell
            let user = offlineDmUsers[indexPath.row]
            if user.loggedOn == "true" {
                cell2?.directMsgStatus.image = UIImage(named: "Online")
            }
            cell2?.offlineUsername.text = user.username
            check = false
        }
        return check == true ? cell1! : cell2!
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.userListTableView {
            let toUser = loggedOnUsers[indexPath.row]
            let directMessageController = self.storyboard?.instantiateViewController(withIdentifier: "DirectMessageController") as? DirectMessageViewController
            directMessageController?.user = self.user
            directMessageController?.toUser = toUser
            navigationController?.pushViewController(directMessageController!, animated: true)
        }
        else if tableView == self.offlineDmUserListTable {
            let toUser = offlineDmUsers[indexPath.row]
            let directMessageController = self.storyboard?.instantiateViewController(withIdentifier: "DirectMessageController") as? DirectMessageViewController
            directMessageController?.user = self.user
            directMessageController?.toUser = toUser
            navigationController?.pushViewController(directMessageController!, animated: true)
        }
       
    }

}
