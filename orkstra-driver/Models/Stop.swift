//
//  Stop.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 20/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

struct StopList: Codable {
    var data: [Stop]
}

class Stop: DirtyRealmObject, DirtyTrackable, Codable{
    // These two attributes are crucial in any struct
    @Persisted var id: String?
    @Persisted var type: String = "stops"
    // Attributes
    @Persisted var order: Int?
    @Persisted var shipment_status: String?
    @Persisted var tracking_number: String?
    
    @Persisted var label: String?
    @Persisted var latitude: Double?
    @Persisted var longitude: Double?
    @Persisted var address_line_1: String?
    @Persisted var address_line_2: String?
    
    @Persisted var eta: Date?
    
    //  Defining relationships
    @Persisted var warehouse: Warehouse?
    @Persisted var deliveries = List<Delivery>()
    @Persisted var line_items = List<LineItem>()
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, latitude: Double, longitude: Double, order: Int, label: String, address_line_1: String, shipment_status: String, warehouse: Warehouse?, deliveries: [Delivery]?) {
        self.init()
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.order = order
        self.label = label
        self.address_line_1 = address_line_1
        self.shipment_status = shipment_status
        self.warehouse = warehouse
        if deliveries != nil{
            self.deliveries.append(objectsIn: deliveries!)
        }
    }
}

class StopManager {

    // Search for a stop by id
    func getStop(byId id: String) -> Stop? {
        let realm = try! Realm()

        if let stop = realm.object(ofType: Stop.self, forPrimaryKey: id) {
            return stop
        } else {
            return nil
        }
    }

    func getOutDeleveries(stop: Stop) -> [Delivery]{
        return stop.deliveries.filter { $0.direction == "out" }
    }
    
    func getInDeleveries(stop: Stop) -> [Delivery]{
        return stop.deliveries.filter { $0.direction == "in" }
    }

}
