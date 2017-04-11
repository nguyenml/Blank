//
//  StatsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/19/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class StatsViewController: UIViewController{

    @IBOutlet weak var CurrentStreak: UILabel!
    @IBOutlet weak var LongestStreak: UILabel!
    @IBOutlet weak var DaysActive: UILabel!
    @IBOutlet weak var AverageWordCount: UILabel!
    @IBOutlet weak var TotalWordCount: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    var entries : [Entry] = []
    
    let myDefaults = UserDefaults.standard
    var total : Int = 0
    
    var ref:FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        getData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }

    //Updates all labels
    func setLabels(){
        CurrentStreak.text = String(Stats.currentStreak)
        AverageWordCount.text = String(Stats.avgWordcount)
        TotalWordCount.text = String(Stats.totalWordcount)
        DaysActive.text = String(Stats.daysActive)
        LongestStreak.text = String(Stats.longestStreak)
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
            print(String(describing: FIRAuth.auth()!.currentUser!.uid))
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
        return end - start
    }
    
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
    
}
