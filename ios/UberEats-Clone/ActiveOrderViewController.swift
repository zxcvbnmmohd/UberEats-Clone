//
//  ActiveOrderViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-22.
//

import UIKit
import MapKit

class ActiveOrderViewController: UIViewController {
    var orderId: Int?
    var restaurantAddress: MKPlacemark?
    var customerAddress: MKPlacemark?
    
    var locationManager = CLLocationManager()
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var timerDriverLocation = Timer()
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var customerSelfieIV: UIImageView!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerAddressLabel: UILabel!
    @IBOutlet weak var orderCompleteButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func orderCompleteButton(_ sender: Any) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            APIManager.shared.completeOrder(order_id: self.orderId!) { json in
                if json != nil {
                    // Stop updating driver location
                    self.timerDriverLocation.invalidate()
                    self.locationManager.stopUpdatingLocation()
                    self.showEmptyView()
                }
            }
        }
        
        let alertView = UIAlertController(title: "Complete Order", message: "Are you sure?", preferredStyle: .alert)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil) 
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loadData()
        
        // Show current user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
        
        // Update driver's location every 3 seconds
        timerDriverLocation = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.updateLocation()
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
    
    func loadData() {
        APIManager.shared.getCurrentDriverOrder { json in
            let order = json!["order"]
            
            if let id = order["id"].int, order["status"] == "On the way" {
                // Get Customer details and display them
                self.orderId = id
                
                let from = order["business"]["address"].string!
                let to = order["address"].string!
                
                let customerName = order["customer"]["name"].string!
                let customerAvatar = order["customer"]["avatar"].string!
                
                self.customerNameLabel.text = customerName
                self.customerAddressLabel.text = to
                self.customerSelfieIV.image = try! UIImage(data: Data(contentsOf: URL(string: customerAvatar)!))
                self.customerSelfieIV.layer.cornerRadius = 60/2
                self.customerSelfieIV.clipsToBounds = true
                
                self.getLocation(from, "Business") { res in
                    self.restaurantAddress = res
                    
                    self.getLocation(to, "Customer") { cus in
                        self.customerAddress = cus
                        self.getDirection()
                    }
                }
                
            } else {
                // Show message
                self.showEmptyView()
            }
        }
    }
    
    func showEmptyView() {
        self.map.isHidden = true
        self.infoStackView.isHidden = true
        self.orderCompleteButton.isHidden = true
        
        // Show a message
        let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        labelMessage.center = self.view.center
        labelMessage.textAlignment =  NSTextAlignment.center
        labelMessage.text = "You don't have any orders to deliver"
        self.view.addSubview(labelMessage)
    }
    
    func updateLocation() {
        if lastLocation != nil {
            APIManager.shared.updateLocation(location: lastLocation) { json in
                
            }
        }
    }

}

extension ActiveOrderViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
//            let center = CLLocationCoordinate2D(
//                latitude: location.coordinate.latitude,
//                longitude: location.coordinate.longitude
//            )
//            let region = MKCoordinateRegion(
//                center: center,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//            self.map.setRegion(region, animated: true)
            
            // Create driver pin
            lastLocation = location.coordinate
            if driverPin != nil {
                driverPin.coordinate = lastLocation
            } else {
                driverPin = MKPointAnnotation()
                driverPin.coordinate = lastLocation
                self.map.addAnnotation(driverPin)
            }
            
            // Reset zoom to cover the whole 3 locations (driver, restaurant, customer)
            self.map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.map.showAnnotations(map.annotations, animated: true)
        }
    }
}

extension ActiveOrderViewController: MKMapViewDelegate {
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 5
        return renderer
    }
    
    // #2 - Convert an address (string) to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHander: @escaping (MKPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error != nil {
                print("Error:", error!)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                // Create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                self.map.addAnnotation(dropPin)
                
                completionHander(MKPlacemark.init(placemark: placemark))
            }
        }
    }
    
    // #3 - Get direction and zoom to locations on the map
    func getDirection() {
        let request = MKDirections.Request()
        request.source = MKMapItem.init(placemark: restaurantAddress!)
        request.destination = MKMapItem.init(placemark: customerAddress!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if error != nil {
                print("Error: ", error!)
            } else {
                // Show route
                self.showRoute(response: response!)
            }
        }
    }
    
    // #4 - Show route between locations and make a visible zoom
    func showRoute(response: MKDirections.Response) {
        for route in response.routes {
            self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
        map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        map.showAnnotations(map.annotations, animated: true)
    }
}

