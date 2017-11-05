//
//  Wifi.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import Foundation
import UIKit
import RNCryptor

let masterKey = "jkjfdoajifsji"

//var currentUser = CurrentUser()

class Wifi {
    let username: String
    let ssid: String
    let password: String
    let hashKey: String
    
    init(username: String, ssid: String, password: String, hashKey: String) {
        self.username = username
        self.ssid = ssid
        self.password = password
        self.hashKey = hashKey
    }
}

func encryptWifi(text: String) -> String {
    let encodedData = String(text).data(using: .utf8)!
    let encryptedText = RNCryptor.encrypt(data: encodedData, withPassword: masterKey)
    return encryptedText.base64EncodedString()
}

func decryptWifi(text: String) -> String {
    let decodedData = NSData(base64Encoded: text, options: .ignoreUnknownCharacters)
    do {
        let originalData = try RNCryptor.decrypt(data: decodedData! as Data, withPassword: masterKey)
        return String(data: originalData, encoding: .utf8)!
    } catch {
        return "Data Error"
    }
}
