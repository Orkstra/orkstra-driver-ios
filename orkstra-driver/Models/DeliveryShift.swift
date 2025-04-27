//
//  DeliveryShift.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 25/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class DeliveryShift: Object, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "delivery_shifts"
    // Attributes
    @Persisted var start_time: Date?
    @Persisted var end_time: Date?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
}

class ShiftManager {
    
    func isETAWithinShift(eta: Date, delivery_shift: DeliveryShift) -> Bool {
        guard let shiftTo = delivery_shift.end_time else {
            print("Shift 'to' time is not set.")
            return false
        }

        // Extract today's date components
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        // Extract the time components from shift.to
        let shiftToComponents = calendar.dateComponents([.hour, .minute, .second], from: shiftTo)

        // Combine the date components of today and the time components of shift.to
        var combinedComponents = todayComponents
        combinedComponents.hour = shiftToComponents.hour
        combinedComponents.minute = shiftToComponents.minute
        combinedComponents.second = shiftToComponents.second

        // Create a full Date object for shift.to
        guard let normalizedShiftTo = calendar.date(from: combinedComponents) else {
            print("Failed to normalize shift 'to' time.")
            return false
        }

        // Compare ETA with the normalized shift.to time
        return eta <= normalizedShiftTo
    }
    
}
