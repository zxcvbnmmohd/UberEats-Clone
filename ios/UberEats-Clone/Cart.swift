//
//  Cart.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation

class Cart {
    static let currentCart = Cart()
    
    var business: Business?
    var items = [CartItem]()
    var address: String?
    
    func getTotalValue() -> Float {
        var total: Float = 0
        for item in self.items {
            total = total + Float(item.qty) * item.item.price!
        }
        return total
    }
    
    func getTotalQuantity() -> Int {
        var total: Int = 0
        for item in self.items {
            total = total + item.qty
        }
        return total
    }
    
    func reset() {
        self.business = nil
        self.address = nil
        self.items = []
    }
}
