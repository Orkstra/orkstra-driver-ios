//
//  SyncManager.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 08/04/2025.
//

import RealmSwift

class SyncManager {
    private var syncTimer: Timer?
    private let dirtyTypes: [Object.Type] = [Stop.self, Trip.self]
    
    init() {
        // Start the timer for periodic sync
        startSyncTimer()
    }

    // Function to start the timer
    private func startSyncTimer() {
        syncTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(syncDirtyObjectsTimerFired), userInfo: nil, repeats: true)
    }

    // Function to perform sync
    @objc private func syncDirtyObjectsTimerFired() {
        syncDirtyObjects() // No need for completion here
    }

    func syncDirtyObjects(completion: (() -> Void)? = nil) {
       let realm = try! Realm()
        let group = DispatchGroup()
        
        for type in dirtyTypes {
            let dirtyObjects = realm.objects(type).filter("isDirty == true")

            for obj in dirtyObjects {
                guard let dirtyObj = obj as? DirtyTrackable else { continue }
                
                group.enter()
                syncWithBackend(dirtyObj) { success in
                    if success {
                        if let o = dirtyObj as? DirtyRealmObject{
                            o.markAsClean()
                        }
                    }else{
                        print("Sync failed for object: \(dirtyObj)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }

    // Function to sync data with backend (you can customize this for your API)
    private func syncWithBackend(_ objects: DirtyTrackable, completion: @escaping (Bool) -> Void) {
        // Call your backend API to sync the dirty objects here
        let manager = ProductModel()
        manager.getProducts(){ result, error, next in
            print("Done")
            completion(true)
        }
    }
    
    func forceSyncNow() {
        // Invalidate current timer
        syncTimer?.invalidate()

        // Perform immediate sync
        syncDirtyObjects()

        // Restart the timer
        startSyncTimer()
    }
}
