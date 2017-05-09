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

class ContinueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var key:String!
    
    var loadString:String = ""
    
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = marks[indexPath.row]
        for entryKey in option.entries{
            ref?.child("Entry").child(entryKey).child("text").observe(FIRDataEventType.value, with :{ (snapshot) -> Void in
                self.loadString = self.loadString + (snapshot.value as! String)
            })
        }
        print(loadString)
        performSegue(withIdentifier: "unwindToInput", sender: loadString)
        
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
            let markName = textField?.text
            post(markName: markName!)
        }))
        
        func post(markName: String){
            let newMark = markName

        }
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backSegue(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToInput", sender: self)
    }
    
}

