//
//  WifiCollectionViewCell.swift
//  EZWifi
//
//  Created by nathan on 11/6/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit

class WifiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var ssid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ssid.text = ""
        QRImageView.image = UIImage()
    }
}
