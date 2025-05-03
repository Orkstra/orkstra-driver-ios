//
//  Trip.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 03/04/2025.
//

import UIKit
import RealmSwift
import Unrealm

class Trip: DirtyRealmObject, DirtyTrackable, Codable{
    @Persisted var id: String?
    @Persisted var type: String = "trips"
    // Attributes
    @Persisted var name: String?
    @Persisted var route_name: String?
    @Persisted var status: String?
    //  Defining relationships
    @Persisted var stops = List<Stop>()
    @Persisted var delivery_shift: DeliveryShift?
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, name: String, route_name: String, stops: [Stop]?, status: String?) {
        self.init()
        self.id = id
        self.name = name
        self.route_name = route_name
        self.status = status
        if stops != nil{
            self.stops.append(objectsIn: stops!)
        }
    }
}

class TripManager {

    // Add stops
    func addTrip(trip: Trip) {
        let realm = try! Realm()

        // Write trip to Realm
        try! realm.write {
            realm.add(trip, update: .modified)
        }
    }
    
    // Delete all trips
    func deleteAllTrips() {
        let realm = try! Realm()

        try! realm.write {
            // Query all Trip objects
            let allTrips = realm.objects(Trip.self)
            // Delete all tri[s
            realm.delete(allTrips)
            
            // Query all Stop objects
            let allStops = realm.objects(Stop.self)
            // Delete all stops
            realm.delete(allStops)
            
            // Query all LineItem objects
            let allLineItems = realm.objects(LineItem.self)
            // Delete all lineItems
            realm.delete(allLineItems)
            
            // Query all Storage objects
            let allStorages = realm.objects(StorageType.self)
            // Delete all storages
            realm.delete(allStorages)
            
            // Query all Delivery objects
            let allDeliveries = realm.objects(Delivery.self)
            // Delete all deliveries
            realm.delete(allDeliveries)
            
            // Query all Shift objects
            let allShifts = realm.objects(DeliveryShift.self)
            // Delete all shifts
            realm.delete(allShifts)
        }

    }

    // Search for a trip by id
    func getTrip(byId id: String) -> Trip? {
        let realm = try! Realm()

        if let trip = realm.object(ofType: Trip.self, forPrimaryKey: id) {
            return trip
        } else {
            return nil
        }
    }
    
    func getUndeliveredStops(trip: Trip) -> [Stop] {
        let realm = try! Realm()
        
        if let t = realm.object(ofType: Trip.self, forPrimaryKey: trip.id){
            return Array(t.stops.filter("delivery_status = %@", "pending"))
        }else{
            return [Stop]()
        }
    }
    
    func getNextStop(trip: Trip) -> Stop? {
        var stop = trip.stops.where { $0.delivery_status == "pending" && $0.warehouse == nil}.first
        if stop == nil {
            stop = trip.stops.where { $0.delivery_status == "pending"}.last
        }
        return stop
    }
    
    func getETA(trip: Trip, legTimes: [TimeInterval]) -> Date? {
        let realm = try! Realm()

        // Total time for the trip (in seconds)
        var totalTime: TimeInterval = 0

        // The current time is the starting point for the trip
        var currentTime = Date()

        // Determine which stops to process based on the trip status
        let stopsToProcess: [Stop]
        if trip.status == "ready" {
            stopsToProcess = Array(trip.stops) // Use all stops
        } else {
            stopsToProcess = trip.stops.filter { $0.delivery_status == "pending" } // Filter stops with delivery_status == "pending"
        }

        try! realm.write {
            // Iterate through the filtered stops
            for (index, stop) in stopsToProcess.enumerated() {
                // Iterate through each delivery at this stop
                for delivery in stop.deliveries {
                    // Assign the ETA for the delivery based on the current time and total time
                    delivery.eta = currentTime.addingTimeInterval(totalTime)
                    
                    // Add the delivery's service time to the total time
                    totalTime += delivery.serviceTime
                }

                // Calculate and assign the ETA for the stop
                stop.eta = currentTime.addingTimeInterval(totalTime)

                // Add the travel time to the next stop if there is one
                if index < legTimes.count {
                    totalTime += legTimes[index]
                }

                // Update the current time to reflect the cumulative total time
                currentTime = stop.eta ?? currentTime
            }
        }

        // Return the ETA of the last stop in the filtered list
        return stopsToProcess.last?.eta
    }

