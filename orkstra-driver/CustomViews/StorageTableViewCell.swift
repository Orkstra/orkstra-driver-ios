//
//  StorageTableViewCell.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 26/04/2025.
//

import UIKit

class StorageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var storageView: UIView?
    @IBOutlet weak var storageDry: UIView?
    @IBOutlet weak var storageChilled: UIView?
    @IBOutlet weak var storageFreeze: UIView?
    @IBOutlet weak var storageViewWidth: NSLayoutConstraint?
    
    func setupStorageView(cell: StorageTableViewCell, storageUIDs: [String]){
        var x: Double = 0
        
        if storageUIDs.contains("Freez"){
            cell.storageFreeze?.isHidden = false
            cell.storageFreeze?.frame.origin.x = 0
            x += 30
        }else{
            cell.storageFreeze?.isHidden = true
        }
        
        if storageUIDs.contains("Chilled"){
            cell.storageChilled?.isHidden = false
            cell.storageChilled?.frame.origin.x = CGFloat(x)
            x += 30
        }else{
            cell.storageChilled?.isHidden = true
            
        }
        
        if storageUIDs.contains("Dry"){
            cell.storageDry?.isHidden = false
            cell.storageDry?.frame.origin.x = CGFloat(x)
            x += 30
        }else{
            cell.storageDry?.isHidden = true
        }
        
        x -= 6
        
        cell.storageViewWidth?.constant = x
    }
}
