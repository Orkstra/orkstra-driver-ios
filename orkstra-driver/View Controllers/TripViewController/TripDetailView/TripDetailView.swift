//
//  TripDetailView.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 03/04/2025.
//

import UIKit
import RealmSwift

protocol TripDetailViewViewDelegate: AnyObject {
    func tripDetailViewDidSwipeUp()
    func tripDetailViewDidSwipeDown()
    func tripDetailViewDidSSelectRow(stop: Stop?)
}


class TripDetailView: UITableViewCell, UITableViewDelegate, UITableViewDataSource, StopActionViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnToggleView: UIButton?
    
    var tripViewController: TripViewController?
    var delegate: TripDetailViewViewDelegate?
    var separator: UIView?
    var summaryViewHeight: NSLayoutConstraint?
    
    var trip: Trip?{
        didSet{
            setStops()
        }
    }
    
    var stops = [Stop]()
    
    var selectedStop: Stop?
    
    func setStops(){
        //Stops
        if trip?.status == "ready"{
            if let t = trip{
                selectedStop = nil
                stops = Array(t.stops)
            }
        }else{
            let manager = TripManager()
            selectedStop = manager.getNextStop(trip: trip ?? Trip())
            stops = manager.getUndeliveredStops(trip: trip ?? Trip())
        }
        
        delegate?.tripDetailViewDidSSelectRow(stop: selectedStop)
        tableView?.reloadData()
    }
    
    //Start trip button click
    func startTrip(){
        setStops()
        //Re draw routes to get updated arrival times
        tripViewController?.mapContainerView?.drawRoute()
    }
    
    func endTrip(){
        setStops()
    }
    
    // Delegate method implementation
    func didDeliver(_ controller: StopActionViewController, stop: Stop?) {
        let manager = TripManager()
        stops = manager.getUndeliveredStops(trip: trip ?? Trip())
        selectedStop = manager.getNextStop(trip: trip ?? Trip())
        
        tableView?.reloadData()
        //Notify delegate
        delegate?.tripDetailViewDidSSelectRow(stop: selectedStop)
        //Re draw routes to get updated arrival times
        tripViewController?.mapContainerView?.drawRoute()
        
        //scroll to next stop
        if let index = stops.firstIndex(of: stop ?? Stop()) {
            let indexPath = IndexPath(row: index, section: 0)
            
            // Scroll to position
            tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
        } else {
            print("Stop was not found in trip.stops")
        }
    }
}

extension TripDetailView{
    
