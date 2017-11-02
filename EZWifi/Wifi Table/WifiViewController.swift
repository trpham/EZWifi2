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

class WifiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LogInViewControllerDelegate, SignUpViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let codeGenerator = FCBBarCodeGenerator()
    var currentUser: CurrentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = CurrentUser()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
//        try! Auth.auth().signOut()
        if (Auth.auth().currentUser == nil) {
            showLogIn()
//            updateData()
        } else {
//            self.tableView.reloadData()
            updateData()
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        try! Auth.auth().signOut()
        
        if (Auth.auth().currentUser == nil) {
            showLogIn()
//            tableView.reloadData()
            updateData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if (Auth.auth().currentUser != nil) {
        
//            updateData()
//            tableView.reloadData()
//        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddWifiView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toAddWifiView" {
                if let dest = segue.destination as? QRGeneratorViewController {
                    dest.currentUser = self.currentUser
                }
            }
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
                    
                    print("999: \(self.currentUser.wifiList)")
                    
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentUser.username == nil {
            print("1111 wifiList for nil: \(currentUser.wifiList)")
        } else {
            print("1111 wifiList for \(currentUser.username): \(currentUser.wifiList)")
        }
        
        if currentUser.wifiList == nil {
            return 0
        }
        return currentUser.wifiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WifiTableViewCell", for: indexPath) as! WifiTableViewCell
    
        if let wifi = currentUser.getWifiFromIndexPath(indexPath: indexPath) {
  
            cell.ssid.text = wifi.ssid
            cell.password.text = wifi.password
            
            let QRSize = CGSize(width: cell.QRImageView.frame.width , height: cell.QRImageView.frame.height)
            
            if let QRImage = codeGenerator.barcode(code: wifi.hashKey, type: .qrcode, size: QRSize) {
                cell.QRImageView.image = QRImage
            }
        } 
        
        return cell
    }
    
    @IBAction func unwindToWifiPage(segue: UIStoryboardSegue) {
        updateData()
    }
    
    func showLogIn() {
        let logInViewController = storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! LogInViewController
        
        logInViewController.delegate = self
        
        logInViewController.willMove(toParentViewController: self)
        self.view.addSubview(logInViewController.view)
        self.addChildViewController(logInViewController)
        logInViewController.didMove(toParentViewController: self)
    }
    
    func showSignUp() {
        let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "signUpViewController") as! SignUpViewController
        
        signUpViewController.delegate = self
        
        signUpViewController.willMove(toParentViewController: self)
        self.view.addSubview(signUpViewController.view)
        self.addChildViewController(signUpViewController)
        signUpViewController.didMove(toParentViewController: self)
    }
    
    
    func logInSuccess(_ controller: LogInViewController, user: User) {
        currentUser = CurrentUser(user: user)
        self.updateData()
//        self.tableView.reloadData()
    }
    
    func goToSignUp(_ controller: LogInViewController) {
        showSignUp()
    }
    
    func signUpSuccess(_ controller: SignUpViewController) {
//        currentUser = CurrentUser()
        updateData()
    }
    
    func goToLogIn(_ controller: SignUpViewController) {
        showLogIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
