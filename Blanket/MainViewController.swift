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
import UserNotifications
import PopupDialog

class MainViewController: UIViewController {

    @IBOutlet weak var dayCircleView: UIImageView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var entryBtn: UIButton!
    
    @IBOutlet weak var reminderButtonOnOff: UIButton!
    
    @IBOutlet weak var reminderButton: UIButton!

    @IBOutlet weak var emoteButton: UIButton!
    var ref:FIRDatabaseReference?
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    let center = UNUserNotificationCenter.current()
    
    var effect:UIVisualEffect!
    
    var stats:[String:Int] = [:]
    var timer:Timer?
    
    //------Reminder globals-----
    var isReminder = false
    var dateString = ""

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupViewButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    let tap = UITapGestureRecognizer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setOverlay()
        ref = FIRDatabase.database().reference()
        checkUser()
        getData()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler:{didAllow, error in
            localNotificationAllowed = didAllow
            self.checkSwitch()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.checkView), name: NSNotification.Name(rawValue: mySpecialNotificationKey), object: nil)
        
        checkForReminder()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setOverlay(){
        if let window = UIApplication.shared.keyWindow {
            overlay.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
            window.addSubview(overlay)
        }
        checkConnectivity()
        effect = blurView.effect
        blurView.effect = nil
    }
    
    func checkConnectivity(){
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func setLabels(){
        setDate()
    }
    
    func checkLastAccess(){
        if Calendar.current.isDateInToday(LastAccess.date as Date) {
            let image = UIImage(named: "day_circle.png") as UIImage?
            dayCircleView.image = image
        }
        else{
        }
        
    }
    
    // Set the date to the front label
    func setDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        dateLabel.text = (dateFormatter.string(from: NSDate() as Date))
    }
    
    //Retrieve all the stats of the user from firebase
    //Checks which badges the user has earned and puts all the information into a local struct to reduce redundant callss
    func getData(){
        ref?.child("users").child(uid).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            self.textLabel.text = (String(describing: self.stats["currentStreak"]!))
            Stats.avgWordcount = (self.stats["avgWordcount"]!)
            Stats.currentStreak = (self.stats["currentStreak"])!
            Stats.longestStreak = (self.stats["longestStreak"])!
            Stats.totalWordcount = (self.stats["totalWordcount"])!
            Stats.totalEntries = (self.stats["totalEntries"])!
            Stats.totalTime = (self.stats["totalTime"])!
            myBadges.checkBadge()
            self.getLvl()
            self.overlay?.removeFromSuperview()
            myBadges.updated = true
          
        })
        ref?.child("users").child(uid).child("LastAccess").observe(FIRDataEventType.value, with: {
            (snapshot) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
            let date = dateFormatter.date(from: (snapshot.value as! String))
            let toString = dateFormatter.string(from: date!)
            if date != nil{
            LastAccess.date = (date! as Date)
            }else{
                return
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
        
        //First FB query gets all the Marks that belong to the user using uid
        ref?.child("Marks").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard snapshot.exists() else{ return }
            guard self != nil else { return }
            let markSnap = snapshot.value as? [String: Any]
            let ma:Mark = Mark(name: markSnap![Constants.Mark.marks]! as! String, key:snapshot.key, loadedString: markSnap![Constants.Mark.text] as! String)
            marks.append(ma)
            NotificationCenter.default.post(name: .reload, object: nil)
        })
        ref?.child("Topics").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard snapshot.exists() else{ return }
            guard self != nil else { return }
            let topicSnap = snapshot.value as? [String: Any]
            let topic:Topic = Topic(name: topicSnap![Constants.Topic.topics]! as! String, key:snapshot.key)
            self?.ref?.child("Topics").child(topic.key).child("entries").observe(.childAdded, with:{ [weak self] (snapshot) -> Void in
                let entrykey = snapshot.value as! String
                topic.entries.append(entrykey)
            })
            topics.append(topic)
            NotificationCenter.default.post(name: .reload, object: nil)
        })
        ref?.child("users").child(uid).child("LastEntry").observe(FIRDataEventType.value, with: {
            (snapshot) in
            if snapshot.value is NSNull{
                LastAccess.entry = ""
            }else{
                LastAccess.entry = snapshot.value as! String
            }
        })
        ref?.child("users").child(uid).child("Date").observe(FIRDataEventType.value, with: {
            (snapshot) in
            if snapshot.value is NSNull{
                StartDate.firstDay = "Jan 1, 2017"
            }else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let date = dateFormatter.date(from: snapshot.value as! String)
                dateFormatter.dateFormat = "yyyy MM dd"
                StartDate.firstDay = dateFormatter.string(from: date!)
            }
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
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
            let currentCalendar     = NSCalendar.current
            let now = Date()
            let tommorow = LastAccess.date.tomorrow as Date
            let nextMidnight = LastAccess.date.tomorrow.endOfDay as Date
            let diff = currentCalendar.dateComponents([.hour, .minute, .second], from: now, to: nextMidnight)
            let date = dateFormatter.string(from: (nextMidnight as Date))
            if (diff.hour! < 0 || diff.minute! < 0 || diff.second! < 0){
                FIRAnalytics.logEvent(withName: "brokenStreak", parameters: nil)
                ref?.child("users").child(uid).child("Stats").updateChildValues(["currentStreak":0])
                showBrokenStreak()
            }
    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    func newBadgeEarned(_ timer:Timer) {
        
        if (self.isViewLoaded && (self.view.window != nil)) {
        if let badge = timer.userInfo as? IndividualBadge{
        let title = badge.name
        let message = badge.message
        let image = badge.image
        
        let popup = PopupDialog(title: title, message: message, image: image)
        
        let buttonOne = CancelButton(title: "DONE") {
        }

        popup.addButtons([buttonOne])
        
        present(popup, animated: true, completion: nil)
        timer.invalidate()
        }
        }
        
    }
    
    func checkView(_ notification: NSNotification){
        if let badge = notification.userInfo?["badge"] as? IndividualBadge{
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.newBadgeEarned),userInfo: badge, repeats: true)
        }
        
    }
    
    @IBAction func reminderButtonPressed(_ sender: UIButton) {
        showTimeDialog()
        FIRAnalytics.logEvent(withName: "userSetsReminder", parameters: ["stuff":"stuff" as NSObject])
    }
    
    func showTimeDialog(animated: Bool = true) {
        let timeVC = TimeViewController(nibName: "TimeViewController", bundle: nil)
        // Create the dialog
        let popup = PopupDialog(viewController: timeVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        let buttonOne = DefaultButton(title: "Set Time", height: 60) {
            self.dateString = timeVC.selectedDate
            let trigger = self.setReminderTimer()
            self.didNotify(trigger: trigger)
            
        }
        
        popup.addButtons([buttonOne])
        
        present(popup, animated: animated, completion: nil)
    }
    
    
    func setReminderTimer() -> UNNotificationTrigger{
        
        reminderButton.setTitle(dateString, for: .normal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateString)
        let triggerDaily = Calendar.current.dateComponents([.hour,.minute], from: date!)
        
        return UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
    }
    
    func didNotify(trigger:UNNotificationTrigger){
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.subtitle = dateString
        content.body = "Make sure to write today!"
        content.sound = UNNotificationSound.default()
        
        let identifier = "Reminder"
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Could not request")
            }
        })
    }
    
    func checkSwitch(){
        if isReminder{
            FIRAnalytics.logEvent(withName: "alarm is turned on", parameters: nil)
            if !localNotificationAllowed {return}
            let image = UIImage(named: "alarm_button.png") as UIImage?
            reminderButtonOnOff.setBackgroundImage(image, for: .normal)
            reminderButton.isHidden = false
            reminderButton.isUserInteractionEnabled = true
        }else{
            FIRAnalytics.logEvent(withName: "alarm is turned off", parameters: nil)
            let image = UIImage(named: "alarm_button_off.png") as UIImage?
            reminderButtonOnOff.setBackgroundImage(image, for: .normal)
            center.removeAllPendingNotificationRequests()
            reminderButton.isHidden = true
            reminderButton.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func reminderDidChange(_ sender: UIButton) {
            self.isReminder = !self.isReminder
            checkSwitch()
    }
    
    func checkForReminder(){
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                self.isReminder = true
                self.reminderButton.setTitle(request.content.subtitle, for: .normal)
                self.center.add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        print("Could not request")
                    }
                })
            }
            if !self.isReminder{ (self.setTimeUI())}
            self.checkSwitch()
        })
        
    }
    
    func getLvl(){
        ref?.child("users").child(uid).child("EntryTime").observe(FIRDataEventType.value, with: {
            (snapshot) in
            print("how many times")
            guard snapshot.exists() else {
                EntryTime.level = 3
                EntryTime.regularTime = 300
                self.ref?.child("users").child(self.uid).child("EntryTime").updateChildValues(["regularTime":300])
                self.ref?.child("users").child(self.uid).child("EntryTime").updateChildValues(["level":3])
                return
            }
            if snapshot.value != nil{
                var entryTime = snapshot.value as? [String : Int] ?? [:]
                if entryTime["level"] != nil{
                    EntryTime.level = entryTime["level"]!
                }
                if entryTime["regularTime"] != nil{
                    EntryTime.regularTime = entryTime["regularTime"]!
                }
            }
            self.getTimeConstraints()
        })
    }

    func getTimeConstraints(){
        //When a user gets to the next level, they permanently change their regular time 
        let defaults = UserDefaults.standard
        //Lvl 3 if the user has at least 300 regular time then we add 15 seconds every week
        if EntryTime.level == 3{
            if Stats.currentStreak > 7{
                let num = Int(Stats.currentStreak/7)
                EntryTime.regularTime += (num * 15)
                if EntryTime.regularTime > 900{
                    EntryTime.regularTime = 900
                }
            }
        }
        //Lvl 2 user write starts writing 3 minutes a day increasing gradually till they reach levl 3
        if EntryTime.level == 2{
            //this method adds different amounts of time based on how far along they have gotten on the streaks.
            
            //if the time is 180 they need to check if their streaks can bring them to 300
            if EntryTime.regularTime == 180{
                if Stats.currentStreak > 3{
                    let num = Int(Stats.currentStreak/3)
                    EntryTime.regularTime += (num * 10)
                    if EntryTime.regularTime >= 300 {
                        ref?.child("users").child(uid).child("EntryTime").updateChildValues(["regularTime":300])
                    }
                }
            }
            //at 300 they dont need to check anymore
            if EntryTime.regularTime == 300{
                if Stats.currentStreak > 7{
                    let num = Int(Stats.currentStreak/7)
                    EntryTime.regularTime += (num * 15)
                    if EntryTime.regularTime > 900{
                        EntryTime.regularTime = 900
                    }
                }
            }
        }
        
        //Lvl1 beginner. They start at 1 minute a day and slowly progress to lvl 2
        if EntryTime.level == 1{
            //same as # 2
            if EntryTime.regularTime < 180{
                if Stats.currentStreak > 2{
                    let num = Int(Stats.currentStreak/2)
                    EntryTime.regularTime += (num * 10)
                    if EntryTime.regularTime >= 180 {
                        ref?.child("users").child(uid).child("EntryTime").updateChildValues(["regularTime":180])
                    }
                }
            }
            if EntryTime.regularTime == 180{
                if Stats.currentStreak > 3{
                    let num = Int(Stats.currentStreak/3)
                    EntryTime.regularTime += (num * 10)
                    if EntryTime.regularTime >= 300 {
                        ref?.child("users").child(uid).child("EntryTime").updateChildValues(["regularTime":300])
                    }
                }
            }
            if EntryTime.regularTime == 300{
                if Stats.currentStreak > 7{
                    let num = Int(Stats.currentStreak/7)
                    EntryTime.regularTime += (num * 15)
                    if EntryTime.regularTime > 900{
                        EntryTime.regularTime = 900
                    }
                }
            }
        }
        
        
        //clusterrrr fuckkk
        let continueTime = defaults.bool(forKey: "continue")
        if !continueTime {
            if Stats.totalEntries > 7 {
                let num = Int(Stats.totalEntries/10)
                if num > 1{
                    EntryTime.addTime += (num * 10)
                    if EntryTime.addTime > 420{
                        EntryTime.addTime = 420
                    }
                }
            }
        } else {
            EntryTime.addTime = 86400
        }
    }
    
    func setTimeUI(){
        reminderButton.setTitle("Set Reminder", for: .normal)
    }
    
    @IBAction func reminderSwitchPressed(_ sender: UISwitch) {
        isReminder = !isReminder
        animateIn()
        checkSwitch()
    }
    
    func animateIn(){
        self.view.addSubview(popupView)
        popupView.center = self.view.center
        
        popupView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
        
        dropShadow(color: .gray, offSet: CGSize(width: -1, height: 3), radius: 10, scale: true)
        
        UIView.animate(withDuration:0.4){
            self.blurView.effect = self.effect
            self.popupView.alpha = 1
            self.popupView.transform = CGAffineTransform.identity
            
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration:0.3, animations: {
            self.popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupView.alpha = 0
            
            self.blurView.effect = nil
        }) { (Bool) in
            self.popupView.removeFromSuperview()
        }
    }
    
    
    @IBAction func dismissPopup(_ sender: UIButton) {
        animateOut()
    }
    
    func showBrokenStreak(){
        animateIn()
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.7, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        popupView.layer.masksToBounds = false
        popupView.layer.shadowColor = color.cgColor
        popupView.layer.shadowOpacity = opacity
        popupView.layer.shadowOffset = offSet
        popupView.layer.shadowRadius = radius
        
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).cgPath
        popupView.layer.shouldRasterize = true
        popupView.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        popupViewButton.layer.masksToBounds = false
        popupViewButton.layer.shadowColor = color.cgColor
        popupViewButton.layer.shadowOpacity = opacity
        popupViewButton.layer.shadowOffset = offSet
        popupViewButton.layer.shadowRadius = radius
        
        popupViewButton.layer.shadowPath = UIBezierPath(rect: popupViewButton.bounds).cgPath
        popupViewButton.layer.shouldRasterize = true
        popupViewButton.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
    


