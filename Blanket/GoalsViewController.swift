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
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var progressVIew: MBCircularProgressBarView!

    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var reminderButton: UIButton!
    let center = UNUserNotificationCenter.current()
    
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    //------Reminder globals-----
    var isReminder = false
    var dateString = ""
    
    var ref:FIRDatabaseReference?

    var goalNumber = 0;
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setGoal()
        ref = FIRDatabase.database().reference()
        updateGoal()
        setTimeUI()
        checkForReminder()
        // Do any additional setup after loading the view.
    }
    
    func checkForReminder(){
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                self.isReminder = true
                self.reminderSwitch.isOn = true
                self.checkSwitch()
                self.reminderButton.setTitle(request.content.subtitle, for: .normal)
                self.center.add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        print("Could not request")
                    }
                })
            }
            self.checkSwitch()
        })
        
    }
    
    func setTimeUI(){
        reminderButton.layer.borderColor = UIColor.init(hex: 0x333333).cgColor
        reminderButton.layer.borderWidth = 1
        reminderButton.layer.cornerRadius = 5
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
        if didWriteToday{
            Goals.current = 1
        }else{
            Goals.current = 0
        }
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
            progressVIew.value = CGFloat(Float(progress*100))
            endLabel.text = String(Goals.endGoal)
            currentLabel.text = String(Goals.current)
        }
    }
    
    @IBAction func setTime(_ sender: UIButton) {
        showTimeDialog()
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
    
    func showTimeDialog(animated: Bool = true) {
        let timeVC = TimeViewController(nibName: "TimeViewController", bundle: nil)
        // Create the dialog
        let popup = PopupDialog(viewController: timeVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = DefaultButton(title: "Set Time", height: 60) {
           self.dateString = timeVC.selectedDate
           let trigger = self.setReminderTimer()
           self.didNotify(trigger: trigger)

        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }

}
