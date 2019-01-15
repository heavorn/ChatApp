//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Sovorn on 9/13/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "celled"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe( .childAdded, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.name = dic["name"] as? String
                user.email = dic["email"] as? String
                user.imageProfile = dic["profileImageUrl"] as? String
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //                print(snapshot)
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
//        cell.detailTextLabel?.text = user.email
        
        if let profileUrl = user.imageProfile {
            
            cell.profileImageView.loadImageViewCacheWithUrlString(urlString: profileUrl)
            //            let myUrl = URL(string: profileUrl)
            //            let requestUrl = URLRequest(url: myUrl!)
            //
            //            URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            //                if error != nil {
            //                    print(error!)
            //                    return
            //                }
            //                DispatchQueue.main.async {
            //                    cell.profileImageView.image = UIImage(data: data!)
            ////                    cell.imageView?.image = UIImage(data: data!)
            //
            //                }
            //            }.resume()
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var messageController: ViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatControllerForUser(user: user) 
        }
    }
    
}



