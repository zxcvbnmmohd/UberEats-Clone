//
//  CheckoutViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import Lottie
import Stripe


class CheckoutViewController: UIViewController {
    var paymentIntentClientSecret: String?
    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    @IBAction func placeOrderButton(_ sender: Any) {
        APIManager.shared.getLatestOrder { json in
            // If the latest order is already delivered
            if json!["last_order"]["restaurant"]["name"] == "" || json!["last_order"]["status"] == "Delivered" {
                // Process the payment and create an order
                guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
                    return;
                }
                
                // Collect the card details
                let cardParams = self.cardTextField.cardParams
                let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
                paymentIntentParams.paymentMethodParams = paymentMethodParams
                
                // Submit the payment
                STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { status, paymentIntent, error in
                    switch (status) {
                    case .failed:
                        print("Payment failed: \(error?.localizedDescription ?? "")")
                        break
                    case .canceled:
                        print("Payment canceled: \(error?.localizedDescription ?? "")")
                        break
                    case .succeeded:
                        print("Payment succeeded: \(paymentIntent?.description ?? "")")
                        APIManager.shared.createOrder { json in
                            print(json!)
                            Cart.currentCart.reset()
                            self.performSegue(withIdentifier: "ViewDelivery", sender: self)
                        }
                        break
                    @unknown default:
                        fatalError()
                        break
                    }
                }
                
            } else {
                // Show alert message saying that you currently still have an outstanding order
                let alertView = UIAlertController(title: "Already order?", message: "Your current order is not completed", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let okAction = UIAlertAction(title: "Go to order", style: .default) { action in
                    self.performSegue(withIdentifier: "ViewDelivery", sender: self)
                }
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
        
        cardTextField.postalCodeEntryEnabled = false
        
        self.startCheckout()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func startCheckout() {
        APIManager.shared.createPaymentIntent { json in
            print(json!)
            guard let client_secret = json?["client_secret"] else {
                return
            }
            self.paymentIntentClientSecret = "\(client_secret)"
        }
    }
}

extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
