//
//  StopCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import UIKit
import MapKit

protocol StopCellDelegate: AnyObject {
    func StopCellDidSwipeUp()
}

class StopCell: StorageTableViewCell {
    
    @IBOutlet weak var txtLocation: UILabel?
    @IBOutlet weak var txtAddressLine1: UILabel?
    
    @IBOutlet weak var txtOrder: UILabel?
    @IBOutlet weak var topLine: UIView?
    @IBOutlet weak var bottomLine: UIView?
    @IBOutlet weak var orderView: UIView?
    @IBOutlet weak var separator: UIView?
    @IBOutlet weak var btnTakeMeThere: UIButton?
    @IBOutlet weak var btnDeliver: CustomUiButton?
    
    @IBOutlet weak var txtOutDeliveries: UILabel?
    @IBOutlet weak var txtInDeliveries: UILabel?
    
    @IBOutlet weak var viewTime: CustomUiView?
    @IBOutlet weak var txtTime: UILabel?
    @IBOutlet weak var txtTimeLeading: NSLayoutConstraint?
    @IBOutlet weak var txtTimeTrailing: NSLayoutConstraint?
    
    var delegate: StopCellDelegate?
    
    var stop: Stop? {
        didSet {
            //Storages
            let storages: [String] = stop?.deliveries
                .flatMap { $0.line_items } // Flatten line items from all deliveries
                .map { $0.storage_type?.uid ?? "NA" } ?? []
            
            setupStorageView(cell: self, storageUIDs: storages)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            txtTime?.text = "ETA: " + formatter.string(from: stop?.eta ?? Date())
            
            txtLocation?.text = stop?.name ?? "NA"
            txtOrder?.text = String(stop?.order ?? 0)
            txtAddressLine1?.text = stop?.address_line_1 ?? "NA"
            
            if stop?.deliveries.contains(where: { $0.start_time != nil }) == true {
                viewTime?.borderWidth = 1
                viewTime?.backgroundColor = AppColors.lightOrange
                txtTimeLeading?.constant = 10
                txtTimeTrailing?.constant = 10
            }else{
                viewTime?.borderWidth = 0
                viewTime?.backgroundColor = .clear
                txtTimeLeading?.constant = 0
                txtTimeTrailing?.constant = 0
            }
            
            let manager = StopManager()
            
            let deliveries = manager.getOutDeleveries(stop: stop ?? Stop()).count
            let returns = manager.getInDeleveries(stop: stop ?? Stop()).count
            
            
            txtOutDeliveries?.text = "\(deliveries) deliver\(deliveries == 1 ? "y" : "ies")"
            txtInDeliveries?.text = "\(returns) return\(returns == 1 ? "" : "s")"
        }
    }
    
    var isLastDrop: Bool = false{
        didSet{
            if isLastDrop == true{
                btnDeliver?.setBoldTitle(string: "Complete Trip", color: .white)
                bottomLine?.isHidden = true
            }else{
                btnDeliver?.setBoldTitle(string: "Deliver", color: .white)
                bottomLine?.isHidden = false
            }
        }
    }
    
    var setSelected: Bool? {
        didSet {
            if setSelected == true{
                orderView?.backgroundColor = AppColors.purple
            }else{
                orderView?.backgroundColor = AppColors.purple
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDeliver?.backgroundColor = AppColors.accent
        btnDeliver?.setTitleColor(.white, for: .normal)
        btnDeliver?.layer.cornerRadius = 7
        
        btnTakeMeThere?.tintColor = .white
        
        //Gesture to dismiss
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func doStorage(){
        //Storages
        let storages: [String] = stop?.deliveries
            .flatMap { $0.line_items } // Flatten line items from all deliveries
            .map { $0.storage_type?.uid ?? "NA" } ?? []
        
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
    
    @objc func didSwipeUp(){
        delegate?.StopCellDidSwipeUp()
    }
    
    @IBAction func didTapTakeMeThere(sender: UIButton){
        let latitude = stop?.latitude ?? 0.0
        let longitude = stop?.longitude ?? 0.0
        let locationName = stop?.name ?? "NA"
            
        navigateToLocation(latitude: latitude, longitude: longitude, locationName: locationName)
    }

    func navigateToLocation(latitude: Double, longitude: Double, locationName: String?) {
        let alertController = UIAlertController(title: "Navigate to Location", message: "Choose an app to navigate", preferredStyle: .actionSheet)
        
        // Apple Maps option
        alertController.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = locationName
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }))
        
        // Google Maps option
        alertController.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            if let googleMapsURL = URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"),
               UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            } else {
                // Open Google Maps in a browser if the app is not installed
                if let browserURL = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)") {
                    UIApplication.shared.open(browserURL, options: [:], completionHandler: nil)
                }
            }
        }))
        
        // Cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        let appHelper = AppHelperClass()
        if let topController = appHelper.getTopViewController() {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}
