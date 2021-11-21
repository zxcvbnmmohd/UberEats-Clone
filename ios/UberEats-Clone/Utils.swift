//
//  Utils.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-21.
//

import Foundation
import UIKit

class Utils {

    // Helper method to load image asynchronously
    static func loadImage(_ imageView: UIImageView,_ urlString: String) {
        let imgURL: URL = URL(string: urlString)!
        URLSession.shared.dataTask(with: imgURL) {
            (data, response, error) in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
