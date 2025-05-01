//
//  GoogleMapsView.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import MapKit
import Foundation

protocol CustomMapViewDelegate: AnyObject {
    func didTapMarker(stop: Stop?)
    func didTapOutsideMarker()
    func recalculatedTravelTime(legTimes: [TimeInterval])
}

class GoogleMapsView: UIView, GMSMapViewDelegate, CLLocationManagerDelegate{
    
    weak var delegate: CustomMapViewDelegate? // Delegate property
    
    var mapView: GMSMapView! // The actual Google Maps view
    
    private var locationManager = CLLocationManager()
    private var previousLocation: CLLocation?       // Track the previous location for bearing calculation
    private var markers: [GMSMarker] = []
    private var smoothedBearing: CLLocationDirection = 0.2
    private let smoothingFactor: Double = 0.2
    private let movementThreshold: CLLocationDistance = 5.0 // meters
    
    var mapPolylines: [GMSPolyline] = []
    
    var trip: Trip?
    var truckMarker: GMSMarker?
    var flashlightMarker: GMSMarker?
    var selectedStop: Stop?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // GMSMapViewDelegate method to detect marker taps
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if trip?.status == "ready"{
            //Change Marker Color
            let stopManager = StopManager()
            selectedStop = stopManager.getStop(byId: marker.userData as! String)
            updateMarkers()
            
            // Notify the delegate
            delegate?.didTapMarker(stop: selectedStop)
            
            // Center the map on the marker
            //let cameraUpdate = GMSCameraUpdate.setTarget(marker.position)
            //mapView.animate(with: cameraUpdate)
        }
        
