//
//  CartTableViewCell.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
