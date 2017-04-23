//
//  StatsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/19/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase


class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    struct statsBlock{
        var progress = UIProgressView()
        var numbersLabel = " "
        var definitionLabel = " "
        var gLabel = " "
    }
    
    @IBOutlet weak var statsTable: UITableView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    var entries : [Entry] = []
    var statsEntries : [statsBlock] = []
    
    let myDefaults = UserDefaults.standard
    var total : Int = 0
    
    var ref:FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.bc
        ref = FIRDatabase.database().reference()
        getData()
        setupUI()
        statsTable.dataSource = self
        statsTable.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupUI(){

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    
    //Updates all labels
    func setLabels(){
        var cs = statsBlock()
        cs.definitionLabel = "Current Streak"
        cs.gLabel = "50"
        cs.numbersLabel = String(Stats.currentStreak)
        cs.progress.progressTintColor = UIColor.orange
        var aw = statsBlock()
        aw.definitionLabel = "Average Word Count"
        aw.numbersLabel = String(Stats.avgWordcount)
        cs.gLabel = "70,000"
        cs.progress.progressTintColor = UIColor.yellow
        statsEntries.append(cs)
        statsEntries.append(aw)
        fetchUser()
    }
    
    //find user and find user display name
    func fetchUser(){
        let user = FIRAuth.auth()?.currentUser
        userLabel.text = user?.displayName
    }
    
    //Logs a user out
    @IBAction func signOut(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            safeReset()
            
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    //resets all the local structs and classes that held the users local data
    func safeReset(){
        myBadges = BadgeClass()
        myBadges.reset()
        Stats.avgWordcount = 0
        Stats.currentStreak = 0
        Stats.daysActive = 0
        Stats.longestStreak = 0
        Stats.totalEntries = 0
        Stats.totalWordcount = 0
        
    }
    
    func getData(){
        ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Date").observeSingleEvent(of: .value,with: {
            (snapshot) in
           // print(String(describing: FIRAuth.auth()!.currentUser!.uid))
            Constants.StartDate.date = (snapshot.value as? String)!
            Stats.daysActive = self.findActiveDates()
            self.setLabels()
        })
    }
    
    //incomplete
    func findActiveDates()-> Int{
        let currentCalendar     = NSCalendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let startDate = dateFormatter.date(from: Constants.StartDate.date)
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: startDate!) else { return 0 }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date) else { return 0 }
        return (end - start) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statsEntries.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell:CustomStatsCell = self.statsTable.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! CustomStatsCell
        
        let entry = statsEntries[indexPath.row]
        cell.definitionLabel.text = entry.definitionLabel
        cell.gLabel.text = entry.gLabel
        cell.numbersLabel.text = entry.numbersLabel
        cell.progress = entry.progress
        
        return cell
    }
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
    
}
