//
//  SignUpViewController.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import FirebaseAuth

//protocol SignUpViewControllerDelegate {
//    func signUpSuccess(_ controller: SignUpViewController)
//}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerificationTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
//    var delegate: SignUpViewControllerDelegate?
    
    var userEmail = ""
    var userPassword = ""
    var userVerifiedPassWord = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordVerificationTextField.delegate = self
        
        self.signUpButton.isEnabled = false
        self.signUpButton.backgroundColor = UIColor.lightGray
        
        self.emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordVerificationTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let verifiedPassword = passwordVerificationTextField.text else { return }
        
        if email == "" || password == "" || verifiedPassword == "" {
            // Never get here
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = email
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            print("Signup success")
//                            self.delegate?.signUpSuccess(self)
                            let customUser:[String: User] = ["customUser": user!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignUpSuccess"), object: self, userInfo: customUser)
                            self.performSegue(withIdentifier: "unwindSignUpToWifiView", sender: nil)
                        }
                        else {
                            self.errorLabel.text = error?.localizedDescription
                        }
                    }
                } else if password != verifiedPassword {
                    self.errorLabel.text = "Oops! The two passwords do not match."
                } else {
                    self.errorLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindSignUpToLogInView", sender: nil)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
         self.performSegue(withIdentifier: "unwindSignUpToWifiView", sender: nil)
    }
    
    // To enable/diable Sign Up button
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty,
            let passwordVerification = self.passwordVerificationTextField.text, !passwordVerification.isEmpty
            else
        {
            self.signUpButton.isEnabled = false
            self.signUpButton.backgroundColor = UIColor.lightGray
            return
        }
        self.signUpButton.isEnabled = true
        self.signUpButton.backgroundColor = UIColor(0x007AFF)
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
        } else if textField == self.passwordTextField {
            if textField.text != nil {
                self.userPassword = textField.text!
            }
        } else if textField == self.passwordVerificationTextField {
            if textField.text != nil {
                self.userVerifiedPassWord = textField.text!
            }
        }
    }

}
