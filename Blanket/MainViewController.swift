//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//
//<a href="https://icons8.com/icon/48/Edit">Edit icon credits</a>


import UIKit
import Firebase
import CZPicker
import UserNotifications
import PopupDialog

class MainViewController: UIViewController {


    @IBOutlet weak var userCount: UILabel!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var entryBtn: UIButton!
    
    @IBOutlet weak var timeToWriteLabel: UILabel!
    @IBOutlet weak var reminderButtonOnOff: UIButton!
    
    @IBOutlet weak var reminderButton: UIButton!
    
    var ref:FIRDatabaseReference?
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    let center = UNUserNotificationCenter.current()
    
    var effect:UIVisualEffect!
    
    var stats:[String:Int] = [:]
    var timer:Timer?
    
    //------Reminder globals-----
    var isReminder = false
    var dateString = ""

    //-------Popup View Stuff
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupViewButton: UIButton!
    @IBOutlet weak var popupBadgeImage: UIImageView!
    @IBOutlet weak var popupBadgeTitle: UILabel!
    @IBOutlet weak var popupBadgeMessage: UILabel!
    @IBOutlet weak var popupLowerStartTime: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    let tap = UITapGestureRecognizer()
    
    //------------weeklyChallenge
    @IBOutlet weak var progressWeeklyChallenge: UIView!
    
    @IBOutlet weak var weeklyChallengeLabel: UILabel!
    
    @IBOutlet weak var weeklyComplete: UIImageView!
    //-------quotes
    @IBOutlet weak var quoteLabel: UILabel!
    
    @IBOutlet weak var promptsButton: UIButton!

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
    
    override func viewDidLayoutSubviews() {
        checkWeekly()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setOverlay(){
        if let window = UIApplication.shared.keyWindow {
            overlay.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
            blurView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
            window.addSubview(overlay)
        }
        checkConnectivity()
        effect = blurView.effect
        blurView.effect = nil
        popupLowerStartTime.isHidden = true
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
            //dayCircleView.image = image
        }
        else{
        }
        
    }
    
