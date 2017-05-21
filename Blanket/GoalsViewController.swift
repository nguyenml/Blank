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
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey:
            "Hello_message_body", arguments: nil)
        
        // Deliver the notification in five seconds.
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
                                                        repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        print(center)
        center.add(request, withCompletionHandler: nil)
        
    }
    
    func didNotify(){
        if(isReminder){
            
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey:
                "Hello!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey:
                "Hello_message_body", arguments: nil)
            
            // Deliver the notification in five seconds.
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                            repeats: false)
            
            // Schedule the notification.
            let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            print(center)
            center.add(request, withCompletionHandler: nil)
            print("test 123 123")
            
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setGoal()
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        isReminder = !isReminder
        didNotify()
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
