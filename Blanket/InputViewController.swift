//
//  InputViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class InputViewController: UIViewController, UITextViewDelegate{
    
    var ref:FIRDatabaseReference?
    var entryRef:FIRDatabaseReference?

    @IBOutlet weak var tapView: UIView!
    
    @IBOutlet weak var backgroundRectangleOnCompletion: UIImageView!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var addMin: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    weak var iTimer = Timer();
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    var regularTime = EntryTime.regularTime
    var addTime = EntryTime.addTime
    var extraCounter = 300;
    var lwc = 0
    var currentPacket:Packet?
    
    //sent by previous view
    var loadedString:String!
    var markKey:String!
    var name:String!
    var loadedWC:Int16!
    var mot:Bool!
    //-----------------------
    
    
    var loadedWordCount = 0
    var extraTime = false
    var currentString:String = ""
    var continueEntry = false
    var continuedEntryWithMark = false
    
    var stats:[String:Int] = [:]
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    let tap = UITapGestureRecognizer()

    
    override func viewDidLoad() {
        FIRAnalytics.logEvent(withName: "UserWriting", parameters: nil)
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        entryRef = ref?.child("Entry").childByAutoId()
        textField.delegate = self
        setup()
        getMostRecent()
    }
    
    //ser up function to get text and view in to order
    func setup(){
        textField.font = UIFont(name: "OpenSans-Regular", size:17)
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(addMinute(_:)))
        tapView.addGestureRecognizer(tap)
    }
    
    // get rid of xcode backspace error, hide buttons, add notification for keyboard scrolling
    func setupInput(bool : Bool){
        if bool{
            textField.text = currentPacket?.text
            counter = Int((currentPacket?.totalTime)!)!
            extraCounter = Int((currentPacket?.totalTime)!)!
            if ((currentPacket?.hasMark())! || (currentPacket?.hasTopic())!){
                continuedEntryWithMark = true
                loadedWordCount = (Int(wordCount(str: textField.text!)))
            }
            setTimeFormat()
            extraTime = true
            addMin.isHidden = false
            addMin.setTitle("+",for: .normal)
            backButton.isHidden = false
            textField.isEditable = false
            timer.textColor = UIColor(hex: 0xFFFFFF)
            backgroundRectangleOnCompletion.image = UIImage(named: "green_rectangle.png")
            
        }else{
            textField.text = ""
            addMin.isHidden = true
            backButton.isHidden = true
            tapView.isHidden = true
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //setup text everytime coming back form markVC
    override func viewDidAppear(_ animated: Bool) {
        timeSituations()
    }
    
    func timeSituations(){
        //4 possible outlooks
        //user is below 5 minutes and goes to marks, when he comes back it should restart and nothing else happens
        if (counter < regularTime){
            iTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            return
        }
    }
    
    func setupDataOnReturn(){
        if loadedString == nil{
            return
        }
        else{
            textField.text = loadedString
        }
        loadedWordCount = Int(loadedWC)
    }
    
    //return to main view
    @IBAction func goBack(_ sender: UIButton) {
        if iTimer != nil{
            FIRAnalytics.logEvent(withName: "user left before time up", parameters: nil)
            reset()
        }
        FIRAnalytics.logEvent(withName: "user left after time up", parameters: nil)
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    
    func getMostRecent(){
        if LastAccess.entry == ""{
            setupInput(bool: false)
            return
        }
        
        ref?.child("Entry").child(LastAccess.entry).observeSingleEvent(of: .value, with: { snapshot in
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]!,
                                    text: entrySnap[Constants.Entry.text]!,
                                    wordCount: entrySnap[Constants.Entry.wordCount]!,
                                    uid: entrySnap[Constants.Entry.uid]!,
                                    emotion: entrySnap[Constants.Entry.emotion]!,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]!,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]!
                //textStart: entrySnap[Constants.Entry.textStart]!
            )
            //check to make sure this belongs to the correct UID
            if entry.uid != self.uid{
                self.setupInput(bool: false)
                return
            }
            if snapshot.hasChild(Constants.Entry.topic){
                entry.topic = entrySnap[Constants.Entry.topic]!
            }
            
            if snapshot.hasChild(Constants.Entry.mark){
                entry.mark = entrySnap[Constants.Entry.mark]!
            }
            let timestamp = entry.timestamp
            let calendar = NSCalendar.current
            var toInt = Double(timestamp)
            toInt = toInt! * -1.0
            let date = NSDate(timeIntervalSince1970: toInt!)
            if calendar.isDateInToday(date as Date) {
                self.currentPacket = entry
                self.continueEntry = true
                self.setupInput(bool: true)
                self.entryRef = self.ref?.child("Entry").child(LastAccess.entry)
            }else{
                self.setupInput(bool: false)
            }
        })
    }

    //Sets a timer up for 3 mins and shows user how long they spent
    func updateCounter() {
        if extraTime{
            if counter < extraCounter{
                counter = counter + 1;
            }
            if counter >= extraCounter{
                addMin.isHidden = false
                reset()
            }
            
        }
        else{
            if counter < regularTime{
                counter = counter + 1;
            }
            if counter >= regularTime{
                addMin.isHidden = false
                addMin.setTitle("+",for: .normal)
                // at 3 mins update info and reset timer for next use
                lwc = greaterThanZero()
                reset()
            }
        }
    setTimeFormat()
    }
    
    func setTimeFormat(){
        let minutes = Int(Double(counter) / 60.0)
        let seconds = Int(counter - (minutes*60))
        var strMinutes = ""
        if minutes > 0{
            strMinutes = String(minutes)
        }
        let strSeconds = String(format: "%02d", seconds)
        timer.text = "\(strMinutes):\(strSeconds)"
    }
    
    // retrieves data from firebase and updates all the users stats
    // using a transaction block because incrementations can cause updated values to be nil
    func updateStats(){
        let userStats = ref?.child("users").child(uid).child("Stats")
        userStats?.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var stats = currentData.value as? [String : Int]{
                let current = stats["currentStreak"]! + 1
                var longest = stats["longestStreak"]!
                let total = Int(stats["totalWordcount"]! + self.lwc)
                let entries:Int = stats["totalEntries"]! + 1
                let time:Int = stats["totalTime"]! + self.regularTime
                if current>longest{
                    longest = current
                }
                stats["currentStreak"] = current as Int
                stats["longestStreak"] = longest as Int
                stats["totalWordcount"] = total as Int
                stats["totalEntries"] = entries as Int
                stats["avgWordcount"] = total/entries as Int
                stats["totalTime"] = time as Int
                
                // Set value and report transaction success
                currentData.value = stats
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func smallUpdate(){
        let userStats = ref?.child("users").child(uid).child("Stats")
        userStats?.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var stats = currentData.value as? [String : Int]{
                let entries:Int = stats["totalEntries"]!
                let total = Int(stats["totalWordcount"]! - self.lwc + self.greaterThanZero())
                let extra = self.counter - self.regularTime
                let time:Int = stats["totalTime"]! + extra
                
                stats["avgWordcount"] = total/entries as Int
                stats["totalWordcount"] = total as Int
                stats["totalTime"] = time as Int
                currentData.value = stats
            }
           return FIRTransactionResult.success(withValue: currentData)
        })
        { (error, committed, snapshot) in
            if let error = error {
                 print(error.localizedDescription)
            }
        }
    }
    
    
    //submit struct to FB
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(greaterThanZero())
        mdata[Constants.Entry.date] = dateToString()
        mdata[Constants.Entry.uid] = uid
        mdata[Constants.Entry.emotion] = imFeeling
        mdata[Constants.Entry.timestamp] = getTimeStamp()
        mdata[Constants.Entry.totalTime] = String(counter)
        let key:String = (entryRef?.key)!
        entryRef?.setValue(mdata)
        updateLastAccess(date: dateToString(), key: key)
    }
    
    //puts info into a struct
    func post(){
        var text = textField.text!
        let data = [Constants.Entry.text: text]
        addToFB(withData: data)
        if extraTime{
            smallUpdate()
        }
        else{
            updateStats()
        }
    }
    
    func concatString(str:String) -> String{
        if str.isEmpty{
            return textField.text
        }
        if textField.text.range(of:loadedString) != nil{
            let copyText = textField.text
            let newString = copyText?.replacingOccurrences(of: loadedString, with: "")
            return newString!
        }
        let length = currentString.characters.count
        if length < 35 {
            return(str)
        }
        let startIndex = str.index(str.startIndex, offsetBy: 35)
        return(str.substring(to: startIndex))
    }
    
    //make sure wordCount > 0
    func greaterThanZero() -> Int{
        if(Int(wordCount(str: textField.text!)) - loadedWordCount) < 0{
            return 0
        }
        return (Int(wordCount(str: textField.text!)) - loadedWordCount)
    }
    
    func updateLastAccess(date: String, key: String){
        ref?.child("users").child(String(describing: uid )).updateChildValues(["LastAccess": date])
        ref?.child("users").child(String(describing: uid )).updateChildValues(["LastEntry": key])
    }
    
    //converts date to a string to be but into the db
    func dateToString() -> String{
        let dateform = DateFormatter()
        dateform.dateFormat = "MMM dd, yyyy h:mm a"
        
        return dateform.string(from: NSDate() as Date)
    }
    
    func getUTC() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    func getTimeStamp() ->String {
        let timestamp = (Date().timeIntervalSince1970)
        let reversedTimestamp = -1.0 * timestamp
        return String(reversedTimestamp)
    }
    
    //resets timer, buttons, and access
    func reset(){
        iTimer?.invalidate()
        backgroundRectangleOnCompletion.image = UIImage(named: "green_rectangle.png")
        timer.textColor = UIColor(hex: 0xFFFFFF)
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            tapView.isHidden = false
            tapView.addGestureRecognizer(tap)
        }
        backButton.isHidden = false
        textField.isEditable = false
        post()
    }
    
    //How many words the user wrote
    func wordCount(str:String) -> Int16{
        
        let wordList =  str.components(separatedBy: NSCharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{$0 != ""}
        
        return Int16(wordList.count)
    }
    
    //function for WC
    func SpecificWordCount(str:String, word:String) ->Int {
        let words = str.components(separatedBy: " "); var count = 0
        for thing in words {
            if thing == word {
                count += 1
            }
        }
        return count
    }
    
    @IBAction func unwindToInput(segue: UIStoryboardSegue) {}
    
    @IBAction func addMinute(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "addMinutes", parameters: nil)
        self.textField.becomeFirstResponder()
        tapView.removeGestureRecognizer(tap)
        tapView.isHidden = true
        textField.isEditable = true
        textField.isUserInteractionEnabled = true

        timer.textColor = UIColor(hex: 0x17DF82)
        backgroundRectangleOnCompletion.image = UIImage(named: "gray_rectangle.png")
        addMin.isHidden = true
        extraCounter = extraCounter + addTime
        extraTime = true
        updateCounter()
        iTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func updateTextView(notification:Notification){
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to:view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            textField.contentInset = UIEdgeInsets.zero
        }else{
            textField.contentInset = UIEdgeInsets(top:0,left:0,bottom:keyboardEndFrame.height, right:0)
            textField.scrollIndicatorInsets = textField.contentInset
        }
        textField.scrollRangeToVisible(textField.selectedRange)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView == textField)
        {
            print(wordCount(str: textView.text))
        }
    }
    
    func wordCount(string: String){
        var words = string.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        var wordDictionary = Dictionary<String, Int>()
        for word in words {
            if let count = wordDictionary[word] {
                wordDictionary[word] = count + 1
            } else {
                wordDictionary[word] = 1
            }
        }
        print(wordDictionary)
    }

}
