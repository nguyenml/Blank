//
//  ContinueViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 5/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

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

class ContinueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topicView: UITableView!
    //Recieve key from input controller
    var currentString:String!
    var markOrTopic = true
    
    //Send to input
    var chosen:String!
    var loadString:String!
    var loadedWC:Int16!
    var name:String!
    //------------------------
    
    var ref:FIRDatabaseReference?
    let uid = String(FIRAuth.auth()!.currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDG()
        tableView.delegate = self
        tableView.dataSource = self
        topicView.delegate = self
        topicView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        tableView.tableFooterView = UIView()
        topicView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the sample data structure.
        var count:Int?
        
        if tableView == self.tableView {
            count = marks.count
        }
        
        if tableView == self.topicView {
            count = topics.count
        }
        
        return count!
        
    }
    
    func reloadTableData(_ notification: Notification) {
        if markOrTopic{
            topicView.insertRows(at: [IndexPath(row: topics.count-1, section: 0)], with: .automatic)
            topicView.reloadData()
            topicView.tableFooterView = UIView()
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
        }
        
        if tableView == self.topicView{
            let option = topics[indexPath.row]
            cell.nameLabel.text = option.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == self.tableView{
            let option = marks[indexPath.row]
            let loadedString = option.getString()
            option.resetString()
            loadedWC = wordCount(str: loadedString)
            chosen = option.key
            loadString = loadedString
            name = option.name
            performSegue(withIdentifier: "unwindToInput", sender: self)
        }
        if tableView == self.topicView{
            topicView.deselectRow(at: indexPath, animated: true)
            let option = topics[indexPath.row]
            chosen = option.key
            name = option.name
            performSegue(withIdentifier: "unwindToInput", sender: self)
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
        
        performSegue(withIdentifier: "unwindToInput", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "unwindToInput"{
            let dvc = segue.destination as! InputViewController
            if markOrTopic{
                dvc.markKey = chosen
                dvc.name = name
                dvc.mot = markOrTopic
            }
            else{
                dvc.markKey = chosen
                dvc.name = name
                dvc.mot = markOrTopic
                dvc.loadedWC = loadedWC
                dvc.loadedString = loadString
            }
        }
        
    }
    
    
    //How many words the user wrote
    func wordCount(str:String) -> Int16{
        
        let wordList =  str.components(separatedBy: NSCharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{$0 != ""}
        
        return Int16(wordList.count)
    }
    
    //function for WC
    func SpecificWordCount(str:String, word:String) ->Int {
        let words = str.components(separatedBy: " "); var count = 0
        for thing in words {
            if thing == word {
                count += 1
            }
        }
        return count
    }
    
    func switchChange( sender: DGRunkeeperSwitch) {
        markOrTopic = !markOrTopic
        if markOrTopic{
            descLabel.text = "Topics are helpful categories to label your thoughts and pieces of writing. They relate but are individual."
            tableView.isHidden = true
            topicView.isHidden = false
        }else{
            descLabel.text = "Marks are pieces of writings that continue off one another. Use these to create progressive writing."
            tableView.isHidden = false
            topicView.isHidden = true
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
    
}

