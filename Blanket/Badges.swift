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
    var badgeFor15Days:IndividualBadge
    var badgeFor30Days:IndividualBadge
    var badgeFor50Days:IndividualBadge
    var badgeFor90Days:IndividualBadge
    var badgeFor180Days:IndividualBadge
    var badgeFor365Days:IndividualBadge
    
//    var badgeFor500Words:IndividualBadge
//    var badgeFor2000Words:IndividualBadge
//    var badgeFor5000Words:IndividualBadge
//    var badgeFor10000Words:IndividualBadge
//    var badgeFor25000Words:IndividualBadge
    
    var badges = [IndividualBadge]()
    var badgeWorkingOn = 0
    
    init(){
        badgeForADay = IndividualBadge.init(name: "A Fresh Start",message: " Congratulations on your first day! You have a long journey ahead, one that will be successful and rewarding. ", earned:false, number:1, image:UIImage(named: "bronze_medal")!)
        badges.append(badgeForADay)
        
        badgeFor3Days = IndividualBadge.init(name: "3 in a Row",message: "Believe it or not, only 50% of people make it this far! Looking good so far.", earned:false, number:3,image:UIImage(named: "silver_medal")!)
        badges.append(badgeFor3Days)
        
        badgeFor10Days = IndividualBadge.init(name: "Streak",message: " Your first streak! This only one of the many you'll have in the future. Theres nothing like the feeling you get when you know the pieces are finally starting to move.", earned:false, number:10, image:UIImage(named: "gold_medal")!)
        badges.append(badgeFor10Days)
        
        badgeFor15Days = IndividualBadge.init(name: "Hot Streak",message: "15 Days! ", earned:false, number:15,image:UIImage(named: "bronze_trophy")!)
        badges.append(badgeFor15Days)
        
        badgeFor30Days = IndividualBadge.init(name: "Long Run",message: "30 Days! Your first month complete. No more tracking by days any more, you've got a new standard. ", earned:false, number:30,image:UIImage(named: "silver_trophy")!)
        badges.append(badgeFor30Days)
        
        badgeFor50Days = IndividualBadge.init(name: "Fifty Fifty",message: "50 days is a lot of days. Most people will never get this far. Your calendar is probably looking pretty good right now isn't it. Don't stop now!", earned:false, number:50,image:UIImage(named: "gold_trophy")!)
        badges.append(badgeFor50Days)
        
        badgeFor90Days = IndividualBadge.init(name: "A Quarter",message: "Remember when you got your first months? Well you just finished a whole quarter. There's no stopping now, your writing habits has become a part of you.", earned:false, number:90,image:UIImage(named: "bronze_super_trophy.png")!)
        badges.append(badgeFor90Days)
        
        badgeFor180Days = IndividualBadge.init(name: "The Half",message: "Finally the halfway mark. No one ever plans to write 6 months in a row, yet here we are. Theres only one big goal you're looking at now.", earned:false, number:180,image:UIImage(named: "silver_super_trophy")!)
        badges.append(badgeFor180Days)
        
        badgeFor365Days = IndividualBadge.init(name: "The end of the Year",message: "1 Year of writing, every single day. What an accomplomplishment. You should feel proud of yourself, less than 1 percent of people will ever get to this point.", earned:false, number:365,image:UIImage(named: "gold_super_trophy")!)
        badges.append(badgeFor365Days)
        
//        badgeFor500Words = IndividualBadge.init(name: "The Calf",message: "Milo of Croton was said to have carried a calf with him since he as a boy. As the calf grew, so did the strength of Milo. 500 words seems like a calf, but with patience and persistence it will become a bull.", earned:false, number: 500,image:UIImage(named: "light_blue_progression.png")!)
//        badges.append(badgeFor500Words)
//        badgeFor2000Words = IndividualBadge.init(name: "The Turtle and the Hare",message: "The first 2000 words can come in the first couple days or the first couple weeks. The only important part is that it comes at all.", earned:false, number: 2000,image:UIImage(named: "green_red_progression.png")!)
//        badges.append(badgeFor2000Words)
//        badgeFor5000Words = IndividualBadge.init(name: "The Mouse",message: "5000 words can really sneak up on you! At this point you're not counting anymore, the words just pour out of you with ease. The weight of writing everyday isn't so heavy anymore.", earned:false, number: 5000,image:UIImage(named: "dark_green_blue_progression.png")!)
//        badges.append(badgeFor5000Words)
//        badgeFor10000Words = IndividualBadge.init(name: "The Cat",message: "Quick and sly, you can write just about anywhere, anytime. No distractions or events can stop you from putting down your words every day.", earned:false, number:10000,image:UIImage(named: "day_circle_incomplete.png")!)
//        badges.append(badgeFor10000Words)
//        badgeFor25000Words = IndividualBadge.init(name: "The Rhino",message: "You just powered through the last 25,000 words. You're excited to meet your next wall so you can test how easy it will be to break through it.", earned:false, number:25000,image:UIImage(named: "day_circle_incomplete-1")!)
//        badges.append(badgeFor25000Words)
        
        
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
        if badgeFor15Days.earned == false{
            checkBadgeFor15Days()
        }
        if badgeFor30Days.earned == false{
            checkBadgeFor30Days()
        }
        if badgeFor50Days.earned == false{
            checkBadgeFor50Days()
        }
        if badgeFor90Days.earned == false{
            checkBadgeFor90Days()
        }
        if badgeFor180Days.earned == false{
            checkBadgeFor180Days()
        }
        if badgeFor365Days.earned == false{
            checkBadgeFor365Days()
        }

//        if badgeFor500Words.earned == false{
//            checkBadgeFor500Words()
//        }
//        if badgeFor2000Words.earned == false{
//            checkBadgeFor2000Words()
//        }
//        if badgeFor5000Words.earned == false{
//            checkBadgeFor5000Words()
//        }
//        if badgeFor10000Words.earned == false{
//            checkBadgeFor10000Words()
//        }
//        if badgeFor25000Words.earned == false{
//            checkBadgeFor25000Words()
//        }

        
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
    
    func checkBadgeFor15Days(){
        if length > 14{
            badgeWorkingOn = 30
            badgeFor15Days.earned = true
            ref?.updateChildValues(["badgeFor15Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor15Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor30Days(){
        if length > 29{
            badgeWorkingOn = 50
            badgeFor30Days.earned = true
            ref?.updateChildValues(["badgeFor30Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor30Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor50Days(){
        if length > 49{
            badgeWorkingOn = 90
            badgeFor50Days.earned = true
            ref?.updateChildValues(["badgeFor50Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor50Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor90Days(){
        if length > 89{
            badgeWorkingOn = 180
            badgeFor90Days.earned = true
            ref?.updateChildValues(["badgeFor90Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor90Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor180Days(){
        if length > 179{
            badgeWorkingOn = 180
            badgeFor180Days.earned = true
            ref?.updateChildValues(["badgeFor180Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor180Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }
    
    func checkBadgeFor365Days(){
        if length > 364{
            badgeWorkingOn = 730
            badgeFor365Days.earned = true
            ref?.updateChildValues(["badgeFor365Days":true])
            if updated {
                let badgeDict:[String: Any] = ["badge": badgeFor365Days]
                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
            }
        }
    }

    
//    func checkBadgeFor500Words(){
//        if words > 499{
//            badgeFor500Words.earned = true
//            ref?.updateChildValues(["badgeFor500Words":true])
//            if updated {
//                let badgeDict:[String: Any] = ["badge": badgeFor500Words]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
//            }
//        }
//    }
//    
//    func checkBadgeFor2000Words(){
//        if words > 1999{
//            badgeFor2000Words.earned = true
//            ref?.updateChildValues(["badgeFor2000Words":true])
//            if updated {
//                let badgeDict:[String: Any] = ["badge": badgeFor2000Words]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
//            }
//        }
//    }
//
//    func checkBadgeFor5000Words(){
//        if words > 4999{
//            badgeFor5000Words.earned = true
//            ref?.updateChildValues(["badgeFor5000Words":true])
//            if updated {
//                let badgeDict:[String: Any] = ["badge": badgeFor5000Words]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
//            }
//        }
//    }
//
//    func checkBadgeFor10000Words(){
//        if words > 9999{
//            badgeFor10000Words.earned = true
//            ref?.updateChildValues(["badgeFor10000Words":true])
//            if updated {
//                print("test")
//                let badgeDict:[String: Any] = ["badge": badgeFor10000Words]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
//            }
//        }
//    }
//
//    func checkBadgeFor25000Words(){
//        if words > 24999{
//            badgeFor25000Words.earned = true
//            ref?.updateChildValues(["badgeFor25000Words":true])
//            if updated {
//                let badgeDict:[String: Any] = ["badge": badgeFor25000Words]
//                NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: nil, userInfo:badgeDict)
//            }
//        }
//    }
    
}
