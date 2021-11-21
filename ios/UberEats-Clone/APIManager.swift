//
//  APIManager.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import CoreLocation

class APIManager {
    
    static let shared = APIManager()
    
    let baseURL = NSURL(string: BASE_URL)
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    // API - Login
    func login(userType: String, completionHanlder: @escaping (NSError?) -> Void) {
        let path = "api/social/convert-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "grant_type": "convert_token",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "backend": "facebook",
            "token": AccessToken.current!.tokenString,
            "user_type": userType
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    print(jsonData)
                    
                    self.accessToken = jsonData["access_token"].string!
                    self.refreshToken = jsonData["refresh_token"].string!
                    self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                    
                    completionHanlder(nil)
                    break
                    
                case .failure(let error):
                    completionHanlder(error as NSError?)
                    break
            }
        }
        
    }
    
    // API - Logout
    func logout(completionHanlder: @escaping (NSError?) -> Void) {
        let path = "api/social/revoke-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": self.accessToken
        ]
        
        AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success:
                    completionHanlder(nil)
                    break
                    
                case .failure(let error):
                    completionHanlder(error as NSError?)
                    break
            }
        }
        
    }
    
    // API to refresh the access token when it's expired
    func refreshTokenIfNeed(completionHanlder: @escaping () -> Void) {
        let path = "api/social/refresh-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "refresh_token": self.refreshToken
        ]
        
        if Date() > self.expired {
            AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                
                    switch response.result {
                        case .success(let value):
                            let jsonData = JSON(value)
                                                        
                            self.accessToken = jsonData["access_token"].string!
                            self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                            
                            completionHanlder()
                            break
                            
                        case .failure:
                            break
                }
            }
        } else {
            completionHanlder()
        }
    }
    
    // Request Server function
    func requestServer(_ method: Alamofire.HTTPMethod,_ path: String,_ params: [String: Any]?,_ encoding: ParameterEncoding,_ completionHandler: @escaping (JSON?) -> Void ) {
        let url = baseURL?.appendingPathComponent(path)
        
        refreshTokenIfNeed {
            AF.request(url!, method: method, parameters: params, encoding: encoding)
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let value):
                        let jsonData = JSON(value)
                        completionHandler(jsonData)
                        break
                        
                    case .failure(let error):
                        print(error.errorDescription!)
                        completionHandler(nil)
                        break
                    }
                }
        }
    }
    
    
    /* CUSTOMER */
    
    // API to fetch all business
    func getBusinesses(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/restaurants/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    // API to fetch all items of a business
    func getItems(restaurantId: Int, completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/meals/\(restaurantId)"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    // API to create payment intent
    func createPaymentIntent(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/payment_intent/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "total": Cart.currentCart.getTotalValue(),
        ]
        
        requestServer(.post, path, params, URLEncoding.default, completionHandler)
    }
    
    // API to create an order
    func createOrder(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/order/add/"
        let items = Cart.currentCart.items
        
        let jsonArray = items.map { item in
            return [
                "item_id": item.item.id,
                "quantity": item.qty
            ]
        }
        
        if JSONSerialization.isValidJSONObject(jsonArray) {
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params: [String: Any] = [
                    "access_token": self.accessToken,
                    "restaurant_id": Cart.currentCart.restaurant!.id!,
                    "order_details": dataString,
                    "address": Cart.currentCart.address!
                ]
                
                requestServer(.post, path, params, URLEncoding.default, completionHandler)
                
            } catch {
                print("JSON serialization failed: \(error)")
            }
        }
        
    }
    
    // API to get the latest order (Customer)
    func getLatestOrder(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/order/latest/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        
        requestServer(.get, path, params, URLEncoding.default, completionHandler)
    }
    
    // API to get the latest order's status (Customer)
    func getLatestOrderStatus(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/order/latest_status/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        
        requestServer(.get, path, params, URLEncoding.default, completionHandler)
    }
    
    // API to get driver's location
    func getDriverLocation(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/driver/location/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        requestServer(.get, path, params, URLEncoding.default, completionHandler)
    }
    
    
    /* DRIVER */
    
    // API getting Driver's profile
    func getDriverProfile(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/driver/profile/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        
        requestServer(.get, path, params, URLEncoding.default, completionHandler)
    }
    
    // API update driver's profile
    func updateDriverProfile(car_model: String, plate_number: String, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/driver/profile/update/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "car_model": car_model,
            "plate_number": plate_number
        ]
        
        requestServer(.post, path, params, URLEncoding.default, completionHandler)
    }
    
    // API getting list of ready orders for picking up
    func getDriverOrders(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/driver/order/ready/"
        requestServer(.get, path, nil, URLEncoding.default, completionHandler)
    }
    
    // API picking up an order
    func pickOrder(order_id: Int, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/driver/order/pick/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "order_id": "\(order_id)"
        ]
        requestServer(.post, path, params, URLEncoding.default, completionHandler)
    }
    
    // API getting driver's current order
    func getCurrentDriverOrder(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/driver/order/latest/"
        let params: [String: Any] = [
            "access_token": self.accessToken
        ]
        
        requestServer(.get, path, params, URLEncoding.default, completionHandler)
    }
    
    // API update driver's location
    func updateLocation(location: CLLocationCoordinate2D, completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/driver/location/update/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "location": "\(location.latitude),\(location.longitude)"
        ]
        requestServer(.post, path, params, URLEncoding.default, completionHandler)
    }
    
    // API complete the order
    func completeOrder(order_id: Int, completionHander: @escaping (JSON?) -> Void) {
        let path = "api/driver/order/complete/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
            "order_id": "\(order_id)"
        ]
        requestServer(.post, path, params, URLEncoding.default, completionHander)
    }
    
    // API get driver's revenue
    func getDriverRevenue(completionHander: @escaping (JSON?) -> Void) {
        let path = "api/driver/revenue/"
        let params: [String: Any] = [
            "access_token": self.accessToken,
        ]
        requestServer(.get, path, params, URLEncoding.default, completionHander)
    }
    
}
