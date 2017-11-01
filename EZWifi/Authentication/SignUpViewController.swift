//
//  SignUpViewController.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SignUpViewControllerDelegate {
    func signUpSuccess(_ controller: SignUpViewController)
    func goToLogIn(_ controller: SignUpViewController)
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordVerificationTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var delegate: SignUpViewControllerDelegate?
    
    var userEmail = ""
    var userName = ""
    var userPassword = ""
    var userVerifiedPassWord = ""

    @IBAction func signUpPressed(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        guard let verifiedPassword = passwordVerificationTextField.text else { return }
        
        if email == "" || password == "" || name == "" || verifiedPassword == "" {
//            let alertController = UIAlertController(title: "Form Error.", message: "Please fill in form completely.", preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            print("Signup success")
                            self.delegate?.signUpSuccess(self)
                            self.view.removeFromSuperview()
//                            let alertController = UIAlertController(title: "Sign Up Sucessfully", message: "", preferredStyle: .alert)
//                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                            alertController.addAction(defaultAction)
//                            self.present(alertController, animated: true, completion: {
//                                self.performSegue(withIdentifier: segueSignUpToWifiPage, sender: self)
//                            })
                        }
                        else {
                            self.errorLabel.text = error?.localizedDescription
//                            let alertController = UIAlertController(title: "Sign Up Error", message: error?.localizedDescription, preferredStyle: .alert)
//                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                            alertController.addAction(defaultAction)
//                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    // TO DO:
                    // The user account has been successfully created. Now, update the user's name in
                    // firebase and then perform a segue to the main page. Note, again, that this segue
                    // already exists somewhere, just do some simple debugging to find the identifier.
                    // Also, notify the user that the account has been successfully created before
                    // performing the segue.
                    
                } else if password != verifiedPassword {
                    self.errorLabel.text = "Oops! The two passwords do not match."
//
//                    let alertController = UIAlertController(title: "Verification Error.", message: "The two passwords do not match.", preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.passwordVerificationTextField.textColor = UIColor.red
//                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.errorLabel.text = error?.localizedDescription
//                    let alertController = UIAlertController(title: "Sign Up Error", message: error?.localizedDescription, preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        self.delegate?.goToLogIn(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordVerificationTextField.delegate = self
        
        self.signUpButton.isEnabled = false
        self.signUpButton.backgroundColor = UIColor.lightGray
        
        self.nameTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordVerificationTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        
        // Do any additional setup after loading the view.
//        self.nameTextField.becomeFirstResponder()
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let name = self.nameTextField.text, !name.isEmpty,
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
        self.signUpButton.backgroundColor = UIColor(0x0000FF)
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
        } else if textField == self.nameTextField {
            if textField.text != nil {
                self.userName = textField.text!
            }
        } else if textField == self.passwordVerificationTextField {
            if textField.text != nil {
                self.userVerifiedPassWord = textField.text!
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
