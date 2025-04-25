//
//  Warehouse.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class Warehouse: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "warehouses"
    // Attributes
    @Persisted var name: String?
    @Persisted var latitude: Double?
    @Persisted var longitude: Double?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
}
