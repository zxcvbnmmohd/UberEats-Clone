//
//  BusinessItemsViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit

class BusinessViewController: UIViewController {
    
    var business: Business?
    var items = [Item]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func viewCartButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toCartView", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let businessName = business?.name {
            self.navigationItem.title = businessName
        }
        
        self.fetchItems()
    }
    
    func fetchItems() {
        if let businessId = business?.id {
            APIManager.shared.getItems(businessId: businessId) { json in
                if json != nil {
                    print(json!)
                    
                    self.items = []
                    
                    if let items = json!["items"].array {
                        for i in items {
                            self.items.append(Item(json: i))
                            
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemView" {
            let controller = segue.destination as! ItemViewController
            controller.business = business
            controller.item = items[(tableView.indexPathForSelectedRow!.row)]
        }
    }
    

}

extension BusinessViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.descriptionLabel.text = item.description
        cell.priceLabel.text = "$\(item.price!)"
        
        if let image = item.image {
            Utils.loadImage(cell.foodImageView, "\(image)")
        }
        print("CELLLLLLLL")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0;
    }
}

