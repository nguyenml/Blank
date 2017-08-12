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
    @IBOutlet weak var additionalMinTime: UILabel!
    
    @IBOutlet weak var addMinSwitch: UISwitch!
    
    @IBOutlet weak var changeText: UILabel!
    
    var isReminder:Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isOnOff()
        getTimeConstraints()
        checkNotification()
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
    
    func isOnOff(){
        let continueTime = defaults.bool(forKey: "continue")
        if continueTime {
            addMinSwitch.isOn = false
        } else {
            addMinSwitch.isOn = true
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
    
    func checkAddTime(){
        
        EntryTime.addTime = 180
        let num = Int(Stats.totalEntries/10)
        if num > 1{
            EntryTime.addTime += (num * 10)
            if EntryTime.addTime > 420{
                EntryTime.addTime = 420
            }
        }
    
        if addMinSwitch.isOn{
            getTimeConstraints()
            defaults.set(false, forKey: "continue")
            FIRAnalytics.logEvent(withName: "continue by minutes", parameters: nil)
        } else {
            EntryTime.addTime = 86400
            getTimeConstraints()
            defaults.set(true, forKey: "continue")
            FIRAnalytics.logEvent(withName: "continue indefinite", parameters: nil)
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
        
        let addTime = EntryTime.addTime
        if addTime == 86400 {
            additionalMinTime.text = "--:--"
        } else {
            let addMinutes = Int(Double(addTime)/60.0)
            let addSeconds = Int(addTime - (addMinutes*60))
            strMinutes = ""
            if addMinutes > 0{
                strMinutes = String(addMinutes)
            }
            strSeconds = String(format: "%02d", addSeconds)
            additionalMinTime.text = "\(strMinutes):\(strSeconds)"
        }
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
    
    @IBAction func addTimeSwitchPressed(_ sender: UISwitch) {
        checkAddTime()
    }
    
    @IBAction func webLink(_ sender: UIButton) {
        let url = URL(string: "www.google.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
}
