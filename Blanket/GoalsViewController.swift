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
    
    //------Reminder globals-----
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
        setTimeUI()
        checkForReminder()
        // Do any additional setup after loading the view.
    }
    
    func checkForReminder(){
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                self.isReminder = true
                self.center.add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        print("Could not request")
                    }
                })
            }
        })
        
    }
    
    func setTimeUI(){
        checkSwitch()
        reminderButton.layer.borderColor = UIColor.init(hex: 0x333333).cgColor
        reminderButton.layer.borderWidth = 1
        reminderButton.setTitle("12:00 PM", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setGoal()
    }
    
    func checkSwitch(){
        if isReminder{
            reminderButton.isHidden = false
            reminderButton.isUserInteractionEnabled = true
        }else{
            center.removeAllPendingNotificationRequests()
            reminderButton.isHidden = true
            reminderButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        isReminder = !isReminder
        checkSwitch()
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
        showTimeDialog()
    }
    
    
    func setReminderTimer(dateString: String) -> UNNotificationTrigger{
        
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
        content.body = "You haven't written an entry today"
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
    
    func showTimeDialog(animated: Bool = true) {
        let timeVC = TimeViewController(nibName: "TimeViewController", bundle: nil)
        // Create the dialog
        let popup = PopupDialog(viewController: timeVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = DefaultButton(title: "Done", height: 60) {
           let trigger = self.setReminderTimer(dateString: timeVC.selectedDate)
            self.didNotify(trigger: trigger)

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
