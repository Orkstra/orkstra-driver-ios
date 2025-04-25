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
    @Persisted var status: String?
    //  Defining relationships
    @Persisted var stops = List<Stop>()
    
    // Primary Key
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Convenience initializer
    convenience init(id: String, name: String, stops: [Stop]?, status: String?) {
        self.init()
        self.id = id
        self.name = name
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

        // Write stops to Realm
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
            let allStorages = realm.objects(Storage.self)
            // Delete all storages
            realm.delete(allStorages)
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
                storage: Storage(id:"1", name: "Freez")
            ),
            LineItem(
                id: "2",
                storage: Storage(id:"2", name: "Chilled")
            ),
            LineItem(
                id: "3",
                storage: Storage(id:"3", name: "Dry")
            )
        ]
        
        let deliveries = [
            Delivery(
                id: "1",
                label: "Universal Studios Florida",
                time_slot: "08:00am - 10:00am",
                contact_person: "John Doe",
                contact_phone_number: "+1 407-555-1234",
                shipment_status: "pending",
                line_items: [line_items[0], line_items[2]]
            ),
            Delivery(
                id: "2",
                label: "Walt Disney",
                time_slot: nil,
                contact_person: "Alice Johnson",
                contact_phone_number: "+1 407-555-7890",
                shipment_status: "pending",
                line_items: [line_items[2]]
            ),
            Delivery(
                id: "3",
                label: "ICON Park",
                time_slot: nil,
                contact_person: "Bob Brown",
                contact_phone_number: "+1 407-555-3456",
                shipment_status: "pending",
                line_items: [line_items[0], line_items[1]]
            ),
            Delivery(
                id: "4",
                label: "SeaWorld Orlando",
                time_slot: "12:00pm - 01:00pm",
                contact_person: "Charlie Green",
                contact_phone_number: "+1 407-555-0001",
                shipment_status: "pending",
                line_items: [line_items[0], line_items[1], line_items[2]]
            ),
            Delivery(
                id: "5",
                label: "Baxters",
                time_slot: "12:00pm - 01:00pm",
                contact_person: "Dana Blue",
                contact_phone_number: "+1 407-555-0002",
                shipment_status: "pending",
                line_items: [line_items[0], line_items[2]]
            ),
            Delivery(
                id: "6",
                label: "Baxters",
                time_slot: "12:00pm - 01:00pm",
                contact_person: "Dana Blue",
                contact_phone_number: "+1 407-555-0002",
                shipment_status: "pending",
                line_items: [line_items[0], line_items[2]]
            )
        ]
        
        
        let stops = [
            Stop(
                id: "1",
                latitude: 28.538336,
                longitude: -81.379234,
                order: 0,
                label: "Orlando Warehouse",
                address_line_1: "123 Warehouse St, Orlando, FL 32801",
                shipment_status: "pending",
                warehouse: warehouse,
                deliveries: nil
            ),
            Stop(
                id: "2",
                latitude: 28.474321,
                longitude: -81.467819,
                order: 1,
                label: "Orlando Mall",
                address_line_1: "6000 Universal Blvd, Orlando, FL 32819",
                shipment_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[0], deliveries[1], deliveries[1]]
            ),
            Stop(
                id: "3",
                latitude: 28.385233,
                longitude: -81.563874,
                order: 2,
                label: "Walt Disney World",
                address_line_1: "Lake Buena Vista, Orlando, FL 32830",
                shipment_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[2]]
            ),
            Stop(
                id: "4",
                latitude: 28.437369,
                longitude: -81.470148,
                order: 3,
                label: "ICON Park",
                address_line_1: "8375 International Dr, Orlando, FL 32819",
                shipment_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[3]]
            ),
            Stop(
                id: "5",
                latitude: 28.500000,
                longitude: -81.380000,
                order: 4,
                label: "Florida Mall",
                address_line_1: "8001 S Orange Blossom Trl, Orlando, FL 32809",
                shipment_status: "pending",
                warehouse: nil,
                deliveries: [deliveries[4], deliveries[5]]
            ),
            Stop(
                id: "6",
                latitude: 28.538336,
                longitude: -81.379234,
                order: 5,
                label: "Orlando Warehouse",
                address_line_1: "123 Warehouse St, Orlando, FL 32801",
                shipment_status: "pending",
                warehouse: warehouse,
                deliveries: nil
            )
        ]
        
        let trip = Trip(id: "1", name: "Orlando East", stops: stops, status: "ready")
        
        
        let manager = TripManager()
        manager.deleteAllTrips()
        manager.addTrip(trip: trip)
    }
}
