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
    @IBOutlet weak var startDate: UILabel!

    @IBOutlet weak var allTimePercent: UILabel!
    @IBOutlet weak var currentStreakIndicator: UILabel!
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var totalDays: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
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
        setCurrentStreakBlock()
        highestStreak.text = String(Stats.longestStreak)
        fetchUser()
        updateLabels()
        setStartDate()
    }
    
    func setCurrentStreakBlock(){
        if Stats.currentStreak == 0 {
            let string = "Writing takes time and practice. Every day is another shot at building a healthy habit. "
            var attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName: UIFont(name: "Abel", size: 25.0)!])
            currentDays.attributedText = attributedString
            currentDays.lineBreakMode = .byWordWrapping
            currentDays.numberOfLines = 4
            currentStreakIndicator.isHidden = true
        } else {
            if Stats.currentStreak == 1 {
                currentDays.text = String(Stats.currentStreak) + " day"
            } else {
                currentDays.text = String(Stats.currentStreak) + " days"
            }
            currentStreakIndicator.isHidden = false
        }
    }
    
    func updateLabels(){

        totalDays.text = String(Stats.totalEntries)
        wordCount.adjustsFontSizeToFitWidth = true;
        wordCount.minimumScaleFactor = 0.5
        
        let time = convertTime()
        
        let string = "\(Stats.totalWordcount) words " as NSString
        
        let stringTotalTime = "\(time) minutes " as NSString
        
        var attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName: UIFont(name: "Abel", size: 23.0)!])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: "Abel", size: 60.0)!]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "\(Stats.totalWordcount)"))
        
        wordCount.attributedText = attributedString
        
        let attributedString2 = NSMutableAttributedString(string: stringTotalTime as String, attributes: [NSFontAttributeName: UIFont(name: "Abel", size: 23.0)!])
        
        attributedString2.addAttributes(boldFontAttribute, range: stringTotalTime.range(of: "\(time)"))
        totalTime.attributedText = attributedString2
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
    
    func convertTime() -> Int{
        var time:Int
        time = secondsToMinutes(seconds: Stats.totalTime)
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
    
    func setStartDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        let date = dateFormatter.date(from: StartDate.firstDay)
        getAllTime(startDate: date!)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let stringDate = dateFormatter.string(from: date!)
        
        startDate.text = "SINCE \(stringDate.uppercased())"
        
        
    }
    
    func getAllTime(startDate:Date){
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = Date()
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let percent = Int(Double(Stats.totalEntries)/Double(components.day! + 1) * 100)
        allTimePercent.text = " \(percent)%"
        
    }
        

    

    @IBAction func unwindToStats(segue: UIStoryboardSegue) {}
    
    
}
