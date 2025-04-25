//
//  Storage.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 18/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class Storage: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "storages"
    // Attributes
    @Persisted var name: String?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}
