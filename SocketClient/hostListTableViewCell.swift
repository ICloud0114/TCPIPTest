//
//  hostListTableViewCell.swift
//  SocketClient
//
//  Created by 郑云 on 15/6/1.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit

class hostListTableViewCell: UITableViewCell {

    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    var cellid: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func updateHostListWith(ip:String, port:String)
    {
        ipLabel.text = ip
        portLabel.text = port
    }

}
