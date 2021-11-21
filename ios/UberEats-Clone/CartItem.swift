//
//  CartItem.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation

class CartItem {
    var item: Item
    var qty: Int
    
    init(item: Item, qty: Int) {
        self.item = item
        self.qty = qty
    }
}
