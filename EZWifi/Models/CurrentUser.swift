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
    
    init(user: User) {
        username = user.displayName
        id = user.uid
        wifiList = []
    }
    
    init(username: String, id: String) {
        self.username = username
        self.id = id
        wifiList = []
    }
    
    
    func clearWifi() {
        wifiList = []
    }
    
    func addWifiToList(wifi: Wifi) {
        wifiList.append(wifi)
    }
    
    func removeWifiFromList(wifi: Wifi) {
        for i in (0..<self.wifiList.count) {
            if wifiList[i].hashKey == wifi.hashKey {
                wifiList.remove(at: i)
                break
            }
        }
    }
    
    func getWifiFromIndexPath(indexPath: IndexPath) -> Wifi? {
        if let wifi = wifiList?[indexPath.row] {
            return wifi
        } else {
            return nil
        }
    }
    
    func updateWifi(wifi: Wifi, ssid: String, password: String, hash:String) {
        
        self.removeWifiFromCloud(wifi: wifi)
        
        self.addWifiToCloud(ssid: ssid, password: password, hash: hash)
        
        // Update local wifiList
        let newWifi = Wifi(username: username, ssid: ssid, password: password, hashKey: hash)

        for i in (0..<self.wifiList.count) {
            if wifiList[i].hashKey == wifi.hashKey {
                wifiList[i] = newWifi
                break
            }
        }
    }
    
    func removeWifiFromCloud(wifi: Wifi) {
        dbRef.child(id).child(wifi.ssid).removeValue()
    }
    
    func addWifiToCloud(ssid: String, password: String, hash: String) {
        let wifiNode = [
            firUsernameNode: username,
            firSSIDNode: ssid,
            firPasswordNode: password,
            firHashNode: hash
        ]
        
        let childUpdate = ["/\(id!)/\(ssid)": wifiNode]
        dbRef.updateChildValues(childUpdate)
    }
    
    func addWifi(ssid: String, password: String, hash: String) {
       
        self.addWifiToCloud(ssid: ssid, password: password, hash: hash)
        
        let wifi = Wifi(username: username, ssid: ssid, password: password, hashKey: hash)
        self.addWifiToList(wifi: wifi)
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
                    completion(wifiArray)
                }
            })
        }
    }
}
