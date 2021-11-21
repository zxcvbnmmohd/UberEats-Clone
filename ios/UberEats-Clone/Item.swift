//
//  File.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation
import SwiftyJSON

class Item {
    var id: Int?
    var name: String?
    var description: String?
    var image: String?
    var price: Float?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.description = json["description"].string
        self.image = json["image"].string
        self.price = json["price"].float
    }
}
