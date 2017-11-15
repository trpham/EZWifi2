
//
//  Strings.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import Foundation
import FirebaseDatabase

let segueLogInToWifiPage = "logInToWifiPage"
let segueSignUpToWifiPage = "signUpToWifiPage"
let segueLogIntoSignUp = "logInToSignUp"

let firUsernameNode = "username"
let firSSIDNode = "ssid"
let firPasswordNode = "password"
let firHashNode = "hash"

let connectedRef = Database.database().reference(withPath: ".info/connected")
