//
//  MarkOptionsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/30/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import DGRunkeeperSwitch

class MarkOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var key:String!
    var markOrTopic = false
    
    var ref:FIRDatabaseReference?
    let uid = String(FIRAuth.auth()!.currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDG()
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
    
    func setUpDG(){
        let runkeeperSwitch = DGRunkeeperSwitch(titles: ["Topics", "Marks"])
        runkeeperSwitch.backgroundColor = UIColor(red: 23.0/255.0, green: 223.0/255.0, blue: 130.0/255.0, alpha: 1.0)
        runkeeperSwitch.selectedBackgroundColor = .white
        runkeeperSwitch.titleColor = .white
        runkeeperSwitch.selectedTitleColor = UIColor(red: 23.0/255.0, green: 223.0/255.0, blue: 130.0/255.0, alpha: 1.0)
        runkeeperSwitch.titleFont = UIFont(name: "System", size: 11.0)
        runkeeperSwitch.frame = CGRect(x: 87.0, y: 28.0, width: 150.0, height: 23.0)
        runkeeperSwitch.center.x = self.view.center.x
        runkeeperSwitch.addTarget(self, action: #selector(MarkOptionsViewController.switchChange(sender:)), for: .valueChanged)
        view.addSubview(runkeeperSwitch)
    }
    
    @IBAction func switchChange( sender: DGRunkeeperSwitch) {
        markOrTopic = !markOrTopic
        if !markOrTopic{
            descLabel.text = "Topics are helpful categories to label your thoughts and pieces of writing. They relate but are individual."
        }else{
            descLabel.text = "Marks are pieces of writings that continue off one another. Use these to create progressive writing."
        }
    }

}



class OptionCell: UITableViewCell {

    @IBOutlet weak var numMarks: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
