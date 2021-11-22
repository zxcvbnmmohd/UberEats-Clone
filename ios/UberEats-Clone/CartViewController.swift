//
//  CartViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import MapKit

class CartViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkoutButton(_ sender: Any) {
        if self.addressTF.text == "" {
            // Show alert that this field is required
            let alertController = UIAlertController(
                title: "No Address",
                message: "Address is required",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default) { alert in
                self.addressTF.becomeFirstResponder()
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Cart.currentCart.address = addressTF.text
            self.performSegue(withIdentifier: "toCheckoutVIew", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if Cart.currentCart.items.count == 0 {
            
            self.checkoutButton.isHidden = true
            self.tableView.isHidden = true
            self.stackView.isHidden = true
            self.map.isHidden = true
            
            let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            labelMessage.center = self.view.center
            labelMessage.textAlignment =  NSTextAlignment.center
            labelMessage.text = "Your cart is empty. Please select a meal"
            self.view.addSubview(labelMessage)
            
        } else {
            self.checkoutButton.isHidden = false
            self.tableView.isHidden = false
            self.stackView.isHidden = false
            self.map.isHidden = false
            
            self.fetchItems()
        }
        
        // Show current user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
    }
    
    func fetchItems() {
        self.tableView.reloadData()
        self.totalLabel.text = "$\(Cart.currentCart.getTotalValue())"
    }
    
}

extension CartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let address = textField.text
        Cart.currentCart.address = address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { placemarks, error in
            if error != nil {
                print("Error: ", error!)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                let region = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.map.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
                
                // Create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                self.map.addAnnotation(dropPin)
            }
        }
        
        return true
    }
}

extension CartViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let center = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.map.setRegion(region, animated: true)
        }
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.currentCart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartItemCell", for: indexPath) as! CartTableViewCell
        
        let item = Cart.currentCart.items[indexPath.row]
        cell.quantityLabel.text = "\(item.qty)"
        cell.nameLabel.text = item.item.name
        cell.priceLabel.text = "$\(item.item.price! * Float(item.qty))"
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
}

