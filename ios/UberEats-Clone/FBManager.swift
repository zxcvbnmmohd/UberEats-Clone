//
//  FBManager.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBManager {
    static let shared = LoginManager()
    
    public class func getFBUserData(completionHandler: @escaping () -> Void) {
        
        if let token = AccessToken.current, !token.isExpired {
            GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"])
                .start { connection, result, error in
                    if error == nil {
                        let json = JSON(result!)
                        print(json)
                        
                        User.currentUser.setInfo(json: json)
                        completionHandler()
                    }
                }
        }
    }
}
