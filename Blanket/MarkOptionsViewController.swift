//
//  MarkOptionsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/30/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MarkOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var key:String!
    
    var ref:FIRDatabaseReference?
    let uid = String(FIRAuth.auth()!.currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        ref = FIRDatabase.database().reference()
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marks.count
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.insertRows(at: [IndexPath(row: marks.count-1, section: 0)], with: .automatic)
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionCell
        let option = marks[indexPath.row]
        cell.nameLabel.text = option.name
        cell.numMarks.text = String(option.entries.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = marks[indexPath.row]
        ref?.child("Entry").child(key).child("mark").setValue(option.name)
        ref?.child("Marks").child(option.key).child("entries").updateChildValues([key:key])
        let markName = option.name
        performSegue(withIdentifier: "unwindToEntry", sender: markName)
    }
    
    @IBAction func addOption(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Mark", message: "Please enter a new mark.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let name = (textField?.text)!
            post(name: name)
        }))
        
        func post(name:String){
            let newMark = name
            var mdata:[String:String] = [:]
            mdata[Constants.Mark.marks] = newMark
            mdata[Constants.Mark.uid] = uid
            ref?.child("Marks").childByAutoId().setValue(mdata)

        }
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backSegue(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToEntry", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToEntry"{
            guard let object = sender as? String else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.markName = object
        }
        
    }

}



class OptionCell: UITableViewCell {

    @IBOutlet weak var numMarks: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
