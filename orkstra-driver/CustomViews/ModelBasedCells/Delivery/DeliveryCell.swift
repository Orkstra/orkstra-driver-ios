//
//  DeliveryCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 23/04/2025.
//

import UIKit

class DeliveryCell: StorageTableViewCell {
    
    @IBOutlet weak var txtLocation: UILabel?
    @IBOutlet weak var txtContactPerson: UILabel?
    @IBOutlet weak var txtContactPhoneNumber: UILabel?
    
    @IBOutlet weak var viewReturn: UIView?
    @IBOutlet weak var viewTime: CustomUiView?
    @IBOutlet weak var txtTime: UILabel?
    @IBOutlet weak var txtWeight: UILabel?
    
    var delivery: Delivery? {
        didSet {
            txtContactPerson?.text = delivery?.contact_person ?? "NA"
            txtContactPhoneNumber?.text = delivery?.contact_phone_number ?? "NA"
            txtLocation?.text = delivery?.label
            
            if delivery?.time_slot != nil {
                viewTime?.borderWidth = 1
                viewTime?.backgroundColor = AppColors.lightOrange
            }else{
                viewTime?.borderWidth = 0
                viewTime?.backgroundColor = .white
            }
            
            viewTime?.isHidden = true
            //txtTime?.text = delivery?.time_slot
            
            //Return
            if delivery?.direction == "in"{
                viewReturn?.isHidden = false
            }else{
                viewReturn?.isHidden = true
            }
            
            //weight
            let weight: Double = (delivery?.line_items.map { $0.shipping_weight ?? 0 } ?? []).reduce(0, +)
            txtWeight?.text = String(format: "%.1f", weight) + " \(delivery?.line_items.first?.shipping_weight_unit ?? "kg")"
            
            //Storages
            let storages = delivery?.line_items.map({$0.storage_type?.uid ?? "NA"}) ?? []
            setupStorageView(cell: self, storageUIDs: storages)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapCallContact(sender: UIButton){
        //let phoneNumber = stop?.contact_phone_number ?? "NA"
        let phoneNumber = "+201065305550"
        callPhoneNumber(phoneNumber: phoneNumber)
    }
    
    func callPhoneNumber(phoneNumber: String) {
        // Format the phone number by removing any spaces or invalid characters
        let formattedNumber = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")

        // Create an action sheet
        let actionSheet = UIAlertController(title: "Phone Number Options", message: "What would you like to do with this phone number?", preferredStyle: .actionSheet)

        // Option to call the phone number
        let callAction = UIAlertAction(title: "Call", style: .default) { _ in
            if let phoneURL = URL(string: "tel://\(formattedNumber)"),
               UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                print("Unable to make a call. Invalid phone number or device does not support calling.")
            }
        }

        // Option to copy the phone number to the clipboard
        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = phoneNumber
            print("Phone number copied to clipboard: \(phoneNumber)")
        }

        // Option to send a WhatsApp message
        let whatsappAction = UIAlertAction(title: "Send WhatsApp", style: .default) { _ in
            let whatsappURL = URL(string: "https://wa.me/\(formattedNumber)")!
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            } else {
                print("Unable to open WhatsApp. Make sure WhatsApp is installed.")
            }
        }

        // Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the action sheet
        actionSheet.addAction(callAction)
        actionSheet.addAction(copyAction)
        actionSheet.addAction(whatsappAction)
        actionSheet.addAction(cancelAction)

        // Present the action sheet
        let appHelper = AppHelperClass()
        if let topController = appHelper.getTopViewController() {
            topController.present(actionSheet, animated: true, completion: nil)
        }
    }
}
