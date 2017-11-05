//
//  CustomTabBarViewController.swift
//  EZWifi
//
//  Created by nathan on 11/4/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {
    
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Swift3.0, Swift 4.0 compatible
    // Pre-iPhone X default tab bar height: 49pt
    // iPhone X default tab bar height: 83pt
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let newTabBarHeight = defaultTabBarHeight + 8.0
        
        var newFrame = tabBar.frame
        newFrame.size.height = newTabBarHeight
        newFrame.origin.y = view.frame.size.height - newTabBarHeight
        
        tabBar.frame = newFrame
    }

}
