//
//  RestaurantTableViewCell.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var nameLabe: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
