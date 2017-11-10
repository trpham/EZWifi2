//
//  WifiViewController.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UPCarouselFlowLayout

class WifiViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    LogInViewControllerDelegate, QRGeneratorViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyListOverlayView: UIView!
    
    @IBOutlet weak var signInAndSignOutButton: UIBarButtonItem!
    
    var wifi: Wifi!
    var currentUser: CurrentUser!
    let codeGenerator = FCBBarCodeGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = CurrentUser()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let layout = UPCarouselFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: self.view.bounds.width)
        self.collectionView.collectionViewLayout = layout
        
        // Use notification to receive signal from Sign Up because there is no direct segue to it.
        NotificationCenter.default.addObserver(self, selector: #selector(self.signUpSuccess(_:)), name: NSNotification.Name(rawValue: "SignUpSuccess"), object: nil)
        
        let tapOnCell = UITapGestureRecognizer(target: self, action: #selector(didTapItemAtIndexPath))
        tapOnCell.numberOfTapsRequired = 1
        self.collectionView.addGestureRecognizer(tapOnCell)

        if (Auth.auth().currentUser == nil) {
            // Show the overlay page
            signInAndSignOutButton.title = "Sign In"
            self.emptyListOverlayView.isHidden = false
        } else {
            signInAndSignOutButton.title = "Sign Out"
            updateData()
        }
    }
    
    // Unwind segue
    @IBAction func unwindToWifiPage(segue: UIStoryboardSegue) {}
    
    // Nofification from Sign Up View
    @objc func signUpSuccess(_ notification: NSNotification) {
        if let user = notification.userInfo?["customUser"] as? User {
            currentUser = CurrentUser(user: user)
            updateData()
            signInAndSignOutButton.title = "Sign Out"
        }
    }
    
    // Update currentUser and reloadData on signing out.
    @IBAction func signInOutPressed(_ sender: UIBarButtonItem) {
        if signInAndSignOutButton.title == "Sign In" {
            if (Auth.auth().currentUser == nil) {
                performSegue(withIdentifier: "segueToLogInView", sender: nil)
                updateData()
            }
        }
        else if signInAndSignOutButton.title == "Sign Out" {
            try! Auth.auth().signOut()
            
            if (Auth.auth().currentUser == nil) {
                currentUser = CurrentUser()
                self.collectionView.reloadData()
                self.emptyListOverlayView.isHidden = (self.currentUser.wifiList.count != 0)
                signInAndSignOutButton.title = "Sign In"
            }
        }
    }
    
//    @IBAction func signOutPressed(_ sender: Any) {
//        try! Auth.auth().signOut()
//        if (Auth.auth().currentUser == nil) {
//            currentUser = CurrentUser()
//            self.collectionView.reloadData()
//            self.emptyListOverlayView.isHidden = (self.currentUser.wifiList.count != 0)
//        }
//    }
    
    // Either present Log In or Add Wifi page.
    @IBAction func addButtonTapped(_ sender: Any) {
        if (Auth.auth().currentUser == nil) {
            performSegue(withIdentifier: "segueToLogInView", sender: nil)
            updateData()
        }
        else {
            self.wifi = nil
            performSegue(withIdentifier: "toAddWifiView", sender: nil)
        }
    }
    
    func updateData() {
        if (Auth.auth().currentUser != nil) {
            currentUser.clearWifi()
            currentUser.getWifi() { (wifis) in
                if let wifis = wifis {
                    for wifi in wifis {
                        self.currentUser.addWifiToList(wifi: wifi)
                    }
                }
                self.collectionView.reloadData()
                self.emptyListOverlayView.isHidden = (self.currentUser.wifiList.count != 0)

            }
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentUser.wifiList == nil {
            return 0
        }
        return currentUser.wifiList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wifiCollectionCell", for: indexPath) as! WifiCollectionViewCell
        
        if let wifi = currentUser.getWifiFromIndexPath(indexPath: indexPath) {
            cell.ssid.text = wifi.ssid
            let QRSize = CGSize(width: cell.QRImageView.frame.width , height: cell.QRImageView.frame.height)
            if let QRImage = codeGenerator.barcode(code: wifi.hashKey, type: .qrcode, size: QRSize) {
                cell.QRImageView.image = QRImage
            }
        }
        
        return cell
    }
    
    // Replace collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    @objc func didTapItemAtIndexPath(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            self.wifi = currentUser.getWifiFromIndexPath(indexPath: indexPath)
            performSegue(withIdentifier: "toAddWifiView", sender: nil)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.wifi = currentUser.getWifiFromIndexPath(indexPath: indexPath)
//        performSegue(withIdentifier: "toAddWifiView", sender: nil)
//    }
    
    // MARK: QRGeneratorViewControllerDelegate
    
    func needUpdateData(_ controller: QRGeneratorViewController) {
        self.collectionView.reloadData()
        self.emptyListOverlayView.isHidden = (self.currentUser.wifiList.count != 0)
    }
    
    // MARK: LogInViewControllerDelegate
    
    func logInSuccess(_ controller: LogInViewController, user: User) {
        currentUser = CurrentUser(user: user)
        self.updateData()
        signInAndSignOutButton.title = "Sign Out"
    }

    // SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toAddWifiView" {
                if let dest = segue.destination as? QRGeneratorViewController {
                    dest.delegate = self
                    if wifi != nil {
                        dest.isViewMode = true
                        dest.wifi = wifi
                    } else {
                        dest.isViewMode = false
                    }
                    dest.currentUser = self.currentUser
                }
            }
            else if identifier == "segueToLogInView" {
                if let dest = segue.destination as? LogInViewController {
                    dest.delegate = self
                }
            }
        }
    }

}
