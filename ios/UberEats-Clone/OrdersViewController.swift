//
//  OrdersViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-22.
//

import UIKit

class OrdersViewController: UIViewController {
    var orders = [DriverOrder]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadReadyOrders()
    }
    
    func loadReadyOrders() {
        APIManager.shared.getDriverOrders { json in
            if json != nil {
                //print(json!)
                
                self.orders = []
                if let readyOrders = json!["orders"].array {
                    for item in readyOrders {
                        let order = DriverOrder(json: item)
                        self.orders.append(order)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func pickOrder(order_id: Int) {
        APIManager.shared.pickOrder(order_id: order_id) { json in
            if let status = json!["status"].string {
                
                switch status {
                case "failed":
                    // Show alert saying error
                    let alertView = UIAlertController(title: "Error", message: json!["error"].string!, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                    alertView.addAction(cancelAction)
                    self.present(alertView, animated: true, completion: nil)
                    
                default:
                    // Show alert saying success
                    let alertView = UIAlertController(title: nil, message: "Success!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Show map", style: .default) { action in
                        self.performSegue(withIdentifier: "toActiveOrderView", sender: self)
                    }
                    alertView.addAction(okAction)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
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

extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        
        let order = orders[indexPath.row]
        cell.restaurantNameLabel.text = order.businessName
        cell.customerNameLabel.text = order.customerName
        cell.customerAddressLabel.text = order.customerAddress
        cell.orderPriceLabel.text = "$\(order.orderTotal!)"
        
        cell.customerSelfieIV.image = try! UIImage(data: Data(contentsOf: URL(string: order.custonerAvatar!)!))
        cell.customerSelfieIV.layer.cornerRadius = 60/2
        cell.customerSelfieIV.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        self.pickOrder(order_id: order.id!)
    }
}
