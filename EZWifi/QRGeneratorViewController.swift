//
//  QRGeneratorViewController.swift
//  EZWifi
//
//  Created by nathan on 10/15/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftHash
import FirebaseAuth

class QRGeneratorViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var SSIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    
    var ssid = ""
    var password = ""
    
    let codeGenerator = FCBBarCodeGenerator()
    let currentUser = CurrentUser()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SSIDTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func generateQRCode(_ sender: Any) {
        
        guard let ssid = SSIDTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if ssid == "" || password == "" {
            let alertController = UIAlertController(title: "Wifi Error", message: "Please enter an SSID and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            let wifiHash = encryptWifi(text: ssid + "|||" + password + "|||" + currentUser.id)
            
            let QRSize = CGSize(width: QRCodeImageView.frame.width , height: QRCodeImageView.frame.height)
            
            if let QRImage = codeGenerator.barcode(code: wifiHash, type: .qrcode, size: QRSize) {
                QRCodeImageView.image = QRImage
            }
            
            currentUser.addWifi(ssid: ssid, password: password, hash: wifiHash)
            
            passwordTextField.resignFirstResponder()
            SSIDTextField.resignFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.SSIDTextField.becomeFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.SSIDTextField {
            if textField.text != nil {
                self.ssid = textField.text!
            }
        } else if textField == self.passwordTextField {
            if textField.text != nil {
                self.password = textField.text!
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

