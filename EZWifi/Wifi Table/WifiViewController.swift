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

class WifiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LogInViewControllerDelegate {

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
        
        try! Auth.auth().signOut()
        
        if (Auth.auth().currentUser == nil) {
            showLogIn()
            updateData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if (Auth.auth().currentUser != nil) {
            tableView.reloadData()
            updateData()
//        }
    }
    
    func updateData() {
        
        if (Auth.auth().currentUser != nil) {
        
            currentUser.getWifi() { (wifis) in
                if let wifis = wifis {
                    clearWifi()
                    for wifi in wifis {
                        addWifiToList(wifi: wifi)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("1111: \(wifiList)")
        return wifiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WifiTableViewCell", for: indexPath) as! WifiTableViewCell
    
        if let wifi = currentUser.getWifiFromIndexPath(indexPath: indexPath) {
            
            print(wifi)
  
            cell.ssid.text = wifi.ssid
            cell.password.text = wifi.password
            
            let QRSize = CGSize(width: cell.QRImageView.frame.width , height: cell.QRImageView.frame.height)
            
            if let QRImage = codeGenerator.barcode(code: wifi.hashKey, type: .qrcode, size: QRSize) {
                cell.QRImageView.image = QRImage
            }
        }
        
        return cell
    }
    
    @IBAction func unwindToWifiPage(segue: UIStoryboardSegue) {}
    
    func showLogIn() {
        let logInViewController = storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! LogInViewController
        
        logInViewController.delegate = self
        
        logInViewController.willMove(toParentViewController: self)
        self.view.addSubview(logInViewController.view)
        self.addChildViewController(logInViewController)
        logInViewController.didMove(toParentViewController: self)
    }
    
    func logInSuccess(_ controller: LogInViewController) {
        updateData()
//        dismiss(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
