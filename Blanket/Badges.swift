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
    
    var ref:FIRDatabaseReference?
    
    var badgeForADay = false
    var badgeFor3Days = false
    var badgeFor10Days = false
    var badgeFor20Days = false
    var badgeFor50Days = false
    var badgeFor100Days = false
    
    var badgeFor200Words = false
    var badgeFor500Words = false
    var badgeFor1000Words = false
    var badgeFor2000Words = false
    var badgeFor5000Words = false
    var badgeFor10000Words = false
    var badgeFor25000Words = false
    
    func checkBadge(){
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Badges")
        length = Stats.currentStreak
        words = Stats.totalWordcount
        if badgeForADay == false{
            checkBadgeForADay()
        }
        if badgeFor3Days == false{
            checkBadgeFor3Days()
        }
        if badgeFor200Words == false{
            checkBadgeFor200Words()
        }
        if badgeFor500Words == false{
            checkBadgeFor500Words()
        }
    }
    
    func checkBadgeForADay(){
        if length > 0{
            badgeForADay = true
            ref?.updateChildValues(["badgeForADay":true])
            ref?.updateChildValues(["badgeFor2Day":true])
        }
    }
    
    func checkBadgeFor3Days(){
        if length > 2{
            badgeFor3Days = true
            ref?.updateChildValues(["badgeFor3Days":true])
        }
    }
    
    func checkBadgeFor10Days(){
        if length > 9{
            badgeFor10Days = true
            ref?.updateChildValues(["badgeFor10Days":true])
        }
    }
    
    func checkBadgeFor20(){
        if length > 19{
            badgeFor20Days = true
            ref?.updateChildValues(["badgeFor20Days":true])
        }
    }
    
    func checkBadgeFor50(){
        if length > 49{
            badgeFor20Days = true
            ref?.updateChildValues(["badgeFor50Days":true])
        }
    }
    
    func checkBadgeFor100(){
        if length > 99{
            badgeFor20Days = true
            ref?.updateChildValues(["badgeFor100Days":true])
        }
    }
    
    func checkBadgeFor200Words(){
        if words > 199{
            badgeFor200Words = true
            ref?.updateChildValues(["badgeFor200Words":true])
        }
    }
    
    func checkBadgeFor500Words(){
        if words > 499{
            badgeFor500Words = true
            ref?.updateChildValues(["badgeFor500Words":true])            
        }
    }
    
    func checkBadgeFor1000Words(){
        if words > 999{
            badgeFor1000Words = true
            ref?.updateChildValues(["badgeFor1000Words":true])
        }
    }
    
    func checkBadgeFor2000Words(){
        if words > 1999{
            badgeFor2000Words = true
            ref?.updateChildValues(["badgeFor2000Words":true])
        }
    }
    
    func checkBadgeFor5000Words(){
        if words > 4999{
            badgeFor5000Words = true
            ref?.updateChildValues(["badgeFor5000Words":true])
        }
    }
    
    func checkBadgeFor10000Words(){
        if words > 9999{
            badgeFor10000Words = true
            ref?.updateChildValues(["badgeFor10000Words":true])
        }
    }
    
    func checkBadgeFor25000(){
        if words > 24999{
            badgeFor25000Words = true
            ref?.updateChildValues(["badgeFor25000Words":true])
        }
    }
    
    func reset(){
        badgeForADay = false
        badgeFor3Days = false
        badgeFor200Words = false
        badgeFor500Words = false
    }
    
}
