//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import CZPicker

class MainViewController: UIViewController {
    
    @IBOutlet weak var EmojiLabel: UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var completedText: UILabel!
    @IBOutlet weak var entryBtn: UIButton!
    
    @IBOutlet weak var emoteButton: UIButton!
    var ref:FIRDatabaseReference?
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    
    var stats:[String:Int] = [:]
    var emotes = [String]()
    
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDate()
        ref = FIRDatabase.database().reference()
        checkUser()
        getData()
        setLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setEmotes(){
        
        emotes = ["😠 " + Constants.Emotions.angry,
                  "☺️ " + Constants.Emotions.content,
                  "😀 " + Constants.Emotions.excited,
                  "😢 " + Constants.Emotions.sad]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setLabels(){
        setEmotes()
        emoteButton.setTitle("Im Feeling..", for: .normal)
    }
    
    func checkLastAccess(){
        if Calendar.current.isDateInToday(LastAccess.date as Date) {
            entryBtn.isHidden = true
            completedText.text = "You already wrote today"
            completedText.isHidden = false
        }
        
    }
    
    
    // Set the date to the front label
    func setDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        dateLabel.text = (dateFormatter.string(from: NSDate() as Date))
    }
    
    //Retrieve all the stats of the user from firebase
    //Checks which badges the user has earned and puts all the information into a local struct to reduce redundant calls
    func getData(){
        ref?.child("users").child(uid).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            self.textLabel.text = ("Day" + " " + String(describing: self.stats["currentStreak"]!))
            
            Stats.avgWordcount = (self.stats["avgWordcount"]!)
            Stats.currentStreak = (self.stats["currentStreak"])!
            Stats.longestStreak = (self.stats["longestStreak"])!
            Stats.totalWordcount = (self.stats["totalWordcount"])!
            myBadges.checkBadge()
        })
        ref?.child("users").child(uid).child("LastAccess").observe(FIRDataEventType.value, with: {
            (snapshot) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let date = dateFormatter.date(from: (snapshot.value as! String))
            if date != nil{
            LastAccess.date = (date! as Date)
            }
            else{
                //no date
            }
            print(snapshot.value as! String)
            print(LastAccess.date)
            print(snapshot)
            self.checkLastAccess()
            self.resetStreak()
            
        })
        ref?.child("Goals").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            var pastGoals: [FIRDataSnapshot]! = []
            pastGoals.append(snapshot)
            if pastGoals.count == 0{
                return
            }
            for goals in pastGoals{
                let myGoal = goals.value as! [String:AnyObject]
                if ((myGoal["inProgress"] as! Bool)){
                    Goals.endGoal = myGoal["endGoal"]! as! Int
                    Goals.current = myGoal["currentGoal"]! as! Int
                }
            }
            print(Goals.endGoal)
            
        })
    }
    
    //TEMP TEMP TEMP TEMP TEMP FIX
    //PLEASE FIX THIS CANNOT GO PRODUCTION
    //THIS LITERALY MAKES NO SENSE
    //THIS IS SHIT
    // 4/09/17 3:49 a.m.
    func checkUser(){
        if FIRAuth.auth()?.currentUser != nil {
            let firebaseAuth = FIRAuth.auth()
            ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").observe(FIRDataEventType.value, with: {
                (snapshot) in
                self.stats = snapshot.value as? [String : Int] ?? [:]
                if(self.stats["currentStreak"] == nil){
                    do {
                        try firebaseAuth?.signOut()
                        self.dismiss(animated: true, completion: nil)
                    } catch let signOutError as NSError {
                        print ("Error signing out: \(signOutError.localizedDescription)")
                    }
                }
            })
        }else {
        }
    }
    
    func resetStreak(){
                let currentCalendar     = NSCalendar.current
                let start = currentCalendar.ordinality(of: .day, in: .era, for: LastAccess.date as Any as! Date)
                let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date)
                let daysSinceWriting = end! - start!
                print(daysSinceWriting)
                if daysSinceWriting > 1{
                    
                }
            }
    
    @IBAction func emoteBtnPressed(_ sender: UIButton) {
        let picker = CZPickerView(headerTitle: "I'm feeling", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = false
        picker?.show()
    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    
}

