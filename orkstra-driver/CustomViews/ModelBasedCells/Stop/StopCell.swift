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

class StopCell: UITableViewCell {
    
    @IBOutlet weak var txtLocation: UILabel?
    @IBOutlet weak var txtAddressLine1: UILabel?
    
    @IBOutlet weak var txtOrder: UILabel?
    @IBOutlet weak var topLine: UIView?
    @IBOutlet weak var bottomLine: UIView?
    @IBOutlet weak var orderView: UIView?
    @IBOutlet weak var separator: UIView?
    @IBOutlet weak var btnTakeMeThere: UIButton?
    
    @IBOutlet weak var viewTime: CustomUiView?
    @IBOutlet weak var txtTime: UILabel?
    
    var delegate: StopCellDelegate?
    
    var stop: Stop? {
        didSet {
            if (stop?.deliveries.map { $0.label }.unique().count ?? 0) > 1{
                txtLocation?.text = stop?.label ?? "NA"
                viewTime?.isHidden = true
            }else{
                txtLocation?.text = stop?.deliveries.first?.label
                viewTime?.isHidden = false
                //txtTime?.text = stop?.deliveries.first?.time_slot
            }
            
            txtLocation?.text = stop?.label ?? "NA"
            txtOrder?.text = String(stop?.order ?? 0)
            txtAddressLine1?.text = stop?.address_line_1 ?? "NA"
            
            if stop?.deliveries.first?.time_slot != nil {
                viewTime?.borderWidth = 1
                viewTime?.backgroundColor = AppColors.lightOrange
            }else{
                viewTime?.borderWidth = 0
                viewTime?.backgroundColor = .white
            }
        }
    }
    
    var setSelected: Bool? {
        didSet {
            if setSelected == true{
                orderView?.backgroundColor = AppColors.orange
            }else{
                orderView?.backgroundColor = AppColors.trip
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnTakeMeThere?.tintColor = AppColors.orange
        //Gesture to dismiss
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func didSwipeUp(){
        delegate?.StopCellDidSwipeUp()
    }
    
    @IBAction func didTapTakeMeThere(sender: UIButton){
        let latitude = stop?.latitude ?? 0.0
        let longitude = stop?.longitude ?? 0.0
        let locationName = stop?.label ?? "NA"
            
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
