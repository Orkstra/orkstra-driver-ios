//
//  ADirtyRealmObject.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 07/04/2025.
//

import RealmSwift

class DirtyRealmObject: Object {
    @Persisted var isDirty: Bool = false{
        didSet{
            let manager = SyncManager()
            manager.forceSyncNow()
        }
    }
    
    func markAsClean() {
        // Ensure the object is valid
        guard !self.isInvalidated else {
            print("Object is invalidated or deleted.")
            return
        }

        // Check if the object is managed by Realm
        if let realm = self.realm {
            // Check if already in a write transaction
            if realm.isInWriteTransaction {
                self.isDirty = false
            } else {
                // Perform the write transaction
                try? realm.write {
                    self.isDirty = false
                }
            }
        } else {
            // Unmanaged object
            self.isDirty = false
        }
    }
}

protocol DirtyTrackable: AnyObject {
    var isDirty: Bool { get set }
    func markAsClean()
}
