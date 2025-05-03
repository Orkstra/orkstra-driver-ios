//
//  TripCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 23/04/2025.
//

import UIKit
import RealmSwift

class TripCell: StorageTableViewCell{
    
    @IBOutlet weak var btnStartTrip: CustomUiButton?
    @IBOutlet weak var btnEndTrip: CustomUiButton?
    @IBOutlet weak var separator: UIView?
    
    @IBOutlet weak var txtRoute: UILabel?
    @IBOutlet weak var txtShift: UILabel?
    @IBOutlet weak var txtETA: UILabel?
    @IBOutlet weak var txtstatus: UILabel?
    @IBOutlet weak var viewStatus: UIView?
    
    @IBOutlet weak var viewProgress: UIView?
    @IBOutlet weak var txtDone: UILabel?
    @IBOutlet weak var txtRemaining: UILabel?
    @IBOutlet weak var viewProgressWidth: NSLayoutConstraint?
    
    @IBOutlet weak var txtStops: UILabel?
    @IBOutlet weak var txtDeliveries: UILabel?
    
    var tripViewController: TripViewController?
    
    var trip: Trip? {
        didSet {
            txtRoute?.text = trip?.route_name
            
            let stops = trip?.stops.where { $0.warehouse == nil}.count
            txtStops?.text = "\(stops ?? 0) stop\(stops == 1 ? "" : "s")"
            
            let deliveries = trip?.stops
                .filter { $0.warehouse == nil } // Filter stops where warehouse is nil
                .reduce(0) { $0 + ($1.deliveries.count) } // Sum up the count of deliveries for each stop
            
            txtDeliveries?.text = "\(deliveries ?? 0) deliver\(deliveries == 1 ? "y" : "ies")"
            
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.dateFormat = "h:mma" // Custom format without a space
            formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent formatting
            txtShift?.text = formatter.string(from: trip?.delivery_shift?.start_time ?? Date()) + " - " + formatter.string(from: trip?.delivery_shift?.end_time ?? Date())
            
            //Storages
            let storages: [String] = trip?.stops
                .flatMap { $0.deliveries } // Flatten all deliveries from all stops
                .flatMap { $0.line_items } // Flatten all line items from all deliveries
                .map { $0.storage_type?.uid ?? "NA" } ?? []
            
            setupStorageView(cell: self, storageUIDs: storages)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnStartTrip?.tintColor = UIColor.white
        btnStartTrip?.layer.cornerRadius = 8
        btnStartTrip?.setBoldTitle(string: "Start trip", color: .white)
        btnEndTrip?.setBoldTitle(string: "End trip", color: .black)
        
        // Apply the gradient
        let helper = AppHelperClass()
        helper.applyGradientToButton(button: btnStartTrip ?? UIButton(), colors: [
            AppColors.purple.cgColor,       // First color
            AppColors.blue.cgColor,         // Second color
            AppColors.turquoise.cgColor     // Third color
        ])
        
        //Gesture to dismiss
        self.addSwipeGesture(target: self, action: #selector( didSwipeUp(_:)), direction: .up)
        self.addSwipeGesture(target: self, action: #selector( didSwipeDown(_:)), direction: .down)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didClickStartTrip(sender: UIButton){
        if let trip = self.trip {
            let realm = try! Realm()
            try! realm.write {
                trip.status = "on_route"
                trip.isDirty = true
            }
        } else {
            print("Nothing to update; person is nil.")
        }
        
        tripViewController?.tripDetailView.startTrip()
        
        //Show the correct views
        tripViewController?.tripDetailsShowingState = 2
        tripViewController?.hideTripDetails()
        tripViewController?.hideStopDetails()
    }
    
    @IBAction func didClickEndTrip(sender: UIButton){
        if let trip = self.trip {
            let realm = try! Realm()
            try! realm.write {
                trip.status = "ready"
                trip.isDirty = true
            }
        } else {
            print("Nothing to update; person is nil.")
        }
        
        tripViewController?.selectedStop = nil
        tripViewController?.hideTripTrackingView()
        tripViewController?.didTapOutsideMarker()
        tripViewController?.tripDetailViewDidSelect(stop: nil)
    }
    
    @objc func didSwipeDown(_ sender: UITapGestureRecognizer){
        tripViewController?.showTripTrackingView()
    }
    
    @objc func didSwipeUp(_ sender: UITapGestureRecognizer){
        tripViewController?.hideTripTrackingView()
    }
}
