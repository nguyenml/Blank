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
    
    @IBOutlet weak var topicsView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var key:String!
    var markOrTopic = true
    var mot:Bool!
    var name = ""
    
    var ref:FIRDatabaseReference?
    let uid = String(FIRAuth.auth()!.currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDG()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        topicsView.dataSource = self
        topicsView.delegate = self
        ref = FIRDatabase.database().reference()
        
        tableView.tableFooterView = UIView()
        topicsView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the sample data structure.
        var count:Int?
        
        if tableView == self.tableView {
            count = marks.count
        }
        
        if tableView == self.topicsView {
            count = topics.count
        }
        
        return count!
        
    }

    func reloadTableData(_ notification: Notification) {
        if markOrTopic{
          topicsView.insertRows(at: [IndexPath(row: topics.count-1, section: 0)], with: .automatic)
          topicsView.reloadData()
          topicsView.tableFooterView = UIView()
        }
        else{
          tableView.insertRows(at: [IndexPath(row: marks.count-1, section: 0)], with: .automatic)
          tableView.reloadData()
          tableView.tableFooterView = UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionCell
        // Dequeue cell
        if tableView == self.tableView{
            let option = marks[indexPath.row]
            cell.nameLabel.text = option.name
            cell.numMarks.text = String(option.entries.count)
        }
        
        if tableView == topicsView{
            let option = topics[indexPath.row]
            cell.nameLabel.text = option.name
            cell.numMarks.text = String(option.entries.count)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView{
            print("test")
            tableView.deselectRow(at: indexPath, animated: true)
            let option = marks[indexPath.row]
            ref?.child("Entry").child(key).child("mark").setValue(option.name)
            ref?.child("Marks").child(option.key).child("entries").updateChildValues([key:key])
            name = option.name
            mot = false
            performSegue(withIdentifier: "unwindToEntry", sender: self)
        }
        if tableView == self.topicsView{
            topicsView.deselectRow(at: indexPath, animated: true)
            let option = topics[indexPath.row]
            ref?.child("Entry").child(key).child("topic").setValue(option.name)
            ref?.child("Topics").child(option.key).child("entries").updateChildValues([key:key])
            name = option.name
            mot = true
            performSegue(withIdentifier: "unwindToEntry", sender: self)
        }
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
            if markOrTopic{
                let newTopic = name
                var mdata:[String:String] = [:]
                mdata[Constants.Topic.topics] = newTopic
                mdata[Constants.Topic.uid] = uid
                ref?.child("Topics").childByAutoId().setValue(mdata)
            }
            else{
                let newMark = name
                var mdata:[String:String] = [:]
                mdata[Constants.Mark.marks] = newMark
                mdata[Constants.Mark.uid] = uid
                ref?.child("Marks").childByAutoId().setValue(mdata)
            }

        }
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backSegue(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToEntry", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToEntry"{
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.markName = name
            dvc.topicOrMark = mot
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
        if markOrTopic{
            descLabel.text = "Topics are helpful categories to label your thoughts and pieces of writing. They relate but are individual."
            tableView.isHidden = true
            topicsView.isHidden = false
        }else{
            descLabel.text = "Marks are pieces of writings that continue off one another. Use these to create progressive writing."
            tableView.isHidden = false
            topicsView.isHidden = true
        }
    }

}



class OptionCell: UITableViewCell {

    @IBOutlet weak var numMarks: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
