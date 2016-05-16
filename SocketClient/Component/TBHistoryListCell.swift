//
//  TBHistoryListCell.swift
//  SocketClient
//
//  Created by 郑云 on 15/7/1.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

import UIKit

class TBHistoryListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.numberOfLines = 0
    }

    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
