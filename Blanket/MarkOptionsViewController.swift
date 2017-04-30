//
//  MarkOptionsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/30/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import PopupDialog

class MarkOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var marks:[Mark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionCell
        let option = marks[indexPath.row]
        cell.nameLabel.text = option.name
        return cell
    }
    
    @IBAction func addOption(_ sender: UIButton) {
        
    }
    
    
    @IBAction func backSegue(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToEntry", sender: self)
    }
    
    //popup when a user presses on a badge they have completed
    func showImageDialog(animated: Bool = true, item:Int) {
        
        // Prepare the popup assets
        let title = "New Mark"
        let message = "Enter a name for this mark."
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create third button
        let buttonClose = DefaultButton(title: "Close") {
        }
        // Add buttons to dialog
        popup.addButtons([buttonClose])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }

}



class OptionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
}
