//
//  User.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 01/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class User: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "users"
    // Attributes
    @Persisted var name: String?
    @Persisted var email: String?
    @Persisted var phone_number: String?
    @Persisted var token: String?
    @Persisted var uid: String?
    @Persisted var client: String?
    //  Defining relationships
    @Persisted var warehouse: Warehouse?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
}


var currentUser = User()

class UserManager: NSObject {
    
    func save(){
        delete()
        let realm = try! Realm()
        // Save both objects to Realm
        try! realm.write {
            realm.add(currentUser)      // Save the User object
        }
    }
    
    func getUser(){
        let realm = try! Realm()
        if let user = realm.objects(User.self).first{
            currentUser = user
            print("Warehouse Name: \(user.warehouse?.name ?? "No warehouse name")")
            //Setup the headers
            let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            headers = ["uid": currentUser.uid ?? "", "access-token": currentUser.token ?? "", "client": currentUser.client ?? "", "X-Platform": "ios_customer", "X-Client-Version": version]
        }
    }
    
    func delete(){
        let realm = try! Realm()
        if let user = realm.objects(User.self).last{
            try! realm.write {
                // Delete the associated Warehouse object
                if let warehouse = user.warehouse {
                    realm.delete(warehouse)
                }
                
                // Delete the User object
                realm.delete(user)
                
                currentUser = User()
                let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                headers = ["uid": (currentUser.uid ?? ""), "access-token": (currentUser.token ?? ""), "client": (currentUser.client ?? ""), "X-Client-Version": version]
            }
        }
    }
    
}

