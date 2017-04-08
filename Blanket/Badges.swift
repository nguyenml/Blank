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
    var badgeEarned = false // check if a badge has been earned
    
    var ref:FIRDatabaseReference?
    
    var badgeForADay = false
    var badgeFor5Days = false
    var badgeFor200Words = false
    var badgeFor500Words = false
    
    func checkBadge(){
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Badges")
        length = Stats.currentStreak
        words = Stats.totalWordcount
        if badgeForADay == false{
            checkBadgeForADay()
        }
        if badgeFor5Days == false{
            checkBadgeFor5Days()
        }
        if badgeFor200Words == false{
            checkBadgeFor200Words()
        }
        if badgeFor500Words == false{
            checkBadgeFor500Words()
        }
        
        if badgeEarned == true{
            badgeEarned = false
            
        }
    }
    
    func checkBadgeForADay(){
        if length > 0{
            badgeForADay = true
            badgeEarned = true
            ref?.updateChildValues(["badgeForADay":true])
        }
    }
    
    func checkBadgeFor5Days(){
        if length > 5{
            badgeFor5Days = true
            badgeEarned = true
            ref?.updateChildValues(["badgeFor5Days":true])
        }
    }
    
    func checkBadgeFor200Words(){
        if words > 199{
            badgeFor200Words = true
            badgeEarned = true
            ref?.updateChildValues(["badgeFor200Words":true])
                       print("sucess")
        }
    }
    
    func checkBadgeFor500Words(){
        if words > 499{
            badgeFor500Words = true
            badgeEarned = true
            ref?.updateChildValues(["badgeFor500Words":true])            
        }
    }
    
}
