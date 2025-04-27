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
    @IBOutlet weak var viewHeight: NSLayoutConstraint?
    
    @IBOutlet weak var txtShift: UILabel?
    @IBOutlet weak var txtETA: UILabel?
    @IBOutlet weak var txtstatus: UILabel?
    @IBOutlet weak var viewStatus: UIView?
    
    @IBOutlet weak var viewProgress: UIView?
    @IBOutlet weak var txtDone: UILabel?
    @IBOutlet weak var txtRemaining: UILabel?
    @IBOutlet weak var viewProgressWidth: NSLayoutConstraint?
    
    var tripViewController: TripViewController?
    
    var trip: Trip? {
        didSet {
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
        btnStartTrip?.layer.cornerRadius = 7
        btnStartTrip?.setBoldTitle(string: "Start trip", color: .white)
        btnEndTrip?.setBoldTitle(string: "End trip", color: .white)
        
        // Apply the gradient
        let helper = AppHelperClass()
        helper.applyGradientToButton(button: btnStartTrip ?? UIButton(), colors: [
            AppColors.purple.cgColor,       // First color
            AppColors.blue.cgColor,         // Second color
            AppColors.turquoise.cgColor     // Third color
        ])
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
        tripViewController?.hideTripSummary()
        tripViewController?.didTapOutsideMarker()
        tripViewController?.tripDetailViewDidSSelectRow(stop: nil)
    }
    
}
