//
//  TripViewController.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import RealmSwift

class TripViewController: UIViewController, CustomMapViewDelegate, StopCellDelegate, TripDetailViewViewDelegate {
    
    @IBOutlet weak var myLocationBottom: NSLayoutConstraint?
    @IBOutlet weak var mapContainerView: GoogleMapsView?

    var stopView = StopCell()
    var tripDetailView = TripDetailView()
    var tripTrackingView = TripCell()
    var selectedStop: Stop?
    var tripId: String?
    
    var tripDetailsShowing = false{
        didSet{
            if tripDetailsShowing == false{
                tripDetailView.tableView?.isScrollEnabled = false
            }else{
                tripDetailView.tableView?.isScrollEnabled = true
            }
        }
    }
    
    private var trip = Trip()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Get Trip
        let tripManager = TripManager()
        trip = tripManager.getTrip(byId: tripId ?? "0") ?? Trip()
        
        //Setup Views
        setupViews()
        self.view.layoutIfNeeded()
    }

    // CustomMapViewDelegate methods
    func didTapMarker(stop: Stop?) {
        selectedStop = stop
        //Notify Stop Detail
        stopView.stop = selectedStop
        
        //Show stop view if hidden
        if tripDetailsShowing == false{
            showStopDetails()
        }
        
        //Show summary view if hidden
        if tripTrackingView.isHidden == true{
            showTripSummary()
        }
    }
    
    func didTapOutsideMarker() {
        selectedStop = nil
        hideStopDetails()
        tripDetailView.trip? = trip
        tripDetailView.tableView?.reloadData()
    }
    
    //Stop View methods
    func StopCellDidSwipeUp() {
        hideStopDetails{
            self.selectedStop = nil
            //Notify Map Container View
            self.mapContainerView?.selectMarker(stop: nil)
        }
    }
    
    //TripDetail View methods
    func tripDetailViewDidSSelectRow(stop: Stop?) {
        if stop != nil{
            selectedStop = stop
            //Notify Map container view
            mapContainerView?.selectMarker(stop: stop)
        }else{
            hideStopDetails{
                self.selectedStop = nil
                //Notify Map Container View
                self.mapContainerView?.selectMarker(stop: nil)
            }
        }
    }
    
    func tripDetailViewDidSwipeUp() {
        hideStopDetails()
        showTripDetails()
    }
    
    func tripDetailViewDidSwipeDown() {
        hideTripDetails()
        if selectedStop != nil{
            showStopDetails()
        }
    }
    
    //My location button click
    @IBAction func didClickMyLocation(sender: UIButton){
        mapContainerView?.zoomToCurrentLocation()
    }
    
    //Zoom to markers button click
    @IBAction func didClickZoomToFit(sender: UIButton){
        mapContainerView?.zoomToFitAllMarkers()
    }
    
    //Close button Click
    @IBAction func didClickCloseBtn(sender: UIButton){
        selectedStop = nil
        stopView.removeFromSuperview()
        tripDetailView.removeFromSuperview()
        
        let tripManager = TripManager()
        tripManager.seedData()
        //Get Trip
        trip = tripManager.getTrip(byId: tripId ?? "0") ?? Trip()
        
        //Setup Views
        setupViews()
        self.view.layoutIfNeeded()
    }
}


extension TripViewController{
    //Setup function
    func setupViews(){
        
        if trip.status != "ready"{
            selectedStop = trip.stops.where { $0.shipment_status != "delivered" && $0.warehouse == nil}.first
        }
        
        let helper = TripViewHelper()
        stopView = helper.setupStopView(viewController: self)
        stopView.delegate = self
        self.view.addSubview(stopView)
        
        tripTrackingView = helper.setupTripTrackingView(viewController: self)
        tripTrackingView.trip = trip
        tripTrackingView.tripViewController = self
        self.view.addSubview(tripTrackingView)
        
        tripDetailView = helper.setupTripDetailsView(viewController: self)
        tripDetailView.selectedStop = selectedStop
        tripDetailView.trip = trip
        tripDetailView.tripViewController = self
        tripDetailView.delegate = self
        tripDetailView.tableView?.isScrollEnabled = false
        self.view.addSubview(tripDetailView)
        myLocationBottom?.constant = 155
        
        //Setup Map View
        mapContainerView?.trip = trip
        mapContainerView?.selectedStop = selectedStop
        mapContainerView?.delegate = self // Set self as the delegate
        mapContainerView?.setupGoogleMap()
        mapContainerView?.drawRoute()
        
        //Show view if not nil
        if selectedStop != nil{
            showStopDetails()
            mapContainerView?.selectMarker(stop: selectedStop)
        }
    }
    
    //Hide and show functions
    
    func showTripSummary(){
        if trip.status != "ready"{
            //Show the data
            if tripTrackingView.isHidden == true{
                //Reset location
                tripTrackingView.frame.origin.y = -1 * self.tripTrackingView.frame.height
                tripTrackingView.isHidden = false
                
                //Show view with animation
                UIView.animate(withDuration: 0.5, animations: {
                    self.tripTrackingView.frame.origin.y = 50
                })
            }
        }
    }
    
    func hideTripSummary(completion: (() -> Void)? = nil) {
        if tripTrackingView.isHidden == false{
            UIView.animate(withDuration: 0.5, animations: {
                self.tripTrackingView.frame.origin.y = -1 * self.tripTrackingView.frame.height
            }, completion: { (finished: Bool) in
                self.tripTrackingView.isHidden = true
                completion?() // Immediately notify if no animation needed
            })
        } else {
            completion?() // Immediately notify if no animation needed
        }
    }
    
    func showStopDetails(){
        if trip.status == "ready"{
            //Show the data
            if stopView.isHidden == true && selectedStop != nil{
                //Reset location
                stopView.frame.origin.y = -1 * self.stopView.frame.height
                stopView.isHidden = false
                
                //Show view with animation
                UIView.animate(withDuration: 0.5, animations: {
                    self.stopView.frame.origin.y = 50
                })
            }
        }
    }
    
    func hideStopDetails(completion: (() -> Void)? = nil) {
        if stopView.isHidden == false{
            UIView.animate(withDuration: 0.5, animations: {
                self.stopView.frame.origin.y = -1 * self.stopView.frame.height
            }, completion: { (finished: Bool) in
                self.stopView.isHidden = true
                completion?() // Immediately notify if no animation needed
            })
        } else {
            completion?() // Immediately notify if no animation needed
        }
    }
    
    func showTripDetails(){
        tripDetailView.selectedStop = selectedStop
        tripDetailView.tableView?.reloadData()
        if tripDetailsShowing == false{
            UIView.animate(withDuration: 0.5, animations: {
                self.tripDetailView.frame.origin.y = 50
            }, completion: { (finished: Bool) in
                self.tripDetailsShowing = true
            })
        }
    }
    
    func hideTripDetails(){
        if tripDetailsShowing == true{
            tripDetailView.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            UIView.animate(withDuration: 0.5, animations: {
                self.tripDetailView.frame.origin.y = self.view.frame.height - 175
            }, completion: { (finished: Bool) in
                self.tripDetailsShowing = false
            })
        }
    }
}
