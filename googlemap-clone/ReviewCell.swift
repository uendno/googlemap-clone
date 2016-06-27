//
//  ReviewCell.swift
//  googlemap-clone
//
//  Created by Tran Viet Thang on 6/24/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var rateView: CosmosView!
}
