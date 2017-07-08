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
    var badgeWorkingOn = 0
    
    init(){
        badgeForADay = IndividualBadge.init(name: "A Fresh Start",message: "You wrote your first day! Writing is a long and fulfilling journey and you just took your first steps. ", earned:false, number:1)
        badges.append(badgeForADay)
        badgeFor3Days = IndividualBadge.init(name: "3 in a Row",message: "Three days in a row. This isn't a fluke anymore. You may have had your doubts but now you're confident that you can do this.", earned:false, number:3)
        badges.append(badgeFor3Days)
        badgeFor10Days = IndividualBadge.init(name: "Streak",message: "10 days in a row! You can start to see your progress now. Writing is another muscle, it's been sore the past couple days but now it's stronger than ever.", earned:false, number:10)
        badges.append(badgeFor10Days)
        badgeFor20Days = IndividualBadge.init(name: "Hot Streak",message: "21 Days! Congratulations you did it. This is how long it takes to develop a good habit. You can add writing to the same categories as drinking water and sleeping.", earned:false, number:21)
        badges.append(badgeFor20Days)
        badgeFor50Days = IndividualBadge.init(name: "The Half",message: "50 Days! That's almost two months! Looks like you're about to stop counting by day and start counting the month.", earned:false, number:50)
        badges.append(badgeFor50Days)
        badgeFor100Days = IndividualBadge.init(name: "The Big 100",message: "Triple digits. Not many people will reach this goal post. But here you are. It was no doubt a difficult journey, but you're not done yet. You've set your eyes on even bigger goals.", earned:false, number:100)
        badges.append(badgeFor100Days)
        badgeFor500Words = IndividualBadge.init(name: "The Calf",message: "Milo of Croton was said to have carried a calf with him since he as a boy. As the calf grew, so did the strength of Milo. 500 words seems like a calf, but with patience it will become a bull.", earned:false, number: 500)
        badges.append(badgeFor500Words)
        badgeFor2000Words = IndividualBadge.init(name: "The Turtle and the Hare",message: "The first 2000 words can come in the first couple days or the first couple weeks. The only important part is that it comes. Looks like it came to you.", earned:false, number: 2000)
        badges.append(badgeFor2000Words)
        badgeFor5000Words = IndividualBadge.init(name: "The Mouse",message: "5000 words can sneak up on you. At this point you're not counting anymore, the words just pour out of you with ease. The weight of writing everyday doesn't seem so heavy anymore.", earned:false, number: 5000)
        badges.append(badgeFor5000Words)
        badgeFor10000Words = IndividualBadge.init(name: "The Cat",message: "Quick and sly, you can write just about anywhere, anytime. No distractions or events can stop you from putting down your words every day.", earned:false, number:10000)
        badges.append(badgeFor10000Words)
        badgeFor25000Words = IndividualBadge.init(name: "The Rhino",message: "You just powered through the last 25,000 words. You're excited to meet your next wall so you can test how easy it will be to break through it.", earned:false, number:25000)
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
            badgeWorkingOn = 3
            ref?.updateChildValues(["badgeForADay":true])
            let badgeDict:[String: Any] = ["badge": badgeForADay]
            if updated {
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor3Days(){
        if length > 2{
            badgeWorkingOn = 10
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
            badgeWorkingOn = 20
            badgeFor10Days.earned = true
            ref?.updateChildValues(["badgeFor10Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor10Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor20Days(){
        if length > 20{
            badgeWorkingOn = 50
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
            badgeWorkingOn = 100
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
            badgeWorkingOn = 200
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
