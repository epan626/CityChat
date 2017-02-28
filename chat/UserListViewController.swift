//
//  UserListViewController.swift
//  chat
//
//  Created by Charles Paisan on 2/27/17.
//  Copyright © 2017 Eric Pan. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: "userCell")
        cell?.backgroundColor = UIColor.blue
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let directMessageController = self.storyboard?.instantiateViewController(withIdentifier: "DirectMessageController")
        navigationController?.pushViewController(directMessageController!, animated: true)
    }

}
