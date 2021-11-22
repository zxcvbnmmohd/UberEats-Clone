//
//  ItemViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit

class ItemViewController: UIViewController {
    var generalLabel = UILabel()
    var business: Business?
    var item: Item?
    var qty = 1
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBAction func removeButton(_ sender: Any) {
        if qty >= 2 {
            qty -= 1
            quantityLabel.text = String(qty)
            
//            if let price = item?.price {
////                priceLabel.text = "$\(price * Float(qty))"
//            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        if qty < 99 {
            qty += 1
            quantityLabel.text = String(qty)
            
//            if let price = item?.price {
////                priceLabel.text = "$\(price * Float(qty))"
//            }
        }
    }
    
    @IBAction func addToCartButton(_ sender: Any) {
        let cartItem = CartItem(item: self.item!, qty: self.qty)
        
        // Check if a current cart and a current business exist then we add this item into the existing card
        guard let cartRestaurant = Cart.currentCart.business, let currentRestaurant = self.business else {
            // Add this item to the current Cart
            Cart.currentCart.business = self.business
            Cart.currentCart.items.append(cartItem)
            
            print(Cart.currentCart.getTotalQuantity())
            goBack()
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // If ordering item from the same business
        if cartRestaurant.id == currentRestaurant.id {
            // Scenario #1: Ordering the same item => increase the qty of an existing item
            // Scenario #2: Ordering different item => just append that item to the Cart
            
            let inCart = Cart.currentCart.items.lastIndex { (item) -> Bool in
                return item.item.id == cartItem.item.id
            }
            
            if let index = inCart {
                
                let alertView = UIAlertController(
                    title: "Add more?",
                    message: "Your cart already has this item. Do you want to add more?",
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "Add more", style: .default) { action in
                    Cart.currentCart.items[index].qty += self.qty
                    print(Cart.currentCart.getTotalQuantity())
                    self.goBack()
                }
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                self.present(alertView, animated: true, completion: nil)
            } else {
                Cart.currentCart.items.append(cartItem)
                print(Cart.currentCart.getTotalQuantity())
                goBack()
            }
        } else {
            // Ordering item from a different business => Error
            let alertView = UIAlertController(
                title: "Start new cart?",
                message: "You're ordering item from another business. Do you want to clear the current Cart?",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "Yes", style: .default) { action in
                Cart.currentCart.items = []
                Cart.currentCart.items.append(cartItem)
                Cart.currentCart.business = self.business
                
                print(Cart.currentCart.getTotalQuantity())
                self.goBack()
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchItem()
    }
    
    
    func fetchItem() {
        self.quantityLabel.text = "\(qty)"
        self.nameLabel.text = item?.name
        self.descriptionLabel.text = item?.description
//        if let price = item?.price {
////            costLabel.text = "$\(price)"
//        }
                
        if let imageUrl = item?.image {
            Utils.loadImage(foodImageView, "\(imageUrl)")
        }
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
