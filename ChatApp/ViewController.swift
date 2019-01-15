//
//  ViewController.swift
//  ChatApp
//
//  Created by Sovorn on 9/13/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//
import UIKit
import Firebase

class ViewController: UITableViewController {
    
    let cellId = "cellId"
    
    let loginController = LoginController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(hanldeNewMessage))
        tableView.allowsMultipleSelectionDuringEditing = true

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
            let rootRef = Database.database().reference().child("user-messages")
            rootRef.child(uid).child(chatPartnerId).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.deleteMessateWithMessageID(messageID: messageID)
            }, withCancel: nil)
            rootRef.child(chatPartnerId).child(uid).removeValue()
            rootRef.child(uid).child(chatPartnerId).removeValue()
            self.attemptReloadTable()
            
            //if we want to delete only in dicMessage, if we want to keep all messages in database
//            rootRef.child(uid).child(chatParnerId).removeValue { (error, ref) in
//                if error != nil {
//                    print("Failed to delete message:", error!)
//                    return
//                }
//                self.dicMessage.removeValue(forKey: chatParnerId)
//                self.attemptReloadTable()
////                self.messages.remove(at: indexPath.row)
////                self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
        }
        
    }
    
    var messages = [Message]()
    var dicMessage = [String: Message]()
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID  = snapshot.key
            ref.child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithMessageID(messageID: messageID)
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.dicMessage.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageID(messageID: String){
        let messagesRef = Database.database().reference().child("messages").child(messageID)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: AnyObject] {
                let message = Message(dic: dic)
                if let partnerID = message.chatPartnerId() {
                    self.dicMessage[partnerID] = message
                }
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
    
    private func deleteMessateWithMessageID(messageID: String){
        let messagesRef = Database.database().reference().child("messages").child(messageID)
        messagesRef.removeValue()
    }
    
    private func attemptReloadTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReload(){
        self.messages = Array(self.dicMessage.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timeStamp! > message2.timeStamp!
        })
        DispatchQueue.main.async {
            print("we reload")
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        checkIfUserIsLoggedIn()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatId = message.chatPartnerId()
        
        let ref = Database.database().reference().child("users").child(chatId!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dic = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.id = chatId
                user.name = dic["name"] as? String
                user.email = dic["email"] as? String
                user.imageProfile = dic["profileImageUrl"] as? String
                self.showChatControllerForUser(user: user)
                
            }
        }, withCancel: nil)
    }
    
    @objc func hanldeNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController , animated: true)
        
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dic = snapshot.value as? [String: AnyObject] {
                    self.setNavigationBarWithImage(dic: dic)
                }
            }, withCancel: nil)
        }
    }
    
    func setNavigationBarWithImage(dic: Dictionary<String, AnyObject>){
        
        messages.removeAll()
        dicMessage.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileUrl = dic["profileImageUrl"] as? String {
            profileImageView.loadImageViewCacheWithUrlString(urlString: profileUrl)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = dic["name"] as? String
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    @objc func handleLogout(){
        
        do{
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError )
        }
        let loginController = LoginController()
        present(loginController, animated: true)
    }
    
    func showChatControllerForUser(user: User){
        let flowLayout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: flowLayout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}


