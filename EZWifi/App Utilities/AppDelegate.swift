//
//  AppDelegate.swift
//  EZWifi
//
//  Created by nathan on 10/14/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import Firebase
import HxColor
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = UIColor(0x007AFF)
//        navigationBarAppearace.barTintColor = UIColor(0x007AFF)
        navigationBarAppearace.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "NunitoSans-Bold", size: 20)!,
            NSAttributedStringKey.foregroundColor:UIColor(0x007AFF)]
        
//        navigationBarAppearace.tintColor = UIColor(0xffffff)
//        navigationBarAppearace.barTintColor = UIColor(0x007AFF)
//        navigationBarAppearace.titleTextAttributes = [
//            NSAttributedStringKey.font: UIFont(name: "NunitoSans-Bold", size: 20)!,
//            NSAttributedStringKey.foregroundColor:UIColor.white]
        
        navigationBarAppearace.isTranslucent = false
        
        let newFont = UIFont(name: "NunitoSans-Bold", size: 16.0)!
        let color = UIColor(0x007AFF)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: newFont], for: .normal)
        
//        let newFont = UIFont(name: "NunitoSans-Bold", size: 16.0)!
//        let color = UIColor.white
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: newFont], for: .normal)

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor(0x007AFF)
//        UITabBar.appearance().layer.borderWidth = 20.0
//        UITabBar.appearance().clipsToBounds = true
        
//        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .blue
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Failed to log into Google: ", error)
            return
        }
        print("Successfully logged into Google: ", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            guard let uid = user?.uid else { return }
            print("Sucessfully logged into Firebase with Google ", uid)
            
            if let user = user {
                let GoogleUser:[String: User] = ["googleUser": user]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoogleLoggedIn"), object: self, userInfo: GoogleUser)}
            })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return googleDidHandle || facebookDidHandle
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

