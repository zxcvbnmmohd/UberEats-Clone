//
//  DriverOrder.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation
import SwiftyJSON

class DriverOrder {
    
    var id: Int?
    var customerName: String?
    var customerAddress: String?
    var custonerAvatar: String?
    var businessName: String?
    var orderTotal: Float?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.customerName = json["customer"]["name"].string
        self.customerAddress = json["address"].string
        self.custonerAvatar = json["customer"]["avatar"].string
        self.businessName = json["business"]["name"].string
        self.orderTotal = json["total"].float
    }
}
