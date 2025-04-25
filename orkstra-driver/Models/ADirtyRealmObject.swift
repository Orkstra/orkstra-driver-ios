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
        if let realm = self.realm {
            if realm.isInWriteTransaction {
                self.isDirty = false
            } else {
                try? realm.write {
                    self.isDirty = false
                }
            }
        } else {
            self.isDirty = false
        }
    }
}

protocol DirtyTrackable: AnyObject {
    var isDirty: Bool { get set }
    func markAsClean()
}
