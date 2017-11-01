//
//  CurrentUser.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CurrentUser {
    var username: String!
    var id: String!
    var wifiList: [Wifi]!
    
    let dbRef = Database.database().reference()
    
    init() {
        let currentUser = Auth.auth().currentUser
        username = currentUser?.displayName
        id = currentUser?.uid
        wifiList = []
    }
    
    func clearWifi() {
        wifiList = []
    }
    
    func addWifiToList(wifi: Wifi) {
        wifiList.append(wifi)
    }
    
    func getWifiFromIndexPath(indexPath: IndexPath) -> Wifi? {
        return wifiList[indexPath.row]
    }
    
    func addWifi(ssid: String, password: String, hash: String) {
        let wifi = [
            firUsernameNode: username,
            firSSIDNode: ssid,
            firPasswordNode: password,
            firHashNode: hash
        ]
        
        let childUpdate = ["/\(id!)/\(ssid)": wifi]
        dbRef.updateChildValues(childUpdate)
    }
    
    func getWifi(completion: @escaping ([Wifi]?) -> Void) {
    
        var wifiArray: [Wifi] = []
        
        if let id = id {
            
            dbRef.child(id).observeSingleEvent(of: .value, with: { snapshot -> Void in
                if snapshot.exists() {
                    if let wifiMap = snapshot.value as? [String:AnyObject] {
                        for wifiHash in wifiMap.keys {
                            if let wifiDetails = wifiMap[wifiHash] as? [String: String] {
                                let wifi = Wifi(username: self.username, ssid: wifiDetails[firSSIDNode]!, password: wifiDetails[firPasswordNode]!, hashKey: wifiDetails[firHashNode]!)
                                wifiArray.append(wifi)
                            }
                        }
                        completion(wifiArray)
                    }
                } else {
                    completion(nil)
                }
            })
        }
    }
}
