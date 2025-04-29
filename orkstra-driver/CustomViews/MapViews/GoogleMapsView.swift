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
    private var smoothedBearing: CLLocationDirection = 0
    
    
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
        locationManager.distanceFilter = 10 // Only update if the device moves 10 meters
        
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
            
            // Fetch the route
            fetchRoute(from: origin, to: destination, waypoints: waypoints) { [weak self] path, legTimes in
                guard let self = self, let path = path else { return }
                
                DispatchQueue.main.async {
                    // Draw the polyline
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 3.0
                    polyline.strokeColor = AppColors.trip
                    polyline.map = self.mapView
                    
                    // Print total duration if available
                    if let legTimes = legTimes {
                        self.delegate?.recalculatedTravelTime(legTimes: legTimes)
                    }
                    
                    // Add custom markers for all stops
                    self.updateMarkers()
                    
                    // Adjust the camera to fit the entire route
                    self.updateCameraToFitRoute(path: path)
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
    
    // Helper to parse duration strings (e.g., "5725s")
    private func parseDuration(_ durationString: String) -> Int {
        return Int(durationString.replacingOccurrences(of: "s", with: "")) ?? 0
    }
    
    // Adjust the camera to fit the route
    func updateCameraToFitRoute(path: GMSPath) {
        var bounds = GMSCoordinateBounds()
        
        // Include each coordinate in the bounds
        for index in 0..<path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        // Animate the camera to fit the bounds
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0) // Add padding around the edges
        mapView.animate(with: update)
    }
    
    func zoomToCurrentLocation() {
        // Validate truck's position
        if let truckPosition = truckMarker?.position, isValidCoordinate(truckPosition) {
            // Move the camera to the truck's location
            let cameraUpdate = GMSCameraUpdate.setTarget(truckPosition, zoom: 15)
            mapView.animate(with: cameraUpdate)
        } else if let userLocation = locationManager.location?.coordinate, isValidCoordinate(userLocation) {
            // Default to the user's location if the truck's location is not valid
            let cameraUpdate = GMSCameraUpdate.setTarget(userLocation, zoom: 15)
            mapView.animate(with: cameraUpdate)
        } else {
            // If no valid location is available, show an alert or log an error
            print("No valid location available")
        }
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
        
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50) // padding to ensure markers are not at the edges
        mapView.animate(with: cameraUpdate)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    // Update the location of the truck marker
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        // Ensure significant movement before updating
        guard hasSignificantMovement(from: previousLocation, to: currentLocation) else {
            print("Stationary: Skipping bearing update")
            return
        }

        // Snap the current location to the nearest road
        snapToRoads(location: currentLocation) { [weak self] snappedLocation, _ in
            guard let self = self, let snappedLocation = snappedLocation else { return }

            DispatchQueue.main.async {
                // Move the truck marker to the snapped location
                self.moveMarker(marker: self.truckMarker, to: snappedLocation)

                if self.trip?.status != "ready" {
                    // Calculate the bearing between the previous and current snapped point
                    if let previousLocation = self.previousLocation {
                        let bearing = self.calculateBearing(
                            from: previousLocation.coordinate,
                            to: snappedLocation
                        )
                        self.updateFlashlightBearing(newBearing: bearing)
                    } else {
                        // If there's no previous location, keep the current flashlight rotation
                        print("No previous location. Retaining current flashlight rotation.")
                    }
                }

                // Update the previous location for the next calculation
                self.previousLocation = CLLocation(latitude: snappedLocation.latitude, longitude: snappedLocation.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let trip = trip else { return } // Ensure trip exists

        if trip.status == "ready" {
            let heading = newHeading.trueHeading

            // Smoothly animate the rotation
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2) // Set a short animation duration
            flashlightMarker?.rotation = heading // Rotate based on phone's heading
            CATransaction.commit()
        }
    }
    /// Snap the given location to the nearest road using the Google Roads API
    func snapToRoads(location: CLLocation, completion: @escaping (CLLocationCoordinate2D?, CLLocationDirection?) -> Void) {
        let urlString = "https://roads.googleapis.com/v1/snapToRoads?path=\(location.coordinate.latitude),\(location.coordinate.longitude)&key=\(GMSServicesApiKey)&interpolate=true"

        guard let url = URL(string: urlString) else {
            print("Invalid Roads API URL")
            completion(nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Snap to Roads API Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil)
                return
            }

            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let snappedPoints = json["snappedPoints"] as? [[String: Any]] {

                    // Extract the first snapped location
                    guard let firstLocation = snappedPoints.first?["location"] as? [String: Any],
                          let latitude = firstLocation["latitude"] as? CLLocationDegrees,
                          let longitude = firstLocation["longitude"] as? CLLocationDegrees else {
                        print("Failed to extract snapped location")
                        completion(nil, nil)
                        return
                    }

                    // Calculate the bearing using consecutive snapped points
                    var bearing: CLLocationDirection? = nil
                    if snappedPoints.count > 1 {
                        let firstPoint = snappedPoints[0]["location"] as? [String: CLLocationDegrees]
                        let secondPoint = snappedPoints[1]["location"] as? [String: CLLocationDegrees]
                        if let firstLat = firstPoint?["latitude"], let firstLng = firstPoint?["longitude"],
                           let secondLat = secondPoint?["latitude"], let secondLng = secondPoint?["longitude"] {
                            bearing = self.calculateBearing(
                                from: CLLocationCoordinate2D(latitude: firstLat, longitude: firstLng),
                                to: CLLocationCoordinate2D(latitude: secondLat, longitude: secondLng)
                            )
                        }
                    }

                    // Return the snapped location and bearing
                    completion(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), bearing)
                } else {
                    print("Failed to parse Snap to Roads response")
                    completion(nil, nil)
                }
            } catch {
                print("Error parsing Snap to Roads response: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
    
    func updateBearing(newBearing: CLLocationDirection) {
        // Apply a low-pass filter to smooth the bearing
        smoothedBearing = (0.8 * smoothedBearing) + (0.2 * newBearing)
        self.truckMarker?.rotation = smoothedBearing
    }
    
    // MARK: - Helper Methods
    
    /// Check if the movement is significant (distance or speed threshold)
    func hasSignificantMovement(from previousLocation: CLLocation?, to currentLocation: CLLocation) -> Bool {
        guard let previousLocation = previousLocation else { return true } // First update
        
        // Calculate the distance between the two locations (in meters)
        let distance = currentLocation.distance(from: previousLocation)
        
        // Check the speed (in m/s) and distance (e.g., threshold > 5 meters)
        return currentLocation.speed > 1.0 || distance > 5.0
    }
    
    /// Move the marker smoothly to the specified position
    func moveMarker(marker: GMSMarker?, to position: CLLocationCoordinate2D) {
        guard marker != nil else { return }
        
        // Begin a smooth animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0) // Smooth animation duration
        
        // Move the marker to the new position
        truckMarker?.position = position
        flashlightMarker?.position = position
        
        CATransaction.commit()
    }
    
    /// Helper function to validate coordinates
    private func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
    
    func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = (end.longitude - start.longitude).radians
        let startLatitude = start.latitude.radians
        let endLatitude = end.latitude.radians

        let y = sin(deltaLongitude) * cos(endLatitude)
        let x = cos(startLatitude) * sin(endLatitude) - sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)

        let bearing = atan2(y, x).degrees // Convert radians to degrees
        let normalizedBearing = (bearing + 360).truncatingRemainder(dividingBy: 360) // Normalize to 0-360 degrees

        // Debugging: Log the bearing calculation
        print("Start: (\(start.latitude), \(start.longitude)) | End: (\(end.latitude), \(end.longitude)) | Bearing: \(bearing)° | Normalized: \(normalizedBearing)°")
        
        return normalizedBearing
    }

    func updateFlashlightBearing(newBearing: CLLocationDirection) {
        // Reduce the influence of the previous smoothed bearing for faster response
        smoothedBearing = (0.9 * newBearing) + (0.1 * smoothedBearing)

        // Apply the smoothed rotation to the flashlight marker
        flashlightMarker?.rotation = smoothedBearing

        // Debugging: Log the bearing and rotation
        print("Original Bearing: \(newBearing)° | Smoothed Bearing: \(smoothedBearing)°")
    }
}

extension Double {
    /// Convert degrees to radians
    var radians: Double {
        return self * .pi / 180.0
    }
    
    /// Convert radians to degrees
    var degrees: Double {
        return self * 180.0 / .pi
    }
}
