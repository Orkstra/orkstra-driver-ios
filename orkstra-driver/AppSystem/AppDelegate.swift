//
//  AppDelegate.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 01/04/2025.
//

import UIKit
import PKHUD
import LanguageManager_iOS
import RealmSwift
import GoogleMaps
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LanguageManager.shared.defaultLanguage = .deviceLanguage
        PKHUD.sharedHUD.dimsBackground = false
        
        UIView.appearance().semanticContentAttribute = .unspecified
        //UIApplication.shared.windows.first?.backgroundColor = .white
        
        // Provide the API key to the Google Maps SDK
        GMSServices.provideAPIKey(GMSServicesApiKey)
        
        //Migration
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 7,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
    
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Register your background task
        BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.applab.orkstra-driver.sync",
                using: nil
            ) { task in
                self.handleBackgroundSyncTask(task: task as! BGAppRefreshTask)
            }
        
        //Manually trigger the sync function
        let syncManager = SyncManager()
        syncManager.forceSyncNow()
        
        return true
    }

    func scheduleBackgroundSyncTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.applab.orkstra-driver.sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 5 seconds for testing

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background sync task scheduled")
        } catch {
            print("❌ Failed to schedule: \(error)")
        }
    }

    func handleBackgroundSyncTask(task: BGAppRefreshTask) {
        print("Background Job Working")

        // Always reschedule first
        scheduleBackgroundSyncTask()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let syncOperation = BlockOperation()

        syncOperation.addExecutionBlock {
            let syncManager = SyncManager()

            let semaphore = DispatchSemaphore(value: 0)

            syncManager.syncDirtyObjects {
                semaphore.signal()
            }

            _ = semaphore.wait(timeout: .now() + 25) // Allow time before expiration
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        syncOperation.completionBlock = {
            task.setTaskCompleted(success: !syncOperation.isCancelled)
        }

        queue.addOperation(syncOperation)
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

