//
//  WelcomeViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var facebookButton: UIButton!
    
    @IBAction func facebookButton(_ sender: Any) {
        if (AccessToken.current != nil) {
            self.redirectUser()
        } else {
            FBManager.shared.logIn(permissions: ["public_profile", "email"], from: self) {result, error in
                if (error == nil) {
                    self.redirectUser()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func redirectUser() {
        if let token = AccessToken.current, !token.isExpired {
            performSegue(withIdentifier: "toCustomerView", sender: self)
        }
    }
    
}
