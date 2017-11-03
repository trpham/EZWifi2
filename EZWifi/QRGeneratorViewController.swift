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
import HxColor

protocol QRGeneratorViewControllerDelegate {
    func needUpdateData(_ controller: QRGeneratorViewController)
}

class QRGeneratorViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var SSIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var generateQRButton: UIButton!
    
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var QRCodeImageView: UIImageView!
    
    @IBOutlet weak var wifiInputView: UIView!
    @IBOutlet weak var QRView: UIView!
    @IBOutlet weak var downloadView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var delegate: QRGeneratorViewControllerDelegate?
    
    // SSID and Password of the wifi input fields
    var ssid = ""
    var password = ""
    
    // Current wifi if this is in wifi view mode
    var wifi: Wifi!
    var currentUser: CurrentUser!
    
    // Hide/Show the Wifi input view by activate/deactivate this constraint
    var wifiInputViewZeroHeight: NSLayoutConstraint!
    
    // Check if this is in wifi view mode
    var isViewMode: Bool!
    
    let codeGenerator = FCBBarCodeGenerator()
    
    func enable(button: UIButton, status: Bool) {
        button.isEnabled = status
        if (status) {
            button.backgroundColor = UIColor(0x0000FF)
        } else {
            button.backgroundColor = UIColor.lightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SSIDTextField.delegate = self
        self.passwordTextField.delegate = self
        self.scrollView.delegate = self
        
        self.enable(button: self.generateQRButton, status: false)
        
        self.wifiInputViewZeroHeight = NSLayoutConstraint(item: self.wifiInputView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
        
        if (isViewMode) {
            self.QRView.isHidden = false
            self.scrollView.isScrollEnabled = true
            NSLayoutConstraint.activate([wifiInputViewZeroHeight])
            
            self.SSIDTextField.text = wifi.ssid
            self.passwordTextField.text = wifi.password
            
            self.ssidLabel.text = wifi.ssid
            self.passwordLabel.text = wifi.password
            
            let QRSize = CGSize(width: 500, height: 500)
            let QRImage = codeGenerator.barcode(code: wifi.hashKey, type: .qrcode, size: QRSize)
            self.QRCodeImageView.image = QRImage
        }
        else {
            self.QRView.isHidden = true
            self.scrollView.isScrollEnabled = false
            NSLayoutConstraint.deactivate([wifiInputViewZeroHeight])
        }
        
        // Set dismiss keyboard on tapping
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(scrollViewTap)
        
        // To Enable/Disable Generate QR Button
        self.SSIDTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
    }
    
    // Set dismiss keyboard on tapping
    @objc func scrollViewTapped() {
        self.view.endEditing(true)
    }
    
    // Set dismiss keyboard on scrolling
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.view.endEditing(true)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        guard
            let ssid = self.SSIDTextField.text, !ssid.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty
            else
        {
            self.generateQRButton.isEnabled = false
            self.generateQRButton.backgroundColor = UIColor.lightGray
            return
        }
        self.generateQRButton.isEnabled = true
        self.generateQRButton.backgroundColor = UIColor(0x0000FF)
    }
    

    @IBAction func generateQRCode(_ sender: Any) {
        
        guard let ssid = SSIDTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        self.ssidLabel.text = ssid
        self.passwordLabel.text = password

        self.QRView.isHidden = false
        self.scrollView.isScrollEnabled = true
        NSLayoutConstraint.activate([self.wifiInputViewZeroHeight])

        let wifiHash = encryptWifi(text: ssid + "|||" + password + "|||" + self.currentUser.id)
        let QRSize = CGSize(width: 500, height: 500)
        let QRImage = codeGenerator.barcode(code: wifiHash, type: .qrcode, size: QRSize)
        self.QRCodeImageView.image = QRImage
    
        if (isViewMode) {
            self.currentUser.updateWifi(wifi: self.wifi, ssid: ssid, password: password, hash: wifiHash)
        }
        else {
            self.currentUser.addWifi(ssid: ssid, password: password, hash: wifiHash)
        }
        
        self.delegate?.needUpdateData(self)

        self.passwordTextField.resignFirstResponder()
        self.SSIDTextField.resignFirstResponder()
    }
    
    func copy(image: UIImage) -> UIImage {
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let copiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copiedImage!
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        NSLayoutConstraint.deactivate([self.wifiInputViewZeroHeight])
    }
    
    // Download QR code image using UIActivityViewController
    @IBAction func downloadImage(_ sender: UIButton) {
        
        if let QRImage = self.QRCodeImageView.image {
            let copiedImage = self.copy(image: QRImage)
            let activityViewController = UIActivityViewController(activityItems: [copiedImage], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func downloadImageWithInstructionPDF(_ sender: UIButton) {
        
    }
    
    // Hide keyboard when user touches outsite
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard on pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.SSIDTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
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

