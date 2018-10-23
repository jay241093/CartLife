//
//  ServiceProviderCell.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/19/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import FloatRatingView
class ServiceProviderCell: UITableViewCell {

    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var contentview: UIView!
    
    @IBOutlet weak var lbladdress: UILabel!
    
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var rating: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
