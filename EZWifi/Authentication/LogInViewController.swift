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

protocol LogInViewControllerDelegate {
    func logInSuccess(_ controller: LogInViewController)
    func goToSignUp(_ controller: LogInViewController)
}

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorBoxHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var delegate: LogInViewControllerDelegate?
    
    var userEmail = ""
    var userPassword = ""
    
    @IBAction func logInPressed(_ sender: UIButton) {
        guard let emailText = emailTextField.text else { return }
        guard let passwordText = passwordTextField.text else { return }
        
        if emailText == "" || passwordText == "" {
            
//            self.errorLabel.text = "Please enter an email and password."
            
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields
//            let alertController = UIAlertController(title: "Log In Error", message: "Please enter an email and password.", preferredStyle: .alert)
//
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().signIn(withEmail: userEmail, password: passwordText) { (user, error) in
                if error == nil {
                    print("Login success")
                    self.delegate?.logInSuccess(self)
                    self.view.removeFromSuperview()
                }
                else {
                    print("error: invalid user")
                    
                    
//                    print(error?.localizedDescription)
//
//                    self.errorLabel.sizeToFit()
                    self.errorLabel.text = error?.localizedDescription
//                    self.errorLabel.textAlignment = .center
//                    self.errorBoxHeightConstrant.constant = self.errorLabel.frame.height
                    
//
//                    let alertController = UIAlertController(title: "Log In Error", message:
//                        error?.localizedDescription, preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.delegate?.goToSignUp(self)
        self.view.removeFromSuperview()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.bottomHeight.constant = self.tabBarController?.tabBar.frame.height ?? 49.0
        print(bottomHeight.constant)
        self.view.layoutIfNeeded()
        
        self.logInButton.isEnabled = false
        self.logInButton.backgroundColor = UIColor.lightGray
        
        self.emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfoDict = notification.userInfo, let keyboardSize = (userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomHeight.constant = keyboardSize.height
            print(self.bottomHeight.constant)
//            print(self.bottomHeight.constant)
            self.view.layoutIfNeeded()
        }
    }

    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.8) {
            self.bottomHeight.constant = self.tabBarController?.tabBar.frame.height ?? 49.0
            print(self.bottomHeight.constant)
//            print(self.bottomHeight.constant)
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
//        self.emailTextField.becomeFirstResponder()
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
