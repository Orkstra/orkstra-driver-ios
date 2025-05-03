//
//  Delivery.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

struct deliveryList: Codable {
    var data: [Delivery]
}

class Delivery: DirtyRealmObject, DirtyTrackable, Codable{
    // These two attributes are crucial in any struct
    @Persisted var id: String?
    @Persisted var type: String = "deliveries"
    // Attributes
    @Persisted var status: String?
    @Persisted var tracking_number: String?
    
    @Persisted var serviceTime: TimeInterval = 900.0 // 15 minutes
    @Persisted var label: String?
    @Persisted var direction: String?

    @Persisted var contact_person: String?
    @Persisted var contact_phone_number: String?
    
    @Persisted var eta: Date?
    @Persisted var start_time: Date?
    @Persisted var end_time: Date?
    
    //  Defining relationships
    @Persisted var line_items = List<LineItem>()
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, label: String, start_time: Date?, end_time: Date?, serviceTime: Double, contact_person: String, contact_phone_number: String, status: String, direction: String, line_items: [LineItem]?) {
        self.init()
        self.id = id
        self.label = label
        self.serviceTime = serviceTime
        self.start_time = start_time
        self.end_time = end_time
        self.contact_person = contact_person
        self.contact_phone_number = contact_phone_number
        self.status = status
        self.direction = direction
        if line_items != nil{
            self.line_items.append(objectsIn: line_items!)
        }
    }
}

class DeliveryManager {

    // Search for a delivery by id
    func getDelivery(byId id: String) -> Delivery? {
        let realm = try! Realm()

        if let delivery = realm.object(ofType: Delivery.self, forPrimaryKey: id) {
            return delivery
        } else {
            return nil
        }
    }


}
