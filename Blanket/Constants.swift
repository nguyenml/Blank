//a
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
import UserNotifications

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Prompt {
        static let prompt = "prompt"
        static let type = "type"
        static let number = "number"
        static let hash = "hash"
    }
    
    struct Entry {
        static let date = "date"
        static let text = "text"
        static let wordCount = "wordcount"
        static let uid = "uid"
        static let emotion = "emotion"
        static let timestamp = "timestamp"
        static let mark = "mark"
        static let topic = "topic"
        static let textStart = "textStart"
        static let totalTime = "totalTime"
        static let hashtags = "hashtags"
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
        static let text = "text"
    }
    
    struct Topic {
        static let topics = "topics"
        static let uid = "uid"
    }
    
    struct StartDate{
        static var date = "date"
    }
}
var marks:[Mark] = []
var topics:[Topic] = []
var entryDates: [Packet]! = []
var didWriteToday = false

struct Stats{
    static var currentStreak = 0
    static var longestStreak = 0
    static var avgWordcount = 0
    static var totalWordcount = 0
    static var daysActive = 0
    static var totalEntries = 0
    static var totalTime = 0
}

struct EntryTime{
    static var regularTime = 300
    static var addTime = 180
    static var level = 0
    static var wordReq = 0
}

struct TimerHidden{
    static var isHidden = false
}

struct LastAccess{
    static var date = NSDate() as Date
    static var entry:String = ""
}

struct StartDate{
    static var firstDay:String = ""
}

struct Goals{
    static var endGoal = 0
    static var current = 0
    static var hasGoal = false
    static var goalId = "ID"
}

struct Statements{
    static var WEB:String = ""
    static var GOAL:String = ""
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
    
    func updateString(newString:String){
        loadedString = newString
    }
    
}

class Topic{
    var name:String
    var key:String
    var entries:[String] = []
    
    init(name:String, key:String){
        self.name = name
        self.key = key
    }
}

class IndividualBadge{
    var name:String
    var message:String
    var image:UIImage
    var earned:Bool
    var number:Int
    
    init(name:String, message:String, earned:Bool, number:Int, image:UIImage){
        self.name = name
        self.message = message
        self.earned = earned
        self.number = number
        self.image = image
    }
}

class Prompt{
    private var key:String
    private var prompt:String
    private var number:Int
    private var type:Int
    private var hash:String
    private var used:Bool
    
    init(key:String,prompt:String,number:Int,type:Int,hash:String, used:Bool = false){
        self.key = key
        self.prompt = prompt
        self.number = number
        self.type = type
        self.hash = hash
        self.used = used
    }
    
    func getKey()->String{
        return key
    }
    
    func getPrompt()->String{
        return prompt
    }
    
    func getNumber()->Int{
        return number
    }
    
    func getType()->Int{
        return type
    }
    
    func getHash()->String{
        return hash
    }
    func isUsed()->Bool{
        return used
    }
}

class Packet{
    var date:String
    var text:String
    var wordCount:String
    var uid:String
    var timestamp:String
    var order:Double = 0
    var key:String
    var mark:String
    var topic:String
    var textStart:String
    var totalTime:String
    var hashtags:[String]
    
    init(date:String, text:String, wordCount:String, uid:String, timeStamp:String, key:String, mark:String = "", topic:String = "", textStart:String = "", totalTime:String = "", hashtags:[String] = []){
        self.date = date
        self.text = text
        self.wordCount = wordCount
        self.uid = uid
        self.timestamp = timeStamp
        self.key = key
        self.mark = mark
        self.topic = topic
        self.textStart = textStart
        self.totalTime = totalTime
        self.hashtags = hashtags
        }
    
    func setOrder(order:String){
        self.order = Double(order)!
    }
    
    func setText(newText:String){
        text = newText
    }
    
    func setWC(newWC:String){
        wordCount = newWC
    }
    //check if packet has the hash
    func doesHaveHash(hashcode:String)-> Bool{
        if hashtags.isEmpty{
            return false
        }
        for hash in hashtags{
            if hash == hashcode{
                return true
            }
        }
        return false
    }
    
}

//Badges
let mySpecialNotificationKey = ".badgeForADay"

//Notys
var localNotificationAllowed = true
struct weeklyChallenges {
    static var amount = 0
    static var type = ""
    static var current = 0
}

