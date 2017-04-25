//
//  ELViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/11/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ELViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var ref:FIRDatabaseReference?
    
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    
    var entries: [FIRDataSnapshot]! = []
    var handle: FIRAuthStateDidChangeListenerHandle?
    var connectedRef:FIRDatabaseReference?
    
    var connected:Bool = true;

    var testCalendar = Calendar(identifier: .gregorian)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.bc
        currentDate = Date()
        checkConnectionWithFB()
        //sets table up to tableviewcell.xib
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        configureDatabase()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //Temporary measure before adding persistent state
    func checkConnectionWithFB(){
        connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef?.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.connected = true
            } else {
                self.connected = false
            }
        })
    }
    
    //This function retrieves data form FB and puts starts to enter it into the tableview
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.entries.append(snapshot)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.entries.count-1, section: 0)], with: .automatic)
            strongSelf.entries.reverse()
        })
    }
    
    // Creates each individual cell given the data of that cell's entry
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Dequeue cell
        let cell:CustomTableCell = self.tableView.dequeueReusableCell(withIdentifier: "CustomTableCell", for: indexPath) as! CustomTableCell
        // Unpack message from Firebase DataSnapshot
        let entrySnapshot = self.entries[indexPath.row]
        guard let entry = entrySnapshot.value as? [String: String] else { return cell }
        let date = entry[Constants.Entry.date]
        let words = entry[Constants.Entry.wordCount]
        let preview = entry[Constants.Entry.text]
        cell.dateLabel?.text = date
        cell.previewLabel?.text = preview
        cell.wordCount?.text = words
        //when emotions come in
        // cell.imageView?.image = UIImage(named: "ic_account_circle")
        
        //Change color
        if ( indexPath.row % 2 == 0 ){
            cell.backgroundColor = Constants.backgroundColor.bc
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    //Returns the number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    //On selection of a cell, this function take the user to the entry the cell contains
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entrySnap = self.entries[indexPath.row]
        let entry = entrySnap.value as? [String: String]
        
        self.performSegue(withIdentifier: "segueToEntry", sender: entry);
    }
    
    //date
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        
        _ = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        _ = DateFormatter().shortWeekdaySymbols[weekday-1]
        
        _ = testCalendar.component(.day, from: currentDate)
        
    }
    
    
    //Creates a segue to take the user to a specific entry
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToEntry" {
            guard let object = sender as? [String:String] else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
        }
    }
    
    //Go back to main view
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    @IBAction func unwindToLogs(segue: UIStoryboardSegue) {}
    
    
}
