//
//  WelcomeViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    var userType: String = USERTYPE_CUSTOMER
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var facebookButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if (AccessToken.current != nil) {
            FBManager.getFBUserData {
                self.facebookButton.setTitle("Continue as \(User.currentUser.name!)", for: .normal)
                self.facebookButton.sizeToFit()
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
    
    func redirectUser() {
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to the next view controller
            print(AccessToken.current!.tokenString)
            performSegue(withIdentifier: "to\(userType.capitalized)View", sender: self)
        }
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            userType = USERTYPE_DRIVER
        } else {
            userType = USERTYPE_CUSTOMER
        }
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        if (AccessToken.current != nil) {
            APIManager.shared.login(userType: userType) { error in
                if error == nil {
                    self.redirectUser()
                } else {
                    print(error!)
                }
            }
        } else {
            FBManager.shared.logIn(permissions: ["public_profile", "email"], from: self) { res, err in
                if (err == nil) {
                    FBManager.getFBUserData {
                        APIManager.shared.login(userType: self.userType) { error in
                            if error == nil {
                                self.redirectUser()
                            } else {
                                print(error!)
                            }
                        }
                    }
                } else {
                    print(err!)
                }
            }
        }
    }
    
}
