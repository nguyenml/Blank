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

    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var totalDays: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
    @IBOutlet weak var calender: UIImageView!
    @IBOutlet weak var pencil: UIImageView!
    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var currentDays: UILabel!
    @IBOutlet weak var highestStreak: UILabel!
    
    @IBOutlet weak var IWEB: UILabel!
    
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
        setIWEB()
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
        fetchUser()
        updateLabels()
    }
    
    func updateLabels(){

        totalDays.text = String(Stats.totalEntries)
        wordCount.adjustsFontSizeToFitWidth = true;
        wordCount.minimumScaleFactor = 0.5
        wordCount.text = String(Stats.totalWordcount)
        totalTime.text = convertTime()
    }
    
    //find user and find user display name
    func fetchUser(){
        let user = FIRAuth.auth()?.currentUser
        userLabel.text = user?.displayName?.capitalizingFirstLetter()
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
        time = String(secondsToMinutes(seconds: Stats.totalTime))
        
        return time
    }
    
    func setIWEB(){
        ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Statement").child("WEB").observeSingleEvent(of: .value,with: {
            (snapshot) in
            if snapshot.exists(){
                Statements.WEB = (snapshot.value as? String)!
                self.IWEB.text = Statements.WEB
            } else {
                print("no web")
            }
        })
    }

    @IBAction func myWritingPressed(_ sender: UIButton) {
    }
    

    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
}
