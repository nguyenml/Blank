//
//  StatsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/19/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MBCircularProgressBar


class StatsViewController: UIViewController{
    
    struct statsBlock{
        var color:UIColor = UIColor.orange
        var numbersLabel = " "
        var definitionLabel = " "
        var gLabel = " "
    }

    @IBOutlet weak var progressCircle: MBCircularProgressBarView!
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
        //setupUI()
        setLabels()
    }
    
    func setupUI(){
        
//        clock.image = clock.image!.withRenderingMode(.alwaysTemplate)
//        clock.tintColor = UIColor.white
//        
//        calender.image = calender.image!.withRenderingMode(.alwaysTemplate)
//        calender.tintColor = UIColor.white
//        
//        pencil.image = pencil.image!.withRenderingMode(.alwaysTemplate)
//        pencil.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    
    //Updates all labels
    func setLabels(){
        userLabel.adjustsFontSizeToFitWidth = true;
        userLabel.minimumScaleFactor = 0.5
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
        setGoal()
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
    
    func secondsToMinutes(seconds:Int) -> Int{
        return seconds / 60
    }
    
    func convertTime() -> String{
        
//        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: (Stats.totalTime))
        var time:String
//        if h < 12{
//            time = String(h) + " hr " + String(m) + " mn "
//        }
//        else{
//             //comeback TO this when moving on
//            time = String(h) + " " + String(m)
//        }
        time = String(secondsToMinutes(seconds: Stats.totalTime)) + " mins"
        
        return time
    }
    
    func setGoal(){
        let progress = Float(String(Stats.currentStreak))! / Float(myBadges.badgeWorkingOn)
        progressCircle.value = CGFloat(Float(progress*100))
    }
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
}
