//
//  LoginController.swift
//  ChatApp
//
//  Created by Sovorn on 9/13/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var inputsContainerViewHeighAnchor: NSLayoutConstraint?
    var nameTextFieldHeighAnchor: NSLayoutConstraint?
    var emailTextFieldHeighAnchor: NSLayoutConstraint?
    var passwordTextFieldHeighAnchor: NSLayoutConstraint?
    var separateHeightAnchor: NSLayoutConstraint?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleLogin(){
        guard let email = emailText.text, let password = passwordText.text else {
            print("Form is not valid.")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (User, error) in
            
            if error != nil {
                print(error!)
                return
            }
            //successfully login
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    let nameText: UITextField = {
        let name = UITextField()
        name.placeholder = "Name"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let emailText: UITextField = {
        let name = UITextField()
        name.placeholder = "Email"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let passwordText: UITextField = {
        let name = UITextField()
        name.placeholder = "Password"
        name.translatesAutoresizingMaskIntoConstraints = false
        name.isSecureTextEntry = true
        return name
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let loginRegisterSegmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        inputsContainerViewHeighAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeighAnchor?.isActive = false
        nameTextFieldHeighAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeighAnchor?.isActive = true
        
        separateHeightAnchor?.isActive = false
        separateHeightAnchor = separatorView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        separateHeightAnchor?.isActive = true
        
        emailTextFieldHeighAnchor?.isActive = false
        emailTextFieldHeighAnchor = emailText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 1/3)
        emailTextFieldHeighAnchor?.isActive = true
        
        passwordTextFieldHeighAnchor?.isActive = false
        passwordTextFieldHeighAnchor = passwordText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0.5 : 1/3)
        passwordTextFieldHeighAnchor?.isActive = true
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImage)
        view.addSubview(loginRegisterSegmentedControl)
        setupInputContainer()
        
        
    }
    
    func setupInputContainer() {
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeighAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeighAnchor?.isActive = true
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
        
        inputsContainerView.addSubview(nameText)
        inputsContainerView.addSubview(separatorView)
        inputsContainerView.addSubview(emailText)
        inputsContainerView.addSubview(separatorView2)
        inputsContainerView.addSubview(passwordText)
        
        
        nameText.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameText.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameText.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeighAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeighAnchor?.isActive = true
        
        separatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: nameText.bottomAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        separateHeightAnchor = separatorView.heightAnchor.constraint(equalToConstant: 1)
        separateHeightAnchor?.isActive = true
        
        emailText.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailText.topAnchor.constraint(equalTo: nameText.bottomAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeighAnchor = emailText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeighAnchor?.isActive = true
        
        separatorView2.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        separatorView2.topAnchor.constraint(equalTo: emailText.bottomAnchor).isActive = true
        separatorView2.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        separatorView2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordText.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordText.topAnchor.constraint(equalTo: emailText.bottomAnchor).isActive = true
        passwordText.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeighAnchor = passwordText.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeighAnchor?.isActive = true
        
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
