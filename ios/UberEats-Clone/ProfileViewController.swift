//
//  ProfileViewController.swift
//  UberEats-Clone
//
//  Created by Mohamed Mohamed on 2021-11-22.
//

import UIKit
import DropDown

class ProfileViewController: UIViewController {
    
    let dropDown = DropDown()
    let carModels = ["Mazda", "Tesla", "Audi"]
    let carImages = ["car_1", "car_2", "car_3"]
    
    var selectedCarIndex = -1
    
    @IBAction func updateButton(_ sender: Any) {
        let car_model = selectedCarIndex >= 0 ? String(selectedCarIndex) : ""
        let plate_number = plateTextField.text
        
        APIManager.shared.updateDriverProfile(car_model: car_model, plate_number: plate_number!) { json in
            self.plateTextField.resignFirstResponder()
            
            guard let status = json?["status"] else {
                return
            }
            
            let alertController = UIAlertController(title: "Notification", message: "Profile is updated", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var selfieIV: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var carIV: UIImageView!
    @IBOutlet weak var carModelButton: UIButton!
    @IBOutlet weak var plateTextField: UITextField!
    
    @IBAction func carModelButton(_ sender: Any) {
        dropDown.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loadDriverProfile()
        self.loadDropDownCarModel()
    }
    
    func loadDropDownCarModel() {
        // The view to which the drop down will appear on
        dropDown.anchorView = carModelButton

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = carModels
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          // print("Selected item: \(item) at index: \(index)")
            carModelButton.setTitle("\(item)", for: .normal)
            carIV.image = UIImage(named: self.carImages[index])
            self.selectedCarIndex = index
        }
    }
    
    func loadDriverProfile() {
        nameLabel.text = User.currentUser.name
        
        selfieIV.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        selfieIV.layer.cornerRadius = 100/2
        selfieIV.layer.borderWidth = 1
        selfieIV.layer.borderColor = UIColor.white.cgColor
        selfieIV.clipsToBounds = true
        
        APIManager.shared.getDriverProfile { json in
            if json != nil {
                //print(json!)
                let driver = json!["driver"]
                
                let car_model = driver["car_model"].string!
                let plate_number = driver["plate_number"].string!
                
                if car_model != "" {
                    let index = Int(car_model) ?? 0
                    self.selectedCarIndex = index
                    self.carModelButton.setTitle(self.carModels[index], for: .normal)
                    self.carIV.image = UIImage(named: self.carImages[index])
                }
                
                self.plateTextField.text = plate_number
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

}
