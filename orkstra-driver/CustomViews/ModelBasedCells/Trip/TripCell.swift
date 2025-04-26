//
//  TripCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 23/04/2025.
//

import UIKit
import RealmSwift

class TripCell: UITableViewCell {
    
    @IBOutlet weak var btnStartTrip: CustomUiButton?
    @IBOutlet weak var btnEndTrip: CustomUiButton?
    @IBOutlet weak var separator: UIView?
    @IBOutlet weak var viewHeight: NSLayoutConstraint?
    
    @IBOutlet weak var storageView: UIView?
    @IBOutlet weak var storageDry: UIView?
    @IBOutlet weak var storageChilled: UIView?
    @IBOutlet weak var storageFreeze: UIView?
    @IBOutlet weak var storageViewWidth: NSLayoutConstraint?
    
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
            //Storage Views
            doStorage()
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
    
    func doStorage(){
        //Storages
        let storages: [String] = trip?.stops
            .flatMap { $0.deliveries } // Flatten all deliveries from all stops
            .flatMap { $0.line_items } // Flatten all line items from all deliveries
            .map { $0.storage?.name ?? "NA" } ?? []
        
        var x: Double = 0
        
        if storages.contains("Freez"){
            storageFreeze?.isHidden = false
            storageFreeze?.frame.origin.x = 0
            x += 25
        }else{
            storageFreeze?.isHidden = true
        }
        
        if storages.contains("Chilled"){
            storageChilled?.isHidden = false
            storageChilled?.frame.origin.x = CGFloat(x)
            x += 25
        }else{
            storageChilled?.isHidden = true
            
        }
        
        if storages.contains("Dry"){
            storageDry?.isHidden = false
            storageDry?.frame.origin.x = CGFloat(x)
            x += 22
        }else{
            storageDry?.isHidden = true
        }
        
        storageViewWidth?.constant = x
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
