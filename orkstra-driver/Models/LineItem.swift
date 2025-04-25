//
//  LineItem.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 03/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class LineItem: DirtyRealmObject, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "line_tems"
    // Attributes
    @Persisted var shipment_status: String?
    @Persisted var product_label: String?
    
    @Persisted var volume_unit: String?
    @Persisted var shipping_weight_unit: String?
    @Persisted var shipping_weight: Double?
    @Persisted var shipping_volume: Double?
    
    @Persisted var uom: String?
    @Persisted var ordered_quantity: Double?
    @Persisted var delivered_quantity: Double?
    
    
    //  Defining relationships
    @Persisted var storage: Storage?
    @Persisted var product: Product?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, storage: Storage) {
        self.init()
        self.id = id
        self.storage = storage
    }
}
