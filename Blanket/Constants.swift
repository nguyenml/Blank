//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import UIKit
import ChameleonFramework

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Entry {
        static let date = "date"
        static let text = "text"
        static let wordCount = "wordcount"
        static let uid = "uid"
        static let emotion = "emotion"
        static let timestamp = "timestamp"
    }
    
    struct Goal {
        static let endGoal = "endGoal"
        static let currentGoal = "currentGoal"
        static let uid = "uid"
        static let inProgress = "inProgress"
    }
    
    struct StartDate{
        static var date = "date"
    }
    struct Emotions{
        static let content = "Content"
        static let sad = "Dissapointed"
        static let angry = "Upset"
        static let excited = "Motivated"
    }
    
    struct backgroundColor{
        static let bc = UIColor.flatWhite
        static let bcd = UIColor.flatWhiteDark
    }

}

var imFeeling = "Content"

struct Stats{
    static var currentStreak = 0
    static var longestStreak = 0
    static var avgWordcount = 0
    static var totalWordcount = 0
    static var daysActive = 0
    static var totalEntries = 0
}

struct LastAccess{
    static var date = NSDate() as Date
}

struct Goals{
    static var endGoal = 0
    static var current = 0
    static var hasGoal = false
    static var goalId = "ID"
}