    //Seed data{
    func seedData(){
        //Seed stops data
        let warehouse = Warehouse()
        warehouse.id = "1"
        warehouse.name = "Test Warehouse"
        warehouse.latitude = 28.538336
        warehouse.longitude = -81.379234
        
        let line_items = [
            LineItem(
                id: "1",
                storage_type: StorageType(id:"1", uid: "Freez"),
                shipping_weight: 100.0,
                shipping_weight_unit: "kg"
            ),
            LineItem(
                id: "2",
                storage_type: StorageType(id:"2", uid: "Chilled"),
                shipping_weight: 50.5,
                shipping_weight_unit: "kg"
            ),
            LineItem(
                id: "3",
                storage_type: StorageType(id:"3", uid: "Dry"),
                shipping_weight: 70.2,
                shipping_weight_unit: "kg"
            )
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Format for 12-hour time with AM/PM
        formatter.locale = Locale(identifier: "en_US") // Set locale for consistent formatting
        formatter.timeZone = TimeZone.current // Use the current timezone
        
        
        let deliveries = [
            Delivery(
                id: "1",
                label: "Universal Studios Florida",
                start_time: formatter.date(from: "10:00 AM"),
                end_time: formatter.date(from: "12:00 PM"),
                serviceTime: 1800,
                contact_person: "John Doe",
                contact_phone_number: "+1 407-555-1234",
                status: "pending",
                direction: "out",
                line_items: [line_items[0], line_items[2]]
            ),
            Delivery(
                id: "2",
                label: "Walt Disney",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Alice Johnson",
                contact_phone_number: "+1 407-555-7890",
                status: "pending",
                direction: "out",
                line_items: [line_items[2]]
            ),
            Delivery(
                id: "3",
                label: "ICON Park",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Bob Brown",
                contact_phone_number: "+1 407-555-3456",
                status: "pending",
                direction: "out",
                line_items: [line_items[0], line_items[1]]
            ),
            Delivery(
                id: "4",
                label: "SeaWorld Orlando",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Charlie Green",
                contact_phone_number: "+1 407-555-0001",
                status: "pending",
                direction: "out",
                line_items: [line_items[0], line_items[1], line_items[2]]
            ),
            Delivery(
                id: "5",
                label: "Baxters",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Dana Blue",
                contact_phone_number: "+1 407-555-0002",
                status: "pending",
                direction: "out",
                line_items: [line_items[0], line_items[2]]
            ),
            Delivery(
                id: "6",
                label: "Baxters",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Dana Blue",
                contact_phone_number: "+1 407-555-0002",
                status: "pending",
                direction: "out",
                line_items: [line_items[0], line_items[2]]
            ),
            Delivery(
                id: "7",
                label: "Walt Disney",
                start_time: nil,
                end_time: nil,
                serviceTime: 1800,
                contact_person: "Alice Johnson",
                contact_phone_number: "+1 407-555-7890",
                status: "pending",
                direction: "in",
                line_items: [line_items[2]]
            )
        ]
        
        
        let stops = [
            Stop(
                id: "1",
                latitude: 28.538336,
                longitude: -81.379234,
                order: 0,
                name: "Orlando Warehouse",
                address_line_1: "123 Warehouse St, Orlando, FL 32801",
                delivery_status: "pending",
                warehouse: warehouse,
                deliveries: nil
            ),
            Stop(
                id: "2",
                latitude: 28.474321,
                longitude: -81.467819,
                order: 1,
                name: "Orlando Mall",
                address_line_1: "6000 Universal Blvd, Orlando, FL 32819",
                delivery_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[0], deliveries[1], deliveries[6]]
            ),
            Stop(
                id: "3",
                latitude: 28.385233,
                longitude: -81.563874,
                order: 2,
                name: "Walt Disney World",
                address_line_1: "Lake Buena Vista, Orlando, FL 32830",
                delivery_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[2]]
            ),
            Stop(
                id: "4",
                latitude: 28.437369,
                longitude: -81.470148,
                order: 3,
                name: "ICON Park",
                address_line_1: "8375 International Dr, Orlando, FL 32819",
                delivery_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[3]]
            ),
            Stop(
                id: "5",
                latitude: 28.500000,
                longitude: -81.380000,
                order: 4,
                name: "Florida Mall",
                address_line_1: "8001 S Orange Blossom Trl, Orlando, FL 32809",
                delivery_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[4], deliveries[5]]
            ),
            Stop(
                id: "6",
                latitude: 28.538336,
                longitude: -81.379234,
                order: 5,
                name: "Orlando Warehouse",
                address_line_1: "123 Warehouse St, Orlando, FL 32801",
                delivery_status: "pending",
                warehouse: warehouse,
                deliveries: nil
            )
        ]
        
        let trip = Trip(id: "1", name: "Trip 2", route_name: "Sharm El Sheikh", stops: stops, status: "ready")
        
        let shift = DeliveryShift()
        shift.id = "1"
            
        shift.start_time = formatter.date(from: "10:00 AM")
        shift.end_time = formatter.date(from: "02:30 PM")
        
        trip.delivery_shift = shift
        
        let manager = TripManager()
        manager.deleteAllTrips()
        manager.addTrip(trip: trip)
    }
}
