//
//  GoogleMapsLocationManager.swift
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

extension GoogleMapsView {
    
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
}
