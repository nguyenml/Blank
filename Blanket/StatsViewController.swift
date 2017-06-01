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
    
    struct statsBlock{
        var color:UIColor = UIColor.orange
        var numbersLabel = " "
        var definitionLabel = " "
        var gLabel = " "
    }
    
    @IBOutlet weak var circleAvatar: UIButton!
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var totalDays: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
    @IBOutlet weak var calender: UIImageView!
    @IBOutlet weak var pencil: UIImageView!
    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var currentDays: UILabel!
    @IBOutlet weak var highestStreak: UILabel!
    @IBOutlet weak var wordsPerDay: UILabel!
    
    @IBOutlet weak var wordsProgress: UIProgressView!
    @IBOutlet weak var currentProgress: UIProgressView!
    
    var entries : [Entry] = []
    var statsEntries : [statsBlock] = []
    
    let myDefaults = UserDefaults.standard
    var total : Int = 0
    var ref:FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        getData()
        setupUI()
        setLabels()
    }
    
    func setupUI(){
        circleAvatar.layer.borderWidth = 1
        circleAvatar.layer.cornerRadius = self.circleAvatar.frame.size.width / 2;
        circleAvatar.layer.masksToBounds = true
        circleAvatar.layer.borderColor = UIColor.white.cgColor
        circleAvatar.backgroundColor = UIColor.gray
        
        clock.image = clock.image!.withRenderingMode(.alwaysTemplate)
        clock.tintColor = UIColor.white
        
        calender.image = calender.image!.withRenderingMode(.alwaysTemplate)
        calender.tintColor = UIColor.white
        
        pencil.image = pencil.image!.withRenderingMode(.alwaysTemplate)
        pencil.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    
    //Updates all labels
    func setLabels(){
        currentDays.text = String(Stats.currentStreak)
        highestStreak.text = String(Stats.longestStreak)
        
        currentProgress.progressTintColor = UIColor.orange
        let fractionalProgress = Float(Stats.currentStreak)/Float(Stats.longestStreak)
        //let animated = Stats.currentStreak != 0
        currentProgress.progress = fractionalProgress
        
        wordsPerDay.text = String(Stats.avgWordcount)
        wordsProgress.progressTintColor = UIColor.yellow
        fetchUser()
        updateLabels()
    }
    
    func updateLabels(){

        totalDays.text = String(Stats.totalEntries)
        wordCount.text = String(Stats.totalWordcount)
        totalTime.text = convertTime()
    }
    
    //find user and find user display name
    func fetchUser(){
        let user = FIRAuth.auth()?.currentUser
        userLabel.text = user?.displayName?.capitalizingFirstLetter()
                circleAvatar.setTitle(user?.displayName?[0].capitalized, for: .normal)
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func convertTime() -> String{
        //entries will have counter times soon
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: (Stats.totalEntries*300))
        var time:String
        if h < 12{
            time = String(h) + ":" + String(m)
        }
        else{
             //comeback TO this when moving on
            time = String(h) + " " + String(m)
        }
        
        return time
    }
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
}
