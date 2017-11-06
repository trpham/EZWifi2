//
//  LogInViewController.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import HxColor
import FBSDKLoginKit
import GoogleSignIn

protocol LogInViewControllerDelegate {
    func logInSuccess(_ controller: LogInViewController, user: User)
    func goToSignUp(_ controller: LogInViewController)
}

class LogInViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var FBLogInButton: FBSDKLoginButton!
    @IBOutlet weak var CustomFBLogInButton: UIButton!
    @IBOutlet weak var customGoogleButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorBoxHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var delegate: LogInViewControllerDelegate?
    
    var userEmail = ""
    var userPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.bottomHeight.constant = self.tabBarController?.tabBar.frame.height ?? 49.0
        print(bottomHeight.constant)
        self.view.layoutIfNeeded()
        
        self.logInButton.isEnabled = false
        self.logInButton.backgroundColor = UIColor.lightGray
        self.FBLogInButton.delegate = self
        self.FBLogInButton.readPermissions = ["email", "public_profile"]
        
        //        let googleButton = GIDSignInButton()
        //        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        //        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook!")
    }
    
    @IBAction func handleFBLogin(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) {
            (result, err) in
            if err != nil {
                print(err as Any)
                return
            }
            self.showEmailAddress()
        }
    }
    @IBAction func handleGoogleSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func handleGoogleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            print("Sccessfully logged in with our user: ", user ?? "")
            
        })
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil) {
                print(result ?? "")
            } else {
                print("Failed to start grapth request:", error as Any)
                return
            }
        })
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        showEmailAddress()
        print("Successfully logged in with facebook")
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        guard let emailText = emailTextField.text else { return }
        guard let passwordText = passwordTextField.text else { return }
        
        if emailText == "" || passwordText == "" {
            // Not possible since LogInButton will be disabled
        }
        else {
            Auth.auth().signIn(withEmail: userEmail, password: passwordText) { (user, error) in
                if error == nil {
                    print("Login success")
                    self.delegate?.logInSuccess(self, user: user!)
                    self.view.removeFromSuperview()
                }
                else {
                    print("error: invalid user")
                    self.errorLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.delegate?.goToSignUp(self)
        self.view.removeFromSuperview()
    }
   

    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfoDict = notification.userInfo, let keyboardSize = (userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomHeight.constant = keyboardSize.height
            print(self.bottomHeight.constant)
            self.view.layoutIfNeeded()
        }
    }

    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.8) {
            self.bottomHeight.constant = self.tabBarController?.tabBar.frame.height ?? 49.0
            print(self.bottomHeight.constant)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty
            else
        {
            self.logInButton.isEnabled = false
            self.logInButton.backgroundColor = UIColor.lightGray
            return
        }
        self.logInButton.isEnabled = true
        self.logInButton.backgroundColor = UIColor(0x0000FF)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Hide keyboard when user touches outsite
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard on pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.errorLabel.text = ""
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            if textField.text != nil {
                self.userEmail = textField.text!
            }
        } else {
            if textField.text != nil {
                self.userPassword = textField.text!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
