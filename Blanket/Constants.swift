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
import Firebase

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
        static let mark = "mark"
    }
    
    struct Goal {
        static let endGoal = "endGoal"
        static let currentGoal = "currentGoal"
        static let uid = "uid"
        static let inProgress = "inProgress"
    }
    
    struct Mark {
        static let marks = "marks"
        static let uid = "uid"
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
var marks:[Mark] = []
var semaphore = DispatchSemaphore(value: 0)

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

class Mark{
    var name:String
    var key:String
    var entries:[String] = []
    var loadedString:String
    
    init(name:String, key:String, loadedString:String){
        self.name = name
        self.key = key
        self.loadedString = loadedString
    }
    
    func getString() ->String{
        return loadedString
    }
    
    func resetString(){
        loadedString = ""
    }
    
}

class Packet{
    var date:String
    var text:String
    var wordCount:String
    var uid:String
    var emotion:String
    var timestamp:String
    var order:Double = 0
    var key:String
    var mark:String
    
    init(date:String, text:String, wordCount:String, uid:String, emotion:String, timeStamp:String, key:String, mark:String = ""){
        self.date = date
        self.text = text
        self.wordCount = wordCount
        self.uid = uid
        self.emotion = emotion
        self.timestamp = timeStamp
        self.key = key
        self.mark = mark
        }
    
    func setOrder(order:String){
        self.order = Double(order)!
    }
    
    func hasMark()-> Bool{
        return(mark.isEmpty)
    }
}

