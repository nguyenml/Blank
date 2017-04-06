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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }

    
    func setLabels(){
        CurrentStreak.text = String(Stats.currentStreak)
        AverageWordCount.text = String(Stats.avgWordcount)
        TotalWordCount.text = String(Stats.totalWordcount)
        DaysActive.text = String(Stats.daysActive)
        LongestStreak.text = String(Stats.longestStreak)
        fetchUser()
    }
    
    func fetchUser(){
        let user = FIRAuth.auth()?.currentUser?.uid
        userLabel.text = user
    }
    
    func findActiveDates()-> Int{
        let currentCalendar     = NSCalendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: myDefaults.object(forKey: "lastAccessDate") as! Date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date) else { return 0 }
        return end - start
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func safeReset(){
        myBadges = BadgeClass()
        Stats.avgWordcount = 0
        Stats.currentStreak = 0
        Stats.daysActive = 0
        Stats.longestStreak = 0
        Stats.totalEntries = 0
        Stats.totalWordcount = 0
        
    }
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
    
}
