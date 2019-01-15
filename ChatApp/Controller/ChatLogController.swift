//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Sovorn on 9/14/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let uid = Auth.auth().currentUser?.uid
    
    private let cellId = "cellId"
    
    var user: User? {
        didSet{
            observeMessage()
        }
    }
    
    var messages = [Message]()
    
    func observeMessage(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dic = snapshot.value as? [String : AnyObject] else {
                    return
                }
                
                let message = Message(dic: dic)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    print("Collection reload")
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter message..."
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate = self
        return text
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        navigationItem.title = user?.name
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        self.collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupKeyboardObservers()
    }
    
    /*Make rotatation size to size */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.Text
        setupCell(cell: cell, message: message)
        
        if let text = message.Text {
            cell.textView.isHidden = false
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 30
        } else if message.imageUrl != nil {
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        let userID = message.fromId!
        
        if let profileUrl = self.user?.imageProfile {
            cell.profileImage.loadImageViewCacheWithUrlString(urlString: profileUrl)
        }
        if userID == uid {
            cell.profileImage.isHidden = true
            cell.textView.textColor = .white
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.profileImage.isHidden = false
            cell.textView.textColor = .black
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let imageUrl = message.imageUrl {
            cell.messageImage.loadImageViewCacheWithUrlString(urlString: imageUrl)
            cell.messageImage.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImage.isHidden = true
        }
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let sendButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Send", for: .normal)
            button.setTitleColor(UIColor(red: 0/255, green: 112/255, blue: 249/255, alpha: 1.0), for: .normal)
            button.addTarget(self, action: #selector(handleSent), for: .touchUpInside)
            
            return button
        }()
        
        let lineBreak: UIView = {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1.0)
            return line
        }()
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpaloadImage)))
        uploadImageView.isUserInteractionEnabled = true
    
        containerView.addSubview(lineBreak)
        containerView.addSubview(sendButton)
        containerView.addSubview(self.inputTextField)
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        lineBreak.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        lineBreak.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineBreak.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        lineBreak.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        
        self.inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 120).isActive = true
        self.inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return containerView
    }()
    
    @objc func handleUpaloadImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //We selected a media
            handleVideoSelected(url: videoUrl )
        } else {
            //We selected an image
            handleImageSelected(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelected(url: URL){
        let fileName = NSUUID().uuidString + ".mov "
        let storage = Storage.storage().reference().child("Media").child(fileName)
        let uploadTask = storage.putFile(from: url, metadata: nil) { (metadata, error) in
            if(error != nil){
                print("Fail to upload video:", error!)
                return
            }
            storage.downloadURL(completion: { (storageUrl, error) in
                if (error != nil){
                    print(error!)
                    return
                }
                if let videoUrl = storageUrl?.absoluteString {
                    if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                        self.uploadChatImageToFirebase(selectedImage: thumbnailImage, completion: { (imageUrl) in
                            let properties: [String: Any] = ["imageUrl": imageUrl, "width": thumbnailImage.size.width, "height": thumbnailImage.size.height, "videoUrl": videoUrl
                            ]
                            self.sendMessageWithProperties(properties: properties)
                        })
                    }
                }
            })
        }
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try assetGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    private func handleImageSelected(info: [String : AnyObject]){
        var selectedImageFromPicker: UIImage?
        if let editImage = info["UIImagePickerControllerEidtedImage"] as? UIImage {
            selectedImageFromPicker = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadChatImageToFirebase(selectedImage: selectedImage) { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            }
        }
    }
    
    private func uploadChatImageToFirebase(selectedImage: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        let storageFile = Storage.storage().reference().child("messages_image").child("\(imageName).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            storageFile.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Fail to upload image: ", error!)
                    return
                }
                
                
                storageFile.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                        completion(profileImageUrl)
                    }
                })
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        //
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
//
//    func handleKeyboardWillShow(_ notification: Notification) {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
////        containerViewBottomAnchor?.constant = -keyboardFrame!.height
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    func handleKeyboardWillHide(_ notification: Notification) {
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//
////        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.Text {
            height = estimateFrameForText(text: text).height + 18
        } else if let imageWidth = message.width?.floatValue, let imageHeight = message.height?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height:  height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }

    
    @objc func handleSent(){
        let properties: [String: Any]  = ["Text": inputTextField.text!]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        let properties: [String: Any] = ["imageUrl": imageUrl, "width": image.size.width, "height": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String : Any]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id!
        let fromId = Auth.auth().currentUser?.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        var values: [String: Any] = ["toId": toId!, "fromId": fromId!, "timeStamp": timeStamp]
        //key $0, value $1
        properties.forEach({values[$0] = $1 as? NSObject})
        
        childRef.updateChildValues(values) { (error, ref) in
            if (error != nil) {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageID = childRef.key
            userMessageRef.updateChildValues([messageID: 1])
            
            let recipientUerMessageRef = Database.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUerMessageRef.updateChildValues([messageID: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSent()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImage: UIImageView?
    
    func performZoomForImageView(imageView: UIImageView){
        self.startingImage = imageView
        self.startingImage?.isHidden = true
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomImageView = UIImageView(frame: startingFrame!)
        zoomImageView.image = imageView.image
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keyWindow = UIApplication.shared.keyWindow {
            self.blackBackground = UIView(frame: keyWindow.frame)
            self.blackBackground?.backgroundColor = .black
            self.blackBackground?.alpha = 0
            
            keyWindow.addSubview(self.blackBackground!)
            keyWindow.addSubview(zoomImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackground?.alpha = 1
                self.inputContainerView.alpha = 0
                
                //h2 / w2 = h1 / w1 so h2 = h1 / w1 * w2
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomImage = tapGesture.view {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomImage.frame = self.startingFrame!
                self.blackBackground?.alpha = 0
                self.inputContainerView.alpha = 1
            }) { (completed: Bool) in
                zoomImage.removeFromSuperview()
                self.startingImage?.isHidden = false
            }
            
        }
    }
}