        return true // Return false to keep default behavior (e.g., showing info window)
    }
    
    // GMSMapViewDelegate method to detect tap outside of marker
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if trip?.status == "ready"{
            //Update markers
            selectedStop = nil
            updateMarkers()
            
            // Notify the delegate
            delegate?.didTapOutsideMarker()
        }
    }
    
    // Select Marker
    func selectMarker(stop: Stop?){
        selectedStop = stop
        updateMarkers()
        
        // Notify the delegate
        delegate?.didTapMarker(stop: selectedStop)
    }
    
    //Draw markers to route
    private func updateMarkers() {
        //Clear all markers
        for marker in markers {
            marker.map = nil // Removes the marker from the map
        }
        markers.removeAll() // Clear the markers array
        
        reinitializeTruckMarker()
        
        //Get stops
        if let stops = trip?.stops { // Safely unwrap the optional
            for (index, stop) in stops.enumerated() {
                let position = CLLocationCoordinate2D(latitude: stop.latitude ?? 0.0, longitude: stop.longitude ?? 0.0)

                // Create the marker
                let marker = GMSMarker(position: position)
                marker.title = stop.name // Use the label from the Stop model
                marker.userData = stop.id
                marker.snippet = "Order: \(stop.order ?? 0)" // Optional snippet showing the order
                
                let markerManager = MarkerManager()
                // Check if this is the start (first stop) or the last stop
                if stop.warehouse != nil{
                    var selected = false
                    if selectedStop != nil && selectedStop?.id == stop.id {selected = true}
                    marker.icon = markerManager.createHomeMarker(with: UIImage(named: "warehouse") ?? UIImage(), selected: selected)  // Special marker for the start and last stop
                } else {
                    var selected = false
                    if selectedStop != nil && selectedStop?.id == stop.id {selected = true}
                    if stop.delivery_status == "delivered"{
                        marker.icon = markerManager.createDeliveredMarker(with: UIImage(systemName: "checkmark") ?? UIImage(), selected: selected)
                    } else {
                        marker.icon = markerManager.createStopMarker(stop: stop, selected: selected) // Numbered marker for intermediate stops
                    }
                }
                
                if index == 0 && stop.name == stops.last?.name{
                   //Do nothing
                } else {
                    marker.map = mapView
                    markers.append(marker)
                }
            }
        }
        
    }

    // Set up the GMSMapView and replace the placeholder UIView
    func setupGoogleMap() {
        // Set an initial camera position (latitude, longitude, zoom level)
        let camera = GMSCameraPosition.camera(withLatitude: currentUser.warehouse?.latitude ?? 0.0, longitude: currentUser.warehouse?.longitude ?? 0.0, zoom: 12.0)
        
        // Initialize the map view
        mapView = GMSMapView()
        mapView.delegate = self
        mapView.frame = self.bounds
        mapView.camera = camera
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Show user's location
        mapView.isMyLocationEnabled = false
        
        //Apply custom styling
        applyMapStyle()
        
        // Add the mapView to the placeholder container
        self.addSubview(mapView)
        
        // Initialize the location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Adjust accuracy as needed
        locationManager.distanceFilter = 5 // Only update if the device moves 5 meters
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // Add a custom truck marker
        let markerManager = MarkerManager()
        let image: UIImage = UIImage(systemName: "truck.box.fill") ?? UIImage()
        truckMarker = markerManager.createTruckMarker(with: image)
        truckMarker?.map = mapView
        
        flashlightMarker = markerManager.setupFlashlightMarker(at: truckMarker!.position)
        flashlightMarker?.map = mapView
    }
    
    func reinitializeTruckMarker(){
        // Reinitialize the truck marker
        if truckMarker == nil {
            let markerManager = MarkerManager()
            let image: UIImage = UIImage(systemName: "truck.box.fill") ?? UIImage()
            truckMarker = markerManager.createTruckMarker(with: image)
            truckMarker?.map = mapView
            
            flashlightMarker = markerManager.setupFlashlightMarker(at: truckMarker!.position)
            flashlightMarker?.map = mapView
        }
        
        if let lastLocation = locationManager.location {
            // Call the method with the last known location
            locationManager(locationManager, didUpdateLocations: [lastLocation])
        } else {
            // If no location exists, call it with an empty array
            locationManager(locationManager, didUpdateLocations: [])
        }
    }
    
    //Apply Map Style
    private func applyMapStyle() {
        // Find the path to the mapStyle.json file in your bundle
        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
            do {
                // Apply the style to the map
                let mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                mapView.mapStyle = mapStyle
            } catch {
                print("Error applying map style: \(error)")
            }
        } else {
            print("Unable to find mapStyle.json")
        }
    }
    
    func zoomToCurrentLocation() {
        guard let truckPosition = truckMarker?.position, isValidCoordinate(truckPosition) else {
            print("No valid truck position")
            return
        }

        // Create artificial bounds around the truck position
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(truckPosition)

        // Add dummy coordinates slightly around the truck to simulate area
        let delta: CLLocationDegrees = 0.002  // ~200 meters, adjust as needed
        let paddingCoordinates = [
            CLLocationCoordinate2D(latitude: truckPosition.latitude + delta, longitude: truckPosition.longitude + delta),
            CLLocationCoordinate2D(latitude: truckPosition.latitude - delta, longitude: truckPosition.longitude - delta),
            CLLocationCoordinate2D(latitude: truckPosition.latitude + delta, longitude: truckPosition.longitude - delta),
            CLLocationCoordinate2D(latitude: truckPosition.latitude - delta, longitude: truckPosition.longitude + delta)
        ]

        for coord in paddingCoordinates {
            bounds = bounds.includingCoordinate(coord)
        }

        // Apply UI insets to account for overlay views
        let topPadding: CGFloat = 150
        let bottomPadding: CGFloat = 294
        let leftPadding: CGFloat = 50
        let rightPadding: CGFloat = 50

        let insets = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)

        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.animate(with: update)
    }

    
    //Zoom to fit all markers on the map
    func zoomToFitAllMarkers() {
        guard !markers.isEmpty else {
            print("No markers available to fit.")
            return
        }
        
        var bounds = GMSCoordinateBounds()
        
        for marker in markers {
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        // Calculate padding
        let topPadding: CGFloat = 50
        let bottomPadding: CGFloat = 294 // Height of your UIView + desired buffer
        let leftPadding: CGFloat = 50
        let rightPadding: CGFloat = 50

        let insets = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        
        // Animate the camera with visible region accounted for
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.animate(with: update)
    }
    
    // MARK: Routing functions
    
    // Draw a route on the map
    func drawRoute() {
        // Get Stops
        if let stops = trip?.stops {
            let sortedStops = Array(stops)
            
            if sortedStops.isEmpty {
                print("Not enough stops to draw a route.")
                return
            }
            
            // Use the first stop as the origin
            let origin = CLLocationCoordinate2D(
                latitude: sortedStops.first!.latitude ?? 0.0,
                longitude: sortedStops.first!.longitude ?? 0.0
            )
            
            // Use the last stop as the destination
            let destination = CLLocationCoordinate2D(
                latitude: sortedStops.last!.latitude ?? 0.0,
                longitude: sortedStops.last!.longitude ?? 0.0
            )
            
            // Use the intermediate stops as waypoints
            let waypoints = sortedStops.dropFirst().dropLast().map {
                CLLocationCoordinate2D(latitude: $0.latitude ?? 0.0, longitude: $0.longitude ?? 0.0)
            }
            
            //Clear the polyline array
            mapPolylines = []
            
            // Fetch the route
            fetchRoute(from: origin, to: destination, waypoints: waypoints) { [weak self] path, legTimes in
                guard let self = self, let path = path else { return }
                
                DispatchQueue.main.async {
                    // Draw the polyline
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 3.0
                    polyline.strokeColor = AppColors.trip
                    polyline.map = self.mapView
                    
                    self.mapPolylines.append(polyline) // Track the polyline
                    
                    // Print total duration if available
                    if let legTimes = legTimes {
                        self.delegate?.recalculatedTravelTime(legTimes: legTimes)
                    }
                    
                    // Add custom markers for all stops
                    self.updateMarkers()
                    
                    // Adjust the camera to fit the entire route
                    self.zoomToFitAllMarkers()
                    
                    //Simulation Karim
                    //self.simulateTruckMovementFromFirstStop()
                }
            }
        }
    }
    
    // Fetch the route using Google Maps Routes API
    private func fetchRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D],
        completion: @escaping (GMSPath?, [TimeInterval]?) -> Void
    ) {
        // Routes API endpoint
        let routesURL = "https://routes.googleapis.com/directions/v2:computeRoutes"
        let key = GMSServicesApiKey
        
        // Create origin and destination dictionaries
        let originDict: [String: Any] = [
            "location": [
                "latLng": [
                    "latitude": origin.latitude,
                    "longitude": origin.longitude
                ]
            ]
        ]
        let destinationDict: [String: Any] = [
            "location": [
                "latLng": [
                    "latitude": destination.latitude,
                    "longitude": destination.longitude
                ]
            ]
        ]
        
        // Create waypoints array
        let waypointDicts: [[String: Any]] = waypoints.map {
            [
                "location": [
                    "latLng": [
                        "latitude": $0.latitude,
                        "longitude": $0.longitude
                    ]
                ]
            ]
        }
        
        // Define truck-specific parameters
        let vehicleInfo: [String: Any] = [
            "emissionsType": "GASOLINE",
            "vehicleHeightMeters": 4.0,
            "vehicleWidthMeters": 2.5,
            "vehicleLengthMeters": 12.0,
            "vehicleWeightKilograms": 20000,
            "hasTrailers": false,
            "hazardousMaterials": false
        ]
        
        // Build the request body
        let requestBody: [String: Any] = [
            "origin": originDict,
            "destination": destinationDict,
            "intermediates": waypointDicts,
            "travelMode": "TRUCK",
            "routingPreference": "TRAFFIC_AWARE",
            //"vehicleInfo": vehicleInfo
            "computeAlternativeRoutes": false
        ]
        
        // Convert the request body to JSON
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to encode request body")
            completion(nil, nil)
            return
        }
        
        // Build the request
        var request = URLRequest(url: URL(string: "\(routesURL)?key=\(key)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline,routes.legs.duration", forHTTPHeaderField: "X-Goog-FieldMask")
        request.httpBody = requestData
        
        // Perform the API request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching route: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil)
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   !routes.isEmpty,
                   let firstRoute = routes.first,
                   let polyline = firstRoute["polyline"] as? [String: Any],
                   let encodedPolyline = polyline["encodedPolyline"] as? String,
                   let legs = firstRoute["legs"] as? [[String: Any]] {
                    
                    // Extract leg durations
                    var legDurations: [TimeInterval] = []
                    for leg in legs {
                        if let durationString = leg["duration"] as? String {
                            // Parse the duration string (e.g., "987s") into seconds
                            let durationValue = TimeInterval(durationString.replacingOccurrences(of: "s", with: "")) ?? 0
                            legDurations.append(durationValue)
                        } else {
                            print("Leg duration is missing or invalid.")
                        }
                    }
                    
                    // Extract total distance (optional, for debugging)
                    let distance = firstRoute["distanceMeters"] as? Int ?? 0
                    print("Route Distance: \(distance) meters")
                    
                    // Convert polyline to a GMSPath
                    let path = GMSPath(fromEncodedPath: encodedPolyline)
                    completion(path, legDurations)
                } else {
                    print("No valid routes found in response.")
                    completion(nil, nil)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    // Handle location updates with snapping and animation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if let previous = previousLocation, currentLocation.distance(from: previous) < 1.0 {
            print("Stationary: Skipping update")
            return
        }

        let bearing = previousLocation.map {
            getBearing(from: $0.coordinate, to: currentLocation.coordinate)
        }

        moveTruckAndFlashlight(to: currentLocation.coordinate, withBearing: bearing)

        previousLocation = currentLocation
    }



    // Handle heading updates only when trip is in 'ready' state (compass mode)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard trip?.status == "ready" else { return }

        let heading = newHeading.trueHeading

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        flashlightMarker?.rotation = heading
        CATransaction.commit()
    }
    
    // Smoothly move and rotate the truck and flashlight markers
    func moveTruckAndFlashlight(to coordinate: CLLocationCoordinate2D, withBearing bearing: CLLocationDirection?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.5)

        truckMarker?.position = coordinate
        flashlightMarker?.position = coordinate

        if trip?.status != "ready", let bearing = bearing {
            flashlightMarker?.rotation = bearing
        }

        CATransaction.commit()
    }
    
    // MARK: - Helper Methods
    /// Helper function to validate coordinates
    private func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180
    }

    func getBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = start.latitude.degreesToRadians
        let lon1 = start.longitude.degreesToRadians
        let lat2 = end.latitude.degreesToRadians
        let lon2 = end.longitude.degreesToRadians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansBearing.radiansToDegrees.truncatingRemainder(dividingBy: 360)
    }

    // MARK: Simulations
    
    func simulateTruckMovementFromFirstStop() {
        guard let stops = trip?.stops, stops.count >= 2 else {
            print("Not enough stops to simulate.")
            return
        }

        let sortedStops = Array(stops)

        // Start at the first stop
        let simulatedStart = CLLocation(
            latitude: sortedStops[0].latitude ?? -180.0,
            longitude: sortedStops[0].longitude ?? -180.0
        )

        // Call didUpdateLocations with the simulated start location
        self.locationManager(self.locationManager, didUpdateLocations: [simulatedStart])

        // Start moving toward the next stop
        simulateMovementBetweenStops(stops: sortedStops, currentIndex: 0)
    }


    
    func simulateMovementBetweenStops(stops: [Stop], currentIndex: Int) {
        guard currentIndex < stops.count - 1 else {
            print("Simulation complete")
            return
        }
        
        let from = CLLocationCoordinate2D(latitude: stops[currentIndex].latitude ?? 0.0,
                                          longitude: stops[currentIndex].longitude ?? 0.0)
        let to = CLLocationCoordinate2D(latitude: stops[currentIndex + 1].latitude ?? 0.0,
                                        longitude: stops[currentIndex + 1].longitude ?? 0.0)
        
        let steps = 100
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard currentStep <= steps else {
                timer.invalidate()
                // Move to the next leg
                self.simulateMovementBetweenStops(stops: stops, currentIndex: currentIndex + 1)
                return
            }
            
            let fraction = Double(currentStep) / Double(steps)
            let lat = from.latitude + (to.latitude - from.latitude) * fraction
            let lng = from.longitude + (to.longitude - from.longitude) * fraction
            let simulatedLocation = CLLocation(latitude: lat, longitude: lng)
            
            self.locationManager(self.locationManager, didUpdateLocations: [simulatedLocation])
            
            currentStep += 1
        }
    }
    
}


extension CLLocationDegrees {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
}

extension CGFloat {
    var radiansToDegrees: CLLocationDegrees {
        return CLLocationDegrees(self * 180.0 / .pi)
    }
}
