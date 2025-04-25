//
//  TripCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 23/04/2025.
//

import UIKit
import RealmSwift

class TripCell: UITableViewCell {
    
    @IBOutlet weak var btnStartTrip: UIButton?
    @IBOutlet weak var separator: UIView?
    
    var tripViewController: TripViewController?
    
    var trip: Trip? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnStartTrip?.tintColor = UIColor.white
        btnStartTrip?.layer.cornerRadius = 5
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
        tripViewController?.showTripSummary()
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
