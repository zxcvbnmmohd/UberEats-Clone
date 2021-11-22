//
//  YourOrderViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import UIKit
import MapKit

class YourOrderViewController: UIViewController {
    var orderStatus = ""
    var restaurantAddress: MKPlacemark?
    var customerAddress: MKPlacemark?
    
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var timerOrderStatus = Timer()
    var timerDeliveryLocation = Timer()
    
    @IBOutlet weak var orderStatusStack: UIStackView!
    @IBOutlet weak var acceptedIV: UIImageView!
    @IBOutlet weak var readyIV: UIImageView!
    @IBOutlet weak var deliveringIV: UIImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var driverCardView: UIView!
    
    @IBOutlet weak var dirverSelfieIV: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    
    @IBOutlet weak var driverCarLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getLatestOrder()
        
        timerOrderStatus = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.getLatestOrderStatus()
        }
    }
    
    func getLatestOrderStatus() {
        APIManager.shared.getLatestOrderStatus { json in
            print(json!)
            
            let order = json!["last_order_status"]
            self.orderStatus = order["status"].string!
            
            self.updateStatus()
        }
    }
    
    func getLatestOrder() {
        APIManager.shared.getLatestOrder { json in
            print(json!)
            
            let order = json!["last_order"]
            
            
            if let id = order["id"].int, order["status"] == "On the way" {
                let from = order["business"]["address"].string!
                let to = order["address"].string!
                
                // Get Driver's details
                if order["driver"] != nil {
                    let driverName = order["driver"]["name"].string!
                    let driverAvatar = order["driver"]["avatar"].string!
                    let carModelID = order["driver"]["car_model"].string!
                    let plateNumber = order["driver"]["plate_number"].string!
                    
                    let carModels = ["Mazda", "Tesla", "Audi"]
                    
                    self.driverNameLabel.text = driverName
                    self.dirverSelfieIV.image = try! UIImage(data: Data(contentsOf: URL(string: driverAvatar)!))
                    self.dirverSelfieIV.layer.cornerRadius = 60/2
                    self.driverCarLabel.text = "\(carModels[Int(carModelID)!]) - \(plateNumber)"
                }
                
                
                self.getLocation(from, "Business") { res in
                    self.restaurantAddress = res
                    
                    self.getLocation(to, "Customer") { cus in
                        self.customerAddress = cus
                        self.getDirection()
                    }
                }
                
                // Update driver's location every 3 seconds
                self.timerDeliveryLocation = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                    self.getDriverLocation()
                }
                
                
            } else {
                // Show a label of "No current order at the moment"
                // I will let you do it yourself
            }
            
            
        }
    }
    
    func updateStatus() {
        switch self.orderStatus {
            case "Ready":
                self.readyIV.alpha = 1
                break
            case "On the way":
                self.readyIV.alpha = 1
                self.deliveringIV.alpha = 1
                if self.driverCardView.isHidden {
                    self.driverCardView.isHidden = false
                    self.getLatestOrder()
                }
                break
            default:
                break
        }
    }
    
    func getDriverLocation() {
        APIManager.shared.getDriverLocation { json in
            //print(json!)
            
            if let location = json!["location"].string {
                let split = location.components(separatedBy: ",")
                let lat = split[0]
                let lng = split[1]
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lng)!)
                
                // Create driver pin
                if self.driverPin != nil {
                    self.driverPin.coordinate = coordinate
                } else {
                    self.driverPin = MKPointAnnotation()
                    self.driverPin.coordinate = coordinate
                    self.driverPin.title = "Driver"
                    self.map.addAnnotation(self.driverPin)
                }
                
                // Reset zoom to cover the whole 3 locations (driver, restaurant, customer)
                self.map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                self.map.showAnnotations(self.map.annotations, animated: true)
            } else {
                self.timerOrderStatus.invalidate()
                self.timerDeliveryLocation.invalidate()
                self.showEmptyView()
            }
        }
    }
    
    func showEmptyView() {
        self.map.isHidden = true
        self.orderStatusStack.isHidden = true
        self.driverCardView.isHidden = true
        
        // Show a message
        let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        labelMessage.center = self.view.center
        labelMessage.textAlignment =  NSTextAlignment.center
        labelMessage.text = "You don't have any outstanding orders"
        self.view.addSubview(labelMessage)
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


extension YourOrderViewController: MKMapViewDelegate {
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
    
    // #5 - Customize pin with image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "MyPin"
        
        var annotationView: MKAnnotationView?
        if let dequeueAnnotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeueAnnotaionView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView, let name = annotation.title! {
            switch name {
            case "Driver":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_driver")
            case "Restaurant":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_restaurant")
            case "Customer":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_customer")
            default:
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_driver")
            }
        }
        
        return annotationView
    }
}
