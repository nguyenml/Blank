//
//  ELViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/11/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class ELViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var entriesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var ref:FIRDatabaseReference?
    
    var entries: [Packet]! = []
    
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    var handle: FIRAuthStateDidChangeListenerHandle?
    var connectedRef:FIRDatabaseReference?
    
    var connected:Bool = true;
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    var num = 0

    var testCalendar = Calendar(identifier: .gregorian)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        tableView.delegate = self
        tableView.dataSource = self
        configureDatabase()
    }
    
    func seperateDate(dateS:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: dateS)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }
    
    func seperateTime(dateS:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: dateS)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date!)
    }
    
    func loadbyN(loadNumber:UInt){
        
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]!,
                                    text: entrySnap[Constants.Entry.text]!,
                                    wordCount: entrySnap[Constants.Entry.wordCount]!,
                                    uid: entrySnap[Constants.Entry.uid]!,
                                    emotion: entrySnap[Constants.Entry.emotion]!,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]!,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]!
            )
            
            if snapshot.hasChild(Constants.Entry.topic){
                entry.topic = entrySnap[Constants.Entry.topic]!
            }
            
            if snapshot.hasChild(Constants.Entry.mark){
                entry.mark = entrySnap[Constants.Entry.mark]!
            }
            entry.setOrder(order: entry.timestamp)
            strongSelf.entries.append(entry)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.entries.count-1, section: 0)], with: .automatic)
            
            strongSelf.entries.sort(by: {$0.order < $1.order})
            strongSelf.tableView.reloadData()
        })
    }
    
    func updateDataOnChange(){
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childChanged, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            let changedKey = snapshot.key //the firebase key
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            for entry in strongSelf.entries{
                if entry.key == changedKey{
                    entry.setText(newText: entrySnap[Constants.Entry.text]!)
                    entry.setWC(newWC: entrySnap[Constants.Entry.wordCount]!)
                    if snapshot.hasChild(Constants.Entry.topic){
                        entry.topic = entrySnap[Constants.Entry.topic]!
                    }
                    if snapshot.hasChild(Constants.Entry.mark){
                        entry.mark = entrySnap[Constants.Entry.mark]!
                    }
                }
            }
            strongSelf.tableView.reloadData()
        })
    }
    
    //This function retrieves data form FB and puts starts to enter it into the tableview
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        loadbyN(loadNumber:10)
        // Listen for new messages in the Firebase database
        updateDataOnChange()

    }
    
    // Creates each individual cell given the data of that cell's entry
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = self.entries[indexPath.row]
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableCell") as! CustomTableCell
        let time = Int(entry.totalTime)!/60
        cell.dateLabel?.text = seperateDate(dateS: entry.date)
        cell.wordCount?.text = String(time) + " mins"
        
        //Change color
        if ( indexPath.row % 2 == 0 ){
            cell.backgroundColor = UIColor(hex: 0xE5E5E5)
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    //Returns the number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    //On selection of a cell, this function take the user to the entry the cell contains
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = self.entries[indexPath.row]
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
            guard let object = sender as? Packet else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
        }
        
        if segue.identifier == "segueToMark"{
            guard let object = sender as? String else { return }
            let dvc = segue.destination as! MarkOptionsViewController
            dvc.key = object
        }
        
        if segue.identifier == "unwindToInput"{
            guard let object = sender as? String else {return}
            let dvc = segue.destination as! InputViewController
            dvc.loadedString = object
        }
        
        if segue.identifier == "segueToCalendar"{
            guard let object = sender as? [Packet] else {return}
            let dvc = segue.destination as! CalendarViewController
            dvc.entries = object
        }
    }
    
    @IBAction func goToCalendar(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToCalendar", sender: entries);
    }
    
    //Go back to main view
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    @IBAction func unwindToLogs(segue: UIStoryboardSegue) {}
    
    
}
