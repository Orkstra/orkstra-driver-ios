//
//  StopActionViewController.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 04/04/2025.
//

import UIKit
import RealmSwift

protocol StopActionViewDelegate: AnyObject {
    func didDeliver(_ controller: StopActionViewController, stop: Stop?)
}

class StopActionViewController: UIViewController {

    weak var delegate: StopActionViewDelegate?
    var stop: Stop?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func deliverBtnClick(){
        //Update stop
        if let stop = self.stop {
            let realm = try! Realm()
            try! realm.write {
                stop.delivery_status = "delivered"
                stop.isDirty = true
            }
        } else {
            print("Nothing to update; person is nil.")
        }
        
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.didDeliver(self, stop: stop)
        }
    }

}
