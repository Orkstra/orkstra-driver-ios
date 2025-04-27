//
//  TripViewHelper.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 04/04/2025.
//

import UIKit

class TripViewHelper: NSObject {
    
    func setupMapContainerView(viewController: TripViewController){
        viewController.mapContainerView?.delegate = viewController // Set self as the delegate
        viewController.mapContainerView?.trip = viewController.trip
        viewController.mapContainerView?.selectedStop = viewController.selectedStop
        viewController.mapContainerView?.setupGoogleMap()
        viewController.mapContainerView?.drawRoute()
    }
    
    func setupStopView(viewController: TripViewController) -> StopCell{
        var stopView = StopCell()
        //stop
        let nib = UINib(nibName: "StopView", bundle: nil)
        if let cell = nib.instantiate(withOwner: nil, options: nil).first as? StopCell {
            stopView = cell
            stopView.frame = CGRect(x: 10, y: -1 * stopView.frame.height, width: viewController.view.frame.width - 20, height: stopView.frame.height)
        }
        
        // Add shadow
        stopView.layer.shadowColor = UIColor.black.cgColor  // Shadow color
        stopView.layer.shadowOpacity = 0.3                 // Opacity (0 to 1)
        stopView.layer.shadowOffset = CGSize(width: 0, height: 0) // No offset
        stopView.layer.shadowRadius = 6                    // Spread of the shadow
        
        stopView.isHidden = true
        
        stopView.delegate = viewController
        viewController.view.addSubview(stopView)
        
        return stopView
    }
    
    func setupTripTrackingView(viewController: TripViewController) -> TripCell{
        var tripCell = TripCell()
        //stop
        let nib = UINib(nibName: "TripTrackingCell", bundle: nil)
        if let cell = nib.instantiate(withOwner: nil, options: nil).first as? TripCell {
            tripCell = cell
            tripCell.frame = CGRect(x: 10, y: -1 * tripCell.frame.height, width: viewController.view.frame.width - 20, height: tripCell.frame.height)
        }
        
        // Add shadow
        tripCell.layer.shadowColor = UIColor.black.cgColor  // Shadow color
        tripCell.layer.shadowOpacity = 0.3                 // Opacity (0 to 1)
        tripCell.layer.shadowOffset = CGSize(width: 0, height: 0) // No offset
        tripCell.layer.shadowRadius = 6                    // Spread of the shadow
        
        tripCell.isHidden = true
        
        tripCell.trip = viewController.trip
        tripCell.tripViewController = viewController
        viewController.view.addSubview(tripCell)
        
        return tripCell
    }
    
    func setupTripDetailsView(viewController: TripViewController) -> TripDetailView{
        var tripDetailView = TripDetailView()
        //TripDetailsView
        let nib = UINib(nibName: "TripDetailView", bundle: nil)
        if let cell = nib.instantiate(withOwner: nil, options: nil).first as? TripDetailView {
            tripDetailView = cell
            tripDetailView.frame = CGRect(x: 10, y: viewController.view.frame.height - 235, width: viewController.view.frame.width - 20, height: viewController.view.frame.height - 50)
        }
        
        // Add shadow
        tripDetailView.layer.shadowColor = UIColor.black.cgColor  // Shadow color
        tripDetailView.layer.shadowOpacity = 0.3                 // Opacity (0 to 1)
        tripDetailView.layer.shadowOffset = CGSize(width: 0, height: 0) // No offset
        tripDetailView.layer.shadowRadius = 6                    // Spread of the shadow
        
        tripDetailView.delegate = viewController
        tripDetailView.selectedStop = viewController.selectedStop
        tripDetailView.trip = viewController.trip
        tripDetailView.tripViewController = viewController
        tripDetailView.tableView?.isScrollEnabled = false
        
        viewController.view.addSubview(tripDetailView)
        
        return tripDetailView
        
    }
}

