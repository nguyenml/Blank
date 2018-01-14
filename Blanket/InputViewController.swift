//
//  InputViewController.swift
//  Blanket
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class InputViewController: UIViewController, UITextViewDelegate{
    
    var ref:FIRDatabaseReference?
    var entryRef:FIRDatabaseReference?

    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var addMin: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    weak var iTimer = Timer();
    weak var downTimeTimer = Timer();
    
    @IBOutlet weak var topProgress: UIView!
    @IBOutlet var timer: UILabel!
    var downTimeResetter =  0
    var downTime = 0
    var counter = 0;
    var regularTime = EntryTime.regularTime
    var addTime = EntryTime.addTime
    var extraCounter = 300;

    var currentPacket:Packet?
    var isTimerOn = true
    
    
    @IBOutlet weak var showTimerButton: UIButton!
    
    @IBOutlet weak var liveWordCount: UILabel!
    var loadedWordCount = 0
    var extraTime = false
    var currentString:String = ""
    var continueEntry = false
    var continuedEntryWithMark = false
    var isTimerHidden = false
    
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //ser up function to get text and view in to order
    func setup(){
        textField.font = UIFont(name: "OpenSans-Regular", size:15)
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(addMinute(_:)))
        tapView.addGestureRecognizer(tap)
    }
    func setupTimerVisibility(){
        let isTimerHidden = TimerHidden.isHidden
        if(isTimerHidden){
            timer.isHidden = true
            liveWordCount.isHidden = false
            isTimerOn = false
        } else {
            timer.isHidden = false
            liveWordCount.isHidden = true
            isTimerOn = true
        }
    }
    
    // get rid of xcode backspace error, hide buttons, add notification for keyboard scrolling
    func setupInput(bool : Bool){
        if bool{
            textField.text = currentPacket?.text
            counter = Int((currentPacket?.totalTime)!)!
            extraCounter = Int((currentPacket?.totalTime)!)!
            loadedWordCount = (Int(wordCount(str: textField.text!)))
            setTimeFormat()
            extraTime = true
            addMin.isHidden = false
            addMin.setTitle("+",for: .normal)
            timer.textColor = UIColor(hex: 0x17DF82);
            backButton.isHidden = false
            textField.isEditable = false
            
        }else{
            textField.text = ""
            addMin.isHidden = true
            backButton.isHidden = true
            tapView.isHidden = true
            setupTimerVisibility()
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
            downTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDownTime), userInfo: nil, repeats: true)
            return
        }
    }

    //return to main view
    @IBAction func goBack(_ sender: UIButton) {
        FIRAnalytics.logEvent(withName: "user_down_time", parameters: ["downtime":downTime as NSObject])
        
        if iTimer != nil{
            FIRAnalytics.logEvent(withName: "user_left_before_time_up", parameters: nil)
            reset()
        }
        FIRAnalytics.logEvent(withName: "user_left_after_time_up", parameters: nil)
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    
    //get the most recent entry and find out if it is old enough to reuse
    func getMostRecent(){
        if LastAccess.entry == ""{
            setupInput(bool: false)
            return
        }
        
        ref?.child("Entry").child(LastAccess.entry).observeSingleEvent(of: .value, with: { snapshot in
            guard let entrySnap = snapshot.value as? [String: Any] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]! as! String,
                                    text: entrySnap[Constants.Entry.text]! as! String,
                                    wordCount: entrySnap[Constants.Entry.wordCount]! as! String,
                                    uid: entrySnap[Constants.Entry.uid]! as! String,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]! as! String,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]! as! String
            )
            //check to make sure this belongs to the correct UID
            if entry.uid != self.uid{
                self.setupInput(bool: false)
                return
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
        }
        else{
            if counter < regularTime{
                counter = counter + 1;
            }
            if counter == regularTime{
                noreset()
            }
        }
        
    setTimeFormat()
    }
    
    //sets the time to make it look like 1:15 instead of 75 seconds
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
                let total = Int(stats["totalWordcount"]! + self.loadedWordCount) //wut
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
        
        updateWeekly(update:false)
    }
    
    //this update is used for already completed entries
    func smallUpdate(){
        let userStats = ref?.child("users").child(uid).child("Stats")
        userStats?.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var stats = currentData.value as? [String : Int]{
                let entries:Int = stats["totalEntries"]!
                let total = Int(stats["totalWordcount"]! + self.greaterThanZero())
                var extra = self.counter - self.regularTime
                if extra < 0 {
                    extra = 0
                }
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
        updateWeekly(update:true)
        findHash()
    }
    
    
    //submit struct to FB
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(loadedWordCount + greaterThanZero())
        mdata[Constants.Entry.date] = dateToString()
        mdata[Constants.Entry.uid] = uid
        mdata[Constants.Entry.timestamp] = getTimeStamp()
        mdata[Constants.Entry.totalTime] = String(counter)
        let key:String = (entryRef?.key)!
        entryRef?.setValue(mdata)
                entryRef?.updateChildValues([Constants.Entry.hashtags:findHash()])
        updateLastAccess(date: dateToString(), key: key)

    }
    
    //puts info into a struct
    func post(){
        var text = textField.text!
        let data = [Constants.Entry.text: text]
        addToFB(withData: data)
        if extraTime{
            smallUpdate()
            print("small update \(loadedWordCount)")
        }
        else{
            loadedWordCount = (Int(wordCount(str: textField.text!)))
            updateStats()
            print("big update \(loadedWordCount)")
        }
    }
    
    //make sure wordCount > 0
    func greaterThanZero() -> Int{
        if(Int(wordCount(str: textField.text!)) - loadedWordCount) < 0{
            return 0
        }
        return (Int(wordCount(str: textField.text!)) - loadedWordCount)
    }
    
    //update the access time if completed
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
    
    //date formatter
    func getUTC() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    //time stamp setter and getter
    func getTimeStamp() ->String {
        let timestamp = (Date().timeIntervalSince1970)
        let reversedTimestamp = -1.0 * timestamp
        return String(reversedTimestamp)
    }
    
    //resets timer, buttons, and access
    func reset(){
        addMin.isHidden = false
        iTimer?.invalidate()
        downTimeTimer?.invalidate()
        if !isTimerOn {
            timer.isHidden = false
            isTimerOn = true
        }
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            tapView.isHidden = false
            tapView.addGestureRecognizer(tap)
        }
        backButton.isHidden = false
        textField.isEditable = false
        post()
    }
    
    //dont reset if the user doesnt have continued times.
    func noreset(){
        backButton.isHidden = false
        if !isTimerOn {
            timer.isHidden = false
            isTimerOn = true
        }
        timer.textColor = UIColor(hex: 0x17DF82)
        extraCounter = extraCounter + addTime
        post()
        extraTime = true
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
        addMin.isHidden = true
        extraCounter = extraCounter + addTime
        extraTime = true
        updateCounter()
        iTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        setupTimerVisibility()
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
            downTimeResetter = 0;
           
        }
        let wordCount = self.wordCount(str: textView.text!)
        liveWordCount.text = String(wordCount)
        topProgressChange(progress: Double(wordCount)/Double(100))
        
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
    }
    
    func checkDownTime(){
        downTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDownTime), userInfo: nil, repeats: true)
    }
    
    func updateDownTime(){
        downTimeResetter += 1;
        if downTimeResetter > 5{
            downTime += 1;
        }
    }
    
    @IBAction func showHideTimer(_ sender: UIButton) {
        isTimerOn = !isTimerOn
        if isTimerOn{
            timer.isHidden = false
            liveWordCount.isHidden = true
        }else{
            timer.isHidden = true
            liveWordCount.isHidden = false
        }
        
    }
    
    func updateWeekly(update:Bool){
        //updating a entry
        //im a god
        if update {
            let num = weeklyChallenges.current + greaterThanZero()
            ref?.child("users").child(String(describing: uid )).updateChildValues(["weeklywords": num])
 
        } else {
            let num = weeklyChallenges.current + loadedWordCount
            ref?.child("users").child(String(describing: uid )).updateChildValues(["weeklywords": num])

        }
    }
    
    //META DATA
    
    func findHash() -> [String:Bool]{
        var hashtags = [String:Bool]()
        var str = textField.text!
        let regex = try? NSRegularExpression(pattern: "(#[A-Za-z0-9]*)", options: [])

        let matches = regex?.matches(in: str, options:[], range:NSMakeRange(0, (str.characters.count)))
        for match in matches! {
            print("match = \(match.range)")
            hashtags[NSString(string: str).substring(with: NSRange(location:match.range.location + 1, length:match.range.length - 1))] = true
        }
        print(hashtags)
        return hashtags
    }
    
    func topProgressChange(progress:Double){
        //set the progress bar to be at the bottom of the parent view with width of 8
        //take parameters of parent views to make up for no layout
        
        let progressSize = (topProgress.superview?.frame.width)! * CGFloat(progress)
        
        if progress < 1 {
            topProgress.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: progressSize, height: 5))
        } else {
            topProgress.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: (topProgress.superview?.frame.width)!, height: 5))
        }
        
    }
    

}
