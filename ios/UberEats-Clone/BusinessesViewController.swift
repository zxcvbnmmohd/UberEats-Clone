//
//  BusinessViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import SkeletonView

class BusinessesViewController: UIViewController {
    var businesses = [Business]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutButton(_ sender: Any) {
        APIManager.shared.logout { error in
            if error == nil {
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                
                // Re-render the LoginView once you completed the logging out process
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                self.view.window?.rootViewController = loginVC
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView.showAnimatedGradientSkeleton(
            usingGradient: .init(baseColor: .concrete),
            animation: nil,
            transition: .crossDissolve(0.25)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.fetchBusinesses()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBusinessView" {
            let controller = segue.destination as! BusinessViewController
            controller.business = businesses[(tableView.indexPathForSelectedRow!.row)]
        }
    }
    
    func fetchBusinesses() {
        APIManager.shared.getBusinesses { json in
            if json != nil {
                print(json!)
                
                self.businesses = []
                
                if let listRes = json!["businesses"].array {
                    for item in listRes {
                        let business = Business(json: item)
                        self.businesses.append(business)
                        print(business.name!)
                    }
                }
                
                self.tableView.stopSkeletonAnimation()
                self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                
                self.tableView.reloadData()
            }
        }
        
    }
    
}


extension BusinessesViewController: SkeletonTableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessTableViewCell

        let item = businesses[indexPath.row]

        cell.nameLabe.text = item.name
        cell.addressLabel.text = item.address

        if let logo = item.logo {
            let url = "\(logo)"
            Utils.loadImage(cell.imageIV, url)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0;
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "businessCell"
    }

}

