//
//  LogsViewController.swift
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
    
    var aPopupContainer: PopupContainer?
    var testCalendar = Calendar(identifier: .gregorian)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        configureDatabase()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            print(snapshot)
            strongSelf.entries.append(snapshot)
            print(strongSelf.entries.count)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.entries.count-1, section: 0)], with: .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        // Unpack message from Firebase DataSnapshot
        let entrySnapshot = self.entries[indexPath.row]
        guard let entry = entrySnapshot.value as? [String: String] else { return cell }
        let date = entry[Constants.Entry.date]
        cell.textLabel?.text = date
        //when emotions come in
        // cell.imageView?.image = UIImage(named: "ic_account_circle")
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entrySnap = self.entries[indexPath.row]
        let entry = entrySnap.value as? [String: String]
        
        self.performSegue(withIdentifier: "segueToEntry", sender: entry);
    }
    
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        
        _ = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        _ = DateFormatter().shortWeekdaySymbols[weekday-1]
        
        _ = testCalendar.component(.day, from: currentDate)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToEntry" {
            guard let object = sender as? [String:String] else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    @IBAction func unwindToLogs(segue: UIStoryboardSegue) {}
    
    
}
