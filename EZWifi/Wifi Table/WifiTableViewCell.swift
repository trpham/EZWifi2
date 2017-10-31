//
//  WifiTableViewCell.swift
//  EZWifi
//
//  Created by nathan on 10/28/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit

class WifiTableViewCell: UITableViewCell {

    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var ssid: UILabel!
    @IBOutlet weak var password: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
