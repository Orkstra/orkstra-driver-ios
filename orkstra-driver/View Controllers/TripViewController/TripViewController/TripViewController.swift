//
//  TripViewController.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import RealmSwift

class TripViewController: UIViewController, CustomMapViewDelegate, StopCellDelegate, TripDetailViewViewDelegate {
    
    @IBOutlet weak var myLocationView: UIView?
    @IBOutlet weak var myLocationBtn: UIButton?
    @IBOutlet weak var mapContainerView: GoogleMapsView?

    var stopView = StopCell()
    var tripDetailView = TripDetailView()
    var tripTrackingView = TripCell()
    var selectedStop: Stop?
    var tripId: String?
    
    var tripDetailsShowingState = 0{
        didSet{
            if tripDetailsShowingState < 2{
                tripDetailView.tableView?.isScrollEnabled = false
            }else{
                tripDetailView.tableView?.isScrollEnabled = true
            }
        }
    }
    
    var trip = Trip()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let h = self.view.frame.height - 94 - 135
        myLocationView?.frame.origin.y = h
        myLocationView?.frame.origin.x = self.view.frame.width - 15 - 54
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
        
        showStopDetails()
    }
    
    func didTapOutsideMarker() {
        selectedStop = nil
        hideStopDetails{
            self.tripDetailView.trip? = self.trip
            self.tripDetailView.tableView?.reloadData()
        }
    }
    
    //This function gets called when trip starts and with every delivery updating the new leg times
    func recalculatedTravelTime(legTimes: [TimeInterval]){
        updateETAs(legTimes: legTimes)
        updateProgress()
        
        if tripTrackingView.isHidden == true{
            showTripTrackingView()
        }
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
    func tripDetailViewDidSelect(stop: Stop?) {
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
        if tripDetailsShowingState  == 1{
            //hideStopDetails()
        }
        showTripDetails()
    }
    
    func tripDetailViewDidSwipeDown() {
        hideTripDetails()
        if selectedStop != nil{
            //showStopDetails()
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
        eraseViews()
        
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
    //Setup functions
    func eraseViews(){
        mapContainerView?.mapView?.removeFromSuperview()
        stopView.removeFromSuperview()
        tripTrackingView.removeFromSuperview()
        tripDetailView.removeFromSuperview()
    }
    
    func setupViews(){
        if trip.status != "ready"{
            selectedStop = trip.stops.where { $0.delivery_status == "pending" && $0.warehouse == nil}.first
        }
        
        let helper = TripViewHelper()
        //Setup Map View First
        helper.setupMapContainerView(viewController: self)
        
        stopView = helper.setupStopView(viewController: self)
        
        tripTrackingView = helper.setupTripTrackingView(viewController: self)
        
        tripDetailView = helper.setupTripDetailsView(viewController: self)
        
        myLocationView?.frame.origin.x = self.view.frame.width - 15 - 54
        
        tripDetailsShowingState = 0
        showTripDetails()
        
        //Show view if not nil
        if selectedStop != nil{
            showStopDetails()
            mapContainerView?.selectMarker(stop: selectedStop)
        }
    }
    
    //Hide and show functions
    
    func showTripTrackingView(){
        if trip.status != "ready"{
            //Show the data
            tripTrackingView.isHidden = false
            
            //Show view with animation
            UIView.animate(withDuration: 0.5, animations: {
                self.tripTrackingView.frame.origin.y = 60
            })
        }
    }
    
    func hideTripTrackingView(completion: (() -> Void)? = nil) {
        if trip.status != "ready"{
            UIView.animate(withDuration: 0.5, animations: {
                self.tripTrackingView.frame.origin.y = -1 * self.tripTrackingView.frame.height + 100
            }, completion: { (finished: Bool) in
                completion?() // Immediately notify if no animation needed
            })
        }else{
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
                    self.stopView.frame.origin.y = 60
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
        
        var y: CGFloat = 0
        var h: CGFloat = 0
        switch tripDetailsShowingState{
        case 0:
            y = self.view.frame.height - 294
            h = y - 135
        case 1:
            y = 60
            h = self.view.frame.height - 294 - 135
        default:
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tripDetailView.frame.origin.y = y
            self.myLocationView?.frame.origin.y = h
        }, completion: { (finished: Bool) in
            self.tripDetailsShowingState += 1
        })
        
    }
    
    func hideTripDetails(){
        
        var y: CGFloat = 0
        var h: CGFloat = 0
        switch tripDetailsShowingState{
        case 1:
            y = self.view.frame.height - 94
            h = self.view.frame.height - 94 - 130
        case 2:
            y = self.view.frame.height - 294
            h = self.view.frame.height - 294 - 130
        default:
            return
        }
        
        if tripDetailView.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) is UITableViewCell{
            tripDetailView.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tripDetailView.frame.origin.y = y
            self.myLocationView?.frame.origin.y = h
        }, completion: { (finished: Bool) in
            self.tripDetailsShowingState -= 1
        })
    }
    
    func updateETAs(legTimes: [TimeInterval]){
        let tripManager = TripManager()
        let shiftManager = ShiftManager()
        
        let eta = tripManager.getETA(trip: trip, legTimes: legTimes)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        tripTrackingView.txtETA?.text = "ETA: " + formatter.string(from: eta ?? Date())
        
        if let eta = eta{
            if shiftManager.isETAWithinShift(eta: eta, delivery_shift: trip.delivery_shift ?? DeliveryShift()){
                tripTrackingView.txtstatus?.text = "On time"
                tripTrackingView.viewStatus?.backgroundColor = AppColors.green
            }else{
                tripTrackingView.txtstatus?.text = "Delayed"
                tripTrackingView.viewStatus?.backgroundColor = AppColors.red
            }
        }else{
            tripTrackingView.txtstatus?.text = "Unknown"
            tripTrackingView.viewStatus?.backgroundColor = AppColors.red
        }
        
        tripDetailView.tableView?.reloadData()
    }
    
    func updateProgress(){
        let done = trip.stops.where { $0.delivery_status != "pending" && $0.warehouse == nil }.count
        let remaining = trip.stops.where { $0.delivery_status == "pending" && $0.warehouse == nil }.count

        // Update the `done` text
        tripTrackingView.txtDone?.text = "\(done) stop\(done == 1 ? "" : "s") done"

        // Update the `remaining` text
        tripTrackingView.txtRemaining?.text = "\(remaining) stop\(remaining == 1 ? "" : "s") remaining"
        
        let percentage: CGFloat = CGFloat(done) / CGFloat(trip.stops.where { $0.warehouse == nil }.count)
        let width = tripTrackingView.viewProgress?.superview?.frame.width ?? 0
        tripTrackingView.viewProgressWidth?.constant = width * percentage
    }
}