    func setup(){
        
        //Table View Setup
        tableView?.showsVerticalScrollIndicator = false
        tableView?.sectionHeaderTopPadding = 0
        //Gesture to dismiss
        btnToggleView?.addSwipeGesture(target: self, action: #selector( didSwipeUp(_:)), direction: .up)
        btnToggleView?.addSwipeGesture(target: self, action: #selector( didSwipeDown(_:)), direction: .down)
        
        // Register the .xib file for the custom cell
        let nib = UINib(nibName: "StopCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "stop")
        
        let nib2 = UINib(nibName: "DeliveryCell", bundle: nil)
        tableView?.register(nib2, forCellReuseIdentifier: "delivery")
        
        let nib3 = UINib(nibName: "DeliveryCellWithTitle", bundle: nil)
        tableView?.register(nib3, forCellReuseIdentifier: "deliveryWithTitle")
        
        let nib4 = UINib(nibName: "NextStopCell", bundle: nil)
        tableView?.register(nib4, forCellReuseIdentifier: "nextStop")
        
        let nib5 = UINib(nibName: "TripSummaryCell", bundle: nil)
        tableView?.register(nib5, forCellReuseIdentifier: "trip")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func didSwipeDown(_ sender: UITapGestureRecognizer){
        delegate?.tripDetailViewDidSwipeDown()
    }
    
    @objc func didSwipeUp(_ sender: UITapGestureRecognizer){
        delegate?.tripDetailViewDidSwipeUp()
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        if tripViewController?.tripDetailsShowing == true {
            tripViewController?.hideTripDetails()
        }else{
            tripViewController?.showTripDetails()
        }
    }
    
    @IBAction func didTapToggleView(_ sender: Any) {
        headerTapped(nil)
    }
    
    @objc func didTapDeliverBtn(_ sender: UIButton){
        let vc = StopActionViewController()
        vc.delegate = self
        vc.stop = selectedStop
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            vc.modalPresentationStyle = .popover
        } else {
            vc.modalPresentationStyle = .fullScreen
        }
        if let view = delegate as? UIViewController{
            view.present(vc, animated: true, completion: nil)
        }
    }
    
}

//Table View Functions
extension TripDetailView{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && trip?.status == "ready"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "trip") as! TripCell
            cell.trip = trip
            cell.tripViewController = tripViewController
            separator = cell.separator
            summaryViewHeight = cell.viewHeight
            cell.addGesture(target: self, action: #selector( headerTapped(_:)))
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "nextStop") as! StopCell
            
            if stops.count == 2 && selectedStop?.warehouse != nil{
                cell.isLastDrop = true
            }else{
                cell.isLastDrop = false
            }
            
            cell.stop = stops[1]
            cell.topLine?.isHidden = true
            cell.setSelected = true
            cell.viewTime?.isHidden = false
            cell.btnDeliver?.addTarget(self, action: #selector( didTapDeliverBtn(_:)), for: .touchUpInside)
            separator = cell.separator
            summaryViewHeight = cell.viewHeight
            cell.addGesture(target: self, action: #selector(headerTapped(_:)))
    
            return cell
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if separator != nil{
            let isSticky = scrollView.contentOffset.y > 0
            separator?.isHidden = !isSticky
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Check for the specific row
        if section != 0 { return 0 }
        
        // Use automatic height for all other rows
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Check for the specific row
        if indexPath.section == 0 && indexPath.row == 0 && trip?.status != "ready" { return 0 }
        
        // Use automatic height for all other rows
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count - 1
        //return (trip?.stops.count ?? 0) - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stops.count > 0{
            return (stops[section + 1].deliveries.count) + 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stop = stops[indexPath.section + 1]
        if indexPath.row == 0 && (trip?.status != "on_route" || indexPath.section != 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "stop") as! StopCell
            
            cell.stop = stop
            
            if indexPath.section == 0{
                cell.topLine?.isHidden = true
            }else{
                cell.topLine?.isHidden = false
            }
            
            if indexPath.section == (stops.count) - 2{
                cell.bottomLine?.isHidden = true
            }else{
                cell.bottomLine?.isHidden = false
            }
            
            cell.setSelected = stop.id == selectedStop?.id
            
            return cell
        }else if indexPath.row == 0 && indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "nextStop") as! StopCell
            cell.stop = stop
            cell.topLine?.isHidden = true
            cell.setSelected = true
            cell.viewTime?.isHidden = false
            return cell
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "delivery") as! DeliveryCell
            let delivery = stop.deliveries[indexPath.row - 1]
            
            // Check if this is the first occurrence of the label
            if (indexPath.row - 1) == stop.deliveries.firstIndex(where: { $0.label == delivery.label }) && (stop.deliveries.map { $0.label }.unique().count) > 1{
                cell = tableView.dequeueReusableCell(withIdentifier: "deliveryWithTitle") as! DeliveryCell
            }
            
            cell.delivery = delivery
            return cell
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
//        if trip?.status != "ready" && selectedStop?.id == stops[indexPath.section].id && indexPath.row > 0{
//            let vc = StopActionViewController()
//            vc.delegate = self
//            vc.stop = selectedStop
//            
//            if UIDevice.current.userInterfaceIdiom == .phone {
//                vc.modalPresentationStyle = .popover
//            } else {
//                vc.modalPresentationStyle = .fullScreen
//            }
//            if let view = delegate as? UIViewController{
//                view.present(vc, animated: true, completion: nil)
//            }
//        }else{
//            selectedStop = stops[indexPath.section]
//        }
//        tableView.reloadData()
//        
//        delegate?.tripDetailViewDidSSelectRow(stop: selectedStop)
    }
}
