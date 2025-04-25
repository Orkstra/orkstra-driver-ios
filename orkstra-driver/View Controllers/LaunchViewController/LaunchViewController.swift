//
//  LaunchViewController.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import RealmSwift

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getProducts()
        
        let userManager = UserManager()
        userManager.getUser()
        
        if currentUser.id == nil{
            let warehouse = Warehouse()
            warehouse.id = "1"
            warehouse.name = "Test Warehouse"
            warehouse.latitude = 28.538336
            warehouse.longitude = -81.379234
            
            currentUser = User()
            currentUser.id = "1"
            currentUser.warehouse = warehouse
            
            userManager.save()
        }
        
        //Seed stop data
        let realm = try! Realm()
        
        if realm.objects(Trip.self).count == 0{
            let tripManager = TripManager()
            tripManager.seedData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let vc = TripViewController(nibName: "TripViewController", bundle: nil)
        
        let tripManager = TripManager()
        let trip = tripManager.getTrip(byId: "1")
        
        vc.tripId = trip?.id
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }


    func getProducts(){
        let productModel = ProductModel()
        productModel.getProduct(id: "3442") { (product: Product?, error, nextLink) in
            if product != nil {
                print("Fetched products: \(product?.id)")
                print("ok")
            } else if let error = error {
              print("Error: \(error.localizedDescription)")
            }else{
                print("Connection Failed")
            }
        }
    }

}
