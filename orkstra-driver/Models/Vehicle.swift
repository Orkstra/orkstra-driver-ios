//
//  Vehicle.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 18/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class Vehicle: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "vehicles"
    
    // Attributes
    @Persisted var name: String?
    
    //  Defining relationships
    @Persisted var vehicle_template: VehicleTemplate?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
}
