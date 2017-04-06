//
//  Badges.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/5/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import Foundation

class BadgeClass{
    var length:Int =  0
    var words:Int = 0
    
    func checkBadge(){
        length = Stats.currentStreak
        words = Stats.totalWordcount
        checkBadgeForADay()
        checkBadgeFor5Days()
        checkBadgeFor200Words()
        checkBadgeFor500Words()
    }
    
    func checkBadgeForADay(){
        if length > 0{
            Badges.badgeForADay = true
        }
    }
    
    func checkBadgeFor5Days(){
        if length > 4{
            Badges.badgeFor5Days = true
        }
    }
    
    func checkBadgeFor200Words(){
        if words > 199{
            Badges.badgeFor200Words = true
        }
    }
    
    func checkBadgeFor500Words(){
        if words > 499{
            Badges.badgeFor500Words = true
        }
    }
}
