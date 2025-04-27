//
//  StorageType.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 18/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class StorageType: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "storage_types"
    // Attributes
    //@Persisted var name: String?
    @Persisted var uid: String?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, uid: String) {
        self.init()
        self.id = id
        self.uid = uid
    }
}
