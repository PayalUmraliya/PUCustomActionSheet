//
//  ViewController.swift
//  PUCustomActions
//
//  Created by PM on 25/05/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func btnShow_clk(_ sender: Any) {
        self.manageArrAndDisplay()
    }
    func manageArrAndDisplay()
    {
        let policyarr = ["PM - 8967675655\nPolicy - Active Assure Plan","PM - 4567890123\nPolicy - Active Fit Plan","PM - 23131313131\nPolicy - Active Assure Plan","PM - 435435435435\nPolicy - Active Fit Plan","PM - 675756765756\nPolicy - Active Assure Plan","PM - 756765765765\nPolicy - Active Fit Plan"]
        if policyarr.count > 1
        {
            var btnArr = [PUButtonItem]()
            for (idx, element) in policyarr.enumerated()
            {
                btnArr.append( PUButtonItem(title: element, titleColor: .blue, subtitleColor: .custom(UIColor.darkGray),buttonType: .default(index: idx)))
            }
            self.showActionSheet(btnArr)
        }
    }
}

extension ViewController
{
    func showActionSheet(_ buttons: [PUButtonItem]) {
    
        let titleItem = PUTitleItem(title: "PLEASE SELECT POLICY", titleColor: .black)
        let cancelButton = PUButtonItem(title: "Close", titleColor: .blue, buttonType: .cancel)

        let PUActionSheet = PUActionSheet(title: titleItem, buttons: buttons, duration: nil, cancelButton: cancelButton)
        PUActionSheet.selectionClosure = { item in
            if let currentItem = item, let type = currentItem.buttonType {
                switch type {
                case let .default(index):
                    print("index \(index) ==")
                    
                case .cancel:
                    self.navigationController?.popViewController(animated: false)
                    print("cancel")
                }
            }
        }
        PUActionSheet.present()
    }
}
