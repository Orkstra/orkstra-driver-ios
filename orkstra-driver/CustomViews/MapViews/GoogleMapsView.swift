//
//  GoogleMapsView.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import GoogleMaps
import RealmSwift

protocol CustomMapViewDelegate: AnyObject {
    func didTapMarker(stop: Stop?)
    func didTapOutsideMarker()
    func recalculatedTravelTime(legTimes: [TimeInterval])
}

class GoogleMapsView: UIView, GMSMapViewDelegate{
    
    weak var delegate: CustomMapViewDelegate? // Delegate property
    
    private var mapView: GMSMapView! // The actual Google Maps view
    private var markers: [GMSMarker] = []
    var trip: Trip?
    
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
        
        //Get stops
        if let stops = trip?.stops { // Safely unwrap the optional
            for (index, stop) in stops.enumerated() {
                let position = CLLocationCoordinate2D(latitude: stop.latitude ?? 0.0, longitude: stop.longitude ?? 0.0)

                // Create the marker
                let marker = GMSMarker(position: position)
                marker.title = stop.label // Use the label from the Stop model
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
                    if stop.shipment_status == "delivered"{
                        marker.icon = markerManager.createDeliveredMarker(with: UIImage(systemName: "checkmark") ?? UIImage(), selected: selected)
                    } else {
                        marker.icon = markerManager.createStopMarker(stop: stop, selected: selected) // Numbered marker for intermediate stops
                    }
                }
                
                if index == 0 && stop.label == stops.last?.label{
                   //Do nothing
                } else {
                    marker.map = mapView
                    markers.append(marker)
                }
            }
        }
        
    }
}

extension GoogleMapsView{
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
        mapView.isMyLocationEnabled = true

        //Apply custom styling
        applyMapStyle()
        
        // Add the mapView to the placeholder container
        self.addSubview(mapView)
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
    
    func zoomToCurrentLocation() {
        guard let location = mapView.myLocation else {
            print("User location unavailable.")
            return
        }

        let cameraUpdate = GMSCameraUpdate.setCamera(
            GMSCameraPosition(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 15  // Adjust zoom as desired
            )
        )
        mapView.animate(with: cameraUpdate)
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
}
