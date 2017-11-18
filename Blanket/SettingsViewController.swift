//
//  SettingsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/15/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class SettingsViewController: UIViewController {
    @IBOutlet weak var dailyEntryMinTime: UILabel!
    @IBOutlet weak var UINotificationSwitch: UISwitch!
    
    @IBOutlet weak var isHiddenSwitch: UISwitch!
    @IBOutlet weak var isHiddenText: UILabel!
    @IBOutlet weak var changeText: UILabel!
    
    var isReminder:Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTimeConstraints()
        checkNotification()
        checkIsTimerHidden()
    }
    
    

    @IBAction func signOut(_ sender: Any) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            safeReset()
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            FIRAnalytics.logEvent(withName: "logout", parameters: nil)
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    //resets all the local structs and classes that held the users local data
    func safeReset(){
        Stats.avgWordcount = 0
        Stats.currentStreak = 0
        Stats.daysActive = 0
        Stats.longestStreak = 0
        Stats.totalEntries = 0
        Stats.totalWordcount = 0
    }
    
    func checkNotification(){
            if localNotificationAllowed{
                UINotificationSwitch.isOn = true
                changeText.isHidden = true
                isReminder = true
            }
            else{
                UINotificationSwitch.isOn = false
                isReminder = false
            }
    }
    
    func checkIsTimerHidden(){
        let isTimerHidden = defaults.bool(forKey: "isTimerHidden")
        if(isTimerHidden){
            isHiddenSwitch.isOn = true
        } else {
            isHiddenSwitch.isOn = false
        }
        
    }
    
    func checkAddTime(){
        
        EntryTime.addTime = 180
        let num = Int(Stats.totalEntries/10)
        if num > 1{
            EntryTime.addTime += (num * 10)
            if EntryTime.addTime > 420{
                EntryTime.addTime = 420
            }
        }
    }
    
    func getTimeConstraints(){
        let entryTimeReq = EntryTime.regularTime
        let entryMinutes = Int(Double(entryTimeReq) / 60.0)
        let entrySeconds = Int(entryTimeReq - (entryMinutes*60))
        var strMinutes = ""
        if entryMinutes > 0{
            strMinutes = String(entryMinutes)
        }
        var strSeconds = String(format: "%02d", entrySeconds)
        dailyEntryMinTime.text = "\(strMinutes):\(strSeconds)"
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        self.isReminder = !self.isReminder
        if !localNotificationAllowed {
            UINotificationSwitch.isOn = false
        }
    }
    
    @IBAction func webLink(_ sender: UIButton) {
        guard let url = URL(string: "https://www.blankitapp.com/#contacts") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (error) in
                print("Open url : \(error)")
            })
        } else {
            UIApplication.shared.openURL(url)
        }
    }
 
    @IBAction func hiddenSwitchIsPressed(_ sender: UISwitch) {
        isHiddenSwitch.isOn = !isHiddenSwitch.isOn
        changeHiddenStatus(hidden: isHiddenSwitch.isOn)
    }
    
    func changeHiddenStatus(hidden:Bool){
        if(hidden){
            defaults.set(true, forKey: "isTimerHidden")
        } else {
            defaults.set(false, forKey: "isTimerHidden")
        }
    }
    
}
