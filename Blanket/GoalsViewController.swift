//
//  GoalsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/13/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import PopupDialog
import Firebase
import MBCircularProgressBar
import UserNotifications

class GoalsViewController: UIViewController {
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var initGoalButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressVIew: MBCircularProgressBarView!

    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var reminderButton: UIButton!
    let center = UNUserNotificationCenter.current()
    
    let uid = FIRAuth.auth()!.currentUser!.uid
    var isReminder = false
    
    var ref:FIRDatabaseReference?

    var goalNumber = 0;
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initGoalButton.isUserInteractionEnabled = false;
        initGoalButton.layer.cornerRadius = 5
        setGoal()
        ref = FIRDatabase.database().reference()
        daysLabel.isHidden = true
        updateGoal()
        // Do any additional setup after loading the view.
    }
    
    func setTimeUI(){
        reminderButton.layer.borderColor = UIColor.init(hex: 0x333333) as! CGColor
        reminderButton.layer.borderWidth = 1
        reminderButton.setTitle("12:00 PM", for: .normal)
    }
    
    func didNotify(){
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "You haven't written an entry today"
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        
        let identifier = "Reminder"
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
            
        let triggerDaily = Calendar.current.dateComponents([hour,.minute,.second,], from: date)
            
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Could not request")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setGoal()
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        isReminder = !isReminder
        if isReminder{
            reminderButton.isHidden = false
            reminderButton.isUserInteractionEnabled = true
        }else{
            reminderButton.isHidden = true
            reminderButton.isUserInteractionEnabled = false
        }
    }
    
    func updateGoal(){
        if Goals.hasGoal{
            ref?.child("Goals").child(Goals.goalId).child("currentGoal").observe(FIRDataEventType.value, with: { (snapshot) -> Void in
                        Goals.current = snapshot.value as! Int
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToFB(withData data: [String: AnyObject]){
        var mdata = data
        mdata[Constants.Goal.currentGoal] = 1 as AnyObject
        mdata[Constants.Goal.uid] = uid as AnyObject
        mdata[Constants.Goal.inProgress] = true as AnyObject
        ref?.child("Goals").childByAutoId().setValue(mdata)
        Goals.current = 1
        Goals.endGoal = goalNumber
    }
    
    func post(){
        let goal = goalNumber
        let data = [Constants.Goal.endGoal: goal]
        addToFB(withData: data as [String : AnyObject] )
        setGoal()
    }
    
    func setGoal(){
        let progress = Float(Goals.current) / Float(Goals.endGoal)
        if Goals.hasGoal{
            initGoalButton.isUserInteractionEnabled = false;
            initGoalButton.backgroundColor = UIColor.flatGray
            progressVIew.value = CGFloat(Float(progress*100))
            endLabel.text = String(Goals.endGoal)
            currentLabel.text = String(Goals.current)
        }
        else{
            initGoalButton.isUserInteractionEnabled = true;
        }
    }
    
    @IBAction func setTime(_ sender: UIButton) {
    }
    
    
    func setReminderTimer(){
        let dateComp:NSDateComponents = NSDateComponents()
        let calender:NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let date:NSDate = calender.dateFromComponents(dateComp as DateComponents)! as NSDate
        
        dateComp.hour = 12;
        dateComp.minute = 55;
        dateComp.timeZone = NSTimeZone.system
        
        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date as Date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
    }
    
    /*!
     Displays a custom view controller instead of the default view.
     Buttons can be still added, if needed
     */
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        //CHANGE NAME
        let goalVC = NewGoalViewController(nibName: "RatingViewController", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: goalVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = DefaultButton(title: "Done", height: 60) {
            self.goalNumber = Int(goalVC.commentTextField.text!)!
            if self.goalNumber > 0{
                Goals.hasGoal = true
                self.post()
            }
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }

    @IBAction func addGoal(_ sender: Any) {
        showCustomDialog()
    }
}
