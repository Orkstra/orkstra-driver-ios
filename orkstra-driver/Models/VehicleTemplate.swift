//
//  VehicleTemplate.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 18/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class VehicleTemplate: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "vehicle_templates"
    // Attributes
    @Persisted var name: String?
    @Persisted var vehicle_type: String?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
}