    // Set the date to the front label
    func setDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        dateLabel.addCharactersSpacing(spacing: 3, text: (dateFormatter.string(from: NSDate() as Date)).uppercased())
    }
    
    //Retrieve all the stats of the user from firebase
    //Checks which badges the user has earned and puts all the information into a local struct to reduce redundant callss
    func getData(){
        ref?.child("users").child(uid).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            Stats.avgWordcount = (self.stats["avgWordcount"]!)
            Stats.currentStreak = (self.stats["currentStreak"])!
            Stats.longestStreak = (self.stats["longestStreak"])!
            Stats.totalWordcount = (self.stats["totalWordcount"])!
            Stats.totalEntries = (self.stats["totalEntries"])!
            Stats.totalTime = (self.stats["totalTime"])!
            self.textLabel.text = "Day \(String(describing: self.stats["totalEntries"]!))"
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
            if date != nil{
            LastAccess.date = (date! as Date)
            }else{
                return
            }
            self.checkLastAccess()
            self.resetStreak()
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
        getUserCount()
        changeQuote()
        getWeeklyChallenge()
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
            let defaultDate = dateFormatter.date(from: "Apr 1, 2017 11:00 AM")
            if (diff.hour! < 0 || diff.minute! < 0 || diff.second! < 0){
                FIRAnalytics.logEvent(withName: "brokenStreak", parameters: nil)
                if defaultDate != LastAccess.date{
                    if Stats.totalEntries < 14 {
                        showEasyBrokenStreak()
                    }
                }
            }
    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    func newBadgeEarned(_ timer:Timer) {
        
        if (self.isViewLoaded && (self.view.window != nil)) {
            if let badge = timer.userInfo as? IndividualBadge{
                let title = badge.name
                let message = badge.message
                let image = badge.image
                
                animateIn(image: image, title: title, message: message, type: 1)
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
            FIRAnalytics.logEvent(withName: "alarm_is_turned_on", parameters: nil)
            if !localNotificationAllowed {return}
            let image = UIImage(named: "doorbell_circle.png") as UIImage?
            reminderButtonOnOff.setBackgroundImage(image, for: .normal)
            reminderButton.isHidden = false
            reminderButton.isUserInteractionEnabled = true
        }else{
            FIRAnalytics.logEvent(withName: "alarm_is_turned_off", parameters: nil)
            let image = UIImage(named: "doorbell_off.png") as UIImage?
            reminderButtonOnOff.setBackgroundImage(image, for: .normal)
            center.removeAllPendingNotificationRequests()
            reminderButton.isUserInteractionEnabled = false
            reminderButton.isHidden = true
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
                    let num = Int(Stats.currentStreak/7)
                    EntryTime.regularTime += (num * 10)
                    if EntryTime.regularTime >= 300 {
                        ref?.child("users").child(uid).child("EntryTime").updateChildValues(["regularTime":300])
                    }
                }
            }
            if EntryTime.regularTime == 300{
                if Stats.currentStreak > 7{
                    let num = Int(Stats.currentStreak/15)
                    EntryTime.regularTime += (num * 15)
                    if EntryTime.regularTime > 900{
                        EntryTime.regularTime = 900
                    }
                }
            }
        }
        
        
        //clusterrrr fuckkk
        //
        let isTimerHidden = defaults.bool(forKey: "isTimerHidden")
        if(isTimerHidden){
            TimerHidden.isHidden = isTimerHidden
        }
        print("test isTImerhidden")
        print(isTimerHidden)
        
        EntryTime.addTime = 86400
        
        setTimeToWriteLabel()
    }
    
    func setTimeUI(){
        reminderButton.setTitle("Set Reminder", for: .normal)
    }
    
    @IBAction func reminderSwitchPressed(_ sender: UISwitch) {
        isReminder = !isReminder
        checkSwitch()
    }
    
    func animateIn(image:UIImage, title:String, message:String, type:Int){
        self.view.addSubview(popupView)
        self.view.addSubview(blurView)
        popupBadgeImage.image = image
        popupBadgeTitle.text = title
        popupBadgeMessage.text = message
        
        if type == 0{
            popupBadgeTitle.font = UIFont(name: "Abel", size: 26.0)!
            popupBadgeMessage.font = UIFont(name: "Abel", size: 10.0)!
        }
        if type == 1 {
            popupBadgeTitle.font = UIFont(name: "Abel", size: 32.0)!
            popupBadgeMessage.font = UIFont(name: "Abel", size: 12.0)!
        }
        
        popupView.center = self.view.center
        
        popupView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
        
        dropShadow(color: .lightGray, offSet: CGSize(width: -1, height: 3), radius: 10, scale: true)
        
        UIView.animate(withDuration:0.4){
            self.blurView.effect = self.effect
            self.popupView.alpha = 1
            self.popupView.transform = CGAffineTransform.identity
            self.view.bringSubview(toFront: self.popupView)
            
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration:0.3, animations: {
            self.popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupView.alpha = 0
            
            self.blurView.effect = nil
        }) { (Bool) in
            self.popupView.removeFromSuperview()
            self.blurView.removeFromSuperview()
            self.popupLowerStartTime.isHidden = true
        }
    }
    
    
    @IBAction func dismissPopup(_ sender: UIButton) {
        animateOut()
    }
    
    func showBrokenStreak(){
        let title = "Broken Streak"
        let message = "Oh no! It looks like you missed a day."
        let image = UIImage(named: "broken_chain")!
        animateIn(image:image,title:title, message:message, type:1)
    }
    
    func showEasyBrokenStreak(){
        let title = "Broken Streak"
        let message = "Oh no! It looks like you missed a day. It can be easy to forget to write when you're just starting off. So we're going to give a little some slack and keep the streak."
        popupLowerStartTime.isHidden = false
        let image = UIImage(named: "broken_chain")!
        animateIn(image:image,title:title, message:message, type:1)
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
        popupViewButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupViewButton.layer.shadowRadius =  4
        
        popupViewButton.layer.shadowPath = UIBezierPath(rect: popupViewButton.bounds).cgPath
        popupViewButton.layer.shouldRasterize = true
        popupViewButton.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func setTimeToWriteLabel() {
        
        let minutes = Int(EntryTime.regularTime/60)
        let seconds = Int(EntryTime.regularTime%60)

        let string = "Write for \(minutes) minutes and \(seconds) seconds" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName: UIFont(name: "Abel", size: 24.0)!])
    
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: "Abel", size: 30.0)!]
    
    
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "\(minutes)"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "\(seconds)"))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(hex: 0x17DF82) , range: string.range(of: "\(minutes)"))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(hex: 0x17DF82) , range: string.range(of: "\(seconds)"))
        
        timeToWriteLabel.attributedText = attributedString
            
    }
    
    //weeklyChallenges-------------------------------------------------------------------------------
    func getWeeklyChallenge(){
        ref?.child("Settings").child("weeklyChallenge").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            weeklyChallenges.type = value?["type"] as? String ?? ""
            weeklyChallenges.amount = value?["amount"] as? Int ?? 0
            self.checkWeekly()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkWeekly(){
        if Date().isInSameWeek(date: LastAccess.date as Date){
           ref?.child("users").child(String(describing: uid )).child("weeklywords").observe(FIRDataEventType.value, with: { (snapshot) in
                weeklyChallenges.current = snapshot.value as? Int ?? 0
                self.weeklyCompleted(progress: Double(weeklyChallenges.current)/Double(weeklyChallenges.amount))
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            ref?.child("users").child(String(describing: uid )).updateChildValues(["weeklywords": 0])
        }
    }
    
    func weeklyCompleted(progress:Double){
        //set the progress bar to be at the bottom of the parent view with width of 8
        //take parameters of parent views to make up for no layout
        weeklyChallengeLabel.text = "\(weeklyChallenges.current)/\(weeklyChallenges.amount) Words"
        
        let progressSize = (progressWeeklyChallenge.superview?.frame.width)! * CGFloat(progress)

        if progress < 1 {
            progressWeeklyChallenge.roundCorners(corners: [.bottomLeft, .topLeft], radius: 5)
            progressWeeklyChallenge.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: progressSize, height: (progressWeeklyChallenge.superview?.frame.height)!))
        } else {
            progressWeeklyChallenge.roundCorners(corners: [.allCorners], radius: 5)
            progressWeeklyChallenge.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 280, height: (progressWeeklyChallenge.superview?.frame.height)!))
            weeklyComplete.isHidden = false
        }
        
    }
    
    func getUserCount(){
        ref?.child("Settings").child("userCount").observe(FIRDataEventType.value, with: { snapshot in
            self.userCount.text = String(describing: snapshot.value!)
        })
    }
    
    func changeQuote(){
        ref?.child("Settings").child("quote").observe(FIRDataEventType.value, with: { snapshot in
            self.quoteLabel.text = String(describing: snapshot.value!)
        })
    }
    
    @IBAction func promptsButtonPressed(_ sender: UIButton) {
        animateIn(image: UIImage(named:"lightbulb_icon.png")!, title: "Daily Inspiration", message: "You go to check the mail and see a package. That's great because you love packages. This one is wrapped in a dark red fabric that you've never really seen before... or felt before. The box begans to shake once you pick it up. That's when you realize you haven't even ordered anything.", type:0)
    }
}



