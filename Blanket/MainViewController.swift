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
import ChameleonFramework
import UserNotifications

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
    
    var colorArray = ColorSchemeOf(ColorScheme.complementary, color:UIColor.flatWhite, isFlatScheme:true)
    
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        checkUser()
        getData()
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler:{didAllow, error in})
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupUIColor(){
        entryBtn.layer.cornerRadius = 50;
        entryBtn.layer.borderColor = UIColor.white.cgColor
        entryBtn.layer.borderWidth = 1;
        entryBtn.setTitle("Write", for: .normal)
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
        setDate()
    }
    
    //--------------------------------------------------------
    //FOR TESTING//
    //------------------------
    func checkLastAccess(){
        if Calendar.current.isDateInToday(LastAccess.date as Date) {
            //entryBtn.isHidden = true
            //completedText.text = "You already wrote today"
            //completedText.isHidden = false
            setupUIColor()
        }
        else{
            setupUIColor()
        }
        
    }
    //--------------------------------------------------------
    //FOR TESTING//
    //------------------------
    
    //FOR IPHONE TESTING-------------
    //----------------------------------
    //func checkLastAccess(){
      //  if Calendar.current.isDateInToday(LastAccess.date as Date) {
        //    entryBtn.isHidden = true
          //  completedText.text = "You already wrote today"
            //completedText.isHidden = false
    //        setupUIColor()
     //   }
      //  else{
       //     setupUIColor()
        //}
        
    //}

    
    
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
            Stats.totalEntries = (self.stats["totalEntries"])!
            myBadges.checkBadge()
            self.setLabels()
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
                    Goals.hasGoal = true
                    Goals.goalId = goals.key
                }
            }
        })
        //problem child
        //cluster fuck
        //Temp fix unoptimized
        
        //First FB query gets all the Marks that belong to the user using uid
        ref?.child("Marks").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard snapshot.exists() else{ return }
            guard self != nil else { return }
            let markSnap = snapshot.value as? [String: Any]
            //creates a new mark for each one they own
            let ma:Mark = Mark(name: markSnap![Constants.Mark.marks]! as! String, key:snapshot.key, loadedString: "")
            
            //For each of those marks, query and find all the entries that have been marked for that particular ID
            self?.ref?.child("Marks").child(ma.key).child("entries").observe(.childAdded, with:{ [weak self] (snapshot) -> Void in
                let entrykey = snapshot.value as! String
                ma.entries.append(entrykey)
                self?.ref?.child("Entry").child(entrykey).child("text").observe(FIRDataEventType.value, with :{ (snapshot) -> Void in
                    guard snapshot.exists() else{
                        return
                    }
                    // Add that text to the loaded string, async call so this will return after the mark has been appended
                    ma.loadedString = ma.loadedString + (snapshot.value as! String) + "\n"
                })
                })
            //append all of that
            marks.append(ma)
            NotificationCenter.default.post(name: .reload, object: nil)
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
            ref?.child("users").child(uid).child("Stats").observe(FIRDataEventType.value, with: {
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
                print(start)
                let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date)
                print(end)
                let daysSinceWriting = end! - start!
                print(daysSinceWriting)
                if daysSinceWriting > 1{
                    ref?.child("users").child(uid).child("Stats").updateChildValues(["currentStreak":0])
                    if Goals.hasGoal{
                        ref?.child("Goals").child(Goals.goalId).child("inProgress").setValue(false)
                    }
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

