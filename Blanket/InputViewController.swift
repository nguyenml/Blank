//
//  InputViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class InputViewController: UIViewController, UITextViewDelegate {
    
    var ref:FIRDatabaseReference?
    var entryRef:FIRDatabaseReference?

  //  @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var addMin: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    weak var iTimer = Timer();
    
    @IBOutlet weak var wordCountLabel: UIButton!
    @IBOutlet var timer: UILabel!
    var counter = 0;
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        entryRef = ref?.child("Entry").childByAutoId()
        self.textField.delegate = self
        getMostRecent()
    }
    
    // get rid of xcode backspace error, hide buttons, add notification for keyboard scrolling
    func setupInput(bool : Bool){
        if bool{
            textField.text = currentPacket?.text
            counter = Int((currentPacket?.totalTime)!)!
            extraCounter = Int((currentPacket?.totalTime)!)!
            if ((currentPacket?.hasMark())! || (currentPacket?.hasTopic())!){
                //markButton.isHidden = true
                continuedEntryWithMark = true
                loadedWordCount = (Int(wordCount(str: textField.text!)))
            }
            setTimeFormat()
            extraTime = true
            addMin.isHidden = false
            backButton.isHidden = false
            textField.isEditable = false
            wordCountLabel.isHidden = true
            
        }else{
            textField.text = ""
            addMin.isHidden = true
            backButton.isHidden = true
            wordCountLabel.isHidden = true
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //setup text everytime coming back form markVC
    override func viewDidAppear(_ animated: Bool) {
        timeSituations()
    }
    
    func topicOrMark(){
        if mot == nil {return}
        if mot{
            textField.text = currentString
        }
        else{
            setupDataOnReturn()
        }
    }
    
    func timeSituations(){
        //4 possible outlooks
        //user is below 5 minutes and goes to marks, when he comes back it should restart and nothing else happens
        if (counter < 300){
            iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            topicOrMark()
            return
        }
        //path 2 - the user just finished and goes to mark, the timer should come back invalidated and the entry should already be posted/updated. still need to update the mark though so
        if(counter == 300){
            topicOrMark()
            reset()
            return
        }
        //path 3 - the user has finished up this writing piece, the timer should be above 300 and less than extraTime. Do not post, but keep the timer going
        if (counter < extraCounter && counter > 300){
            iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            topicOrMark()
            return
        }

        //path 4 - the user has finished up writing and finished his extra minute as well
        
        if (counter == extraCounter){
            topicOrMark()
            reset()
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
        if timer == nil{
            reset()
        }
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func textView(textView: UITextView, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = wordCount(str: textField.text)
        //change the value of the label
        wordCountLabel.setTitle(String(newLength),for: .normal)
        //you can save this value to a global var
        //myCounter = newLength

        return true
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
                reset()
            }
            
        }
        else{
            if counter < 300{
                counter = counter + 1;
            }
            if counter >= 300{
                addMin.isHidden = false
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
                let time:Int = stats["totalTime"]! + 300
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
                let time:Int = stats["totalTime"]! + 60
                
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

//        if markKey != nil{
//            if mot{
//                mdata[Constants.Entry.topic] = name
//                ref?.child("Topics").child(markKey).child("entries").updateChildValues([key:key])
//            }else{
//                mdata[Constants.Entry.mark] = name
//                ref?.child("Marks").child(markKey).child("entries").updateChildValues([key:key])
//                ref?.child("Marks").child(markKey).child("text").setValue(textField.text)
//                mdata[Constants.Entry.textStart] = concatString(str: currentString)
//            }
//        }
//        else{
//            //mdata[Constants.Entry.textStart] = textField.text
//        }
        entryRef?.setValue(mdata)
        updateLastAccess(date: dateToString(), key: key)
    }
    
    //puts info into a struct
    func post(){
        //don't post if continued
        if skip() {return}
        var text = ""
        if mot == nil || mot{
            text = textField.text
        }else{
            text = currentString
        }
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
        timer.textColor = UIColor(hex: 0x17DF82)
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
    
    @IBAction func goToMarks(_ sender: UIButton) {
        var newString = textField.text
        if mot == nil || mot{
            currentString = newString!
        }
        iTimer?.invalidate()
        if (mot != nil && mot == false){
            ref?.child("Marks").child(markKey).child("text").setValue(textField.text)
        }
        performSegue(withIdentifier: "segueToContinue", sender: currentString)
    }
    
    @IBAction func unwindToInput(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToContinue"{
            guard let object = sender as? String else {return}
            let dvc = segue.destination as! ContinueViewController
            dvc.currentString = object
        }
        
    }
    @IBAction func addMinute(_ sender: UIButton) {
        textField.isEditable = true
        textField.isUserInteractionEnabled = true
        timer.textColor = UIColor(hex: 0xB8B8B8)
        extraCounter = extraCounter + 60
        extraTime = true
        updateCounter()
        iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
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
    
    func skip() -> Bool{
        if continueEntry{
            continueEntry = false
            return true
        }
        return false
    }

    @IBAction func switchTimerWordCount(_ sender: UIButton) {
        if wordCountLabel.isHidden{
            wordCountLabel.isHidden = false
            timer.isHidden = true
            addMin.isHidden = true
        }else{
            wordCountLabel.isHidden = true
            timer.isHidden = false
            if counter >= 300{
                addMin.isHidden = true
            }
        }
    }
}
