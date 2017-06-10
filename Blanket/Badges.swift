//
//  Badges.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/5/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import Foundation
import Firebase

var myBadges = BadgeClass()

class BadgeClass{
    var length:Int =  0
    var words:Int = 0
    var updated = false
    
    var ref:FIRDatabaseReference?
    
    var badgeForADay:IndividualBadge
    var badgeFor3Days:IndividualBadge
    var badgeFor10Days:IndividualBadge
    var badgeFor20Days:IndividualBadge
    var badgeFor50Days:IndividualBadge
    var badgeFor100Days:IndividualBadge
    var badgeFor500Words:IndividualBadge
    var badgeFor2000Words:IndividualBadge
    var badgeFor5000Words:IndividualBadge
    var badgeFor10000Words:IndividualBadge
    var badgeFor25000Words:IndividualBadge
    
    var badges = [IndividualBadge]()
    
    init(){
        badgeForADay = IndividualBadge.init(name: "The Calf",message: "You Earned your first badge!", earned:false)
        badges.append(badgeForADay)
        badgeFor3Days = IndividualBadge.init(name: "3 in a Row",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor3Days)
        badgeFor10Days = IndividualBadge.init(name: "Streak",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor10Days)
        badgeFor20Days = IndividualBadge.init(name: "Hot Streak",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor20Days)
        badgeFor50Days = IndividualBadge.init(name: "The One",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor50Days)
        badgeFor100Days = IndividualBadge.init(name: "The Cow",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor100Days)
        badgeFor500Words = IndividualBadge.init(name: "The Ant",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor500Words)
        badgeFor2000Words = IndividualBadge.init(name: "The Beetle",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor2000Words)
        badgeFor5000Words = IndividualBadge.init(name: "The Mouse",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor5000Words)
        badgeFor10000Words = IndividualBadge.init(name: "The Cat",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor10000Words)
        badgeFor25000Words = IndividualBadge.init(name: "The Stallion",message: "You Earned your first badge!", earned:false)
        badges.append(badgeFor25000Words)
        
        
    }
    
    func checkBadge(){
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Badges")
        
        length = Stats.longestStreak
        words = Stats.totalWordcount
        if badgeForADay.earned == false{
            checkBadgeForADay()
        }
        if badgeFor3Days.earned == false{
            checkBadgeFor3Days()
        }
        if badgeFor10Days.earned == false{
            checkBadgeFor10Days()
        }
        if badgeFor20Days.earned == false{
            checkBadgeFor20Days()
        }
        if badgeFor50Days.earned == false{
            checkBadgeFor50Days()
        }
        if badgeFor100Days.earned == false{
            checkBadgeFor100Days()
        }
        if badgeFor500Words.earned == false{
            checkBadgeFor500Words()
        }
        if badgeFor2000Words.earned == false{
            checkBadgeFor2000Words()
        }
        if badgeFor5000Words.earned == false{
            checkBadgeFor5000Words()
        }
        if badgeFor10000Words.earned == false{
            checkBadgeFor10000Words()
        }
        if badgeFor25000Words.earned == false{
            checkBadgeFor25000Words()
        }

        
    }
    
    func checkBadgeForADay(){
        if length > 0{
            badgeForADay.earned = true
            ref?.updateChildValues(["badgeForADay":true])
            let badgeDict:[String: Any] = ["badge": badgeForADay]
            if updated {
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor3Days(){
        if length > 2{
            badgeFor3Days.earned = true
            ref?.updateChildValues(["badgeFor3Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor3Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor10Days(){
        if length > 9{
            badgeFor10Days.earned = true
            ref?.updateChildValues(["badgeFor10Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor10Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor20Days(){
        if length > 19{
            badgeFor20Days.earned = true
            ref?.updateChildValues(["badgeFor20Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor20Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor50Days(){
        if length > 49{
            badgeFor50Days.earned = true
            ref?.updateChildValues(["badgeFor50Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor50Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor100Days(){
        if length > 99{
            badgeFor100Days.earned = true
            ref?.updateChildValues(["badgeFor100Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor100Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }

    
    func checkBadgeFor500Words(){
        if words > 499{
            badgeFor500Words.earned = true
            ref?.updateChildValues(["badgeFor500Words":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor500Words]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor2000Words(){
        if words > 1999{
            badgeFor2000Words.earned = true
            ref?.updateChildValues(["badgeFor2000Words":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor2000Words]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor5000Words(){
        if words > 4999{
            badgeFor5000Words.earned = true
            ref?.updateChildValues(["badgeFor5000Words":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor5000Words]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor10000Words(){
        if words > 9999{
            badgeFor10000Words.earned = true
            ref?.updateChildValues(["badgeFor10000Words":true])
            if updated {
                print("test")
                let badgeDict:[String: Any] = ["badge": badgeFor10000Words]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor25000Words(){
        if words > 24999{
            badgeFor25000Words.earned = true
            ref?.updateChildValues(["badgeFor25000Words":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor25000Words]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
        
}
