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

    @IBOutlet weak var addMin: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    var iTimer = Timer();
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    var lwc = 0
    
    //sent by previous view
    var loadedString:String!
    var markKey:String!
    var markName:String!
    var loadedWC:Int16!
    //-----------------------
    
    
    var loadedWordCount = 0
    var extraTime = false
    var currentString:String = ""
    
    var stats:[String:Int] = [:]
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref  = FIRDatabase.database().reference()
        entryRef = ref?.child("Entry").childByAutoId()
        self.textField.delegate = self
        //change this timer
        addMin.isHidden = true
        backButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InputViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        // Do any advarional setup after loadingvare view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timeSituations()
    }
    
    func timeSituations(){
        //4 possible outlooks
        //user is below 5 minutes and goes to marks, when he comes back it should restart and nothing else happens
        if (counter < 300){
            iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            setupDataOnReturn()
        }
        //path 2 - the user just finished and goes to mark, the timer should come back invalidated and the entry should already be posted/updated. still need to update the mark though so 
        if(counter == 300){
            setupDataOnReturn()
            post()
            
        }
        //path 3 - the user has finished up this writing piece, the timer should be above 300 and less than 360. Do not post, but keep the timer going
        if (counter < 360 && counter > 300){
            iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            setupDataOnReturn()
        }
        //path 4 - the user has finished up writing and finished his extra minute as well
        if (counter == 360){
            setupDataOnReturn()
            post()
        }
    }
    
    func setupDataOnReturn(){
        if loadedString == nil{
            return
        }
        else{
            textField.text = loadedString + currentString
        }
        loadedWordCount = Int(loadedWC)
    }
    
    //return to main view
    @IBAction func goBack(_ sender: UIButton) {
        if extraTime{
            reset()
        }
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    //Sets a timer up for 3 mins and shows user how long they spent
    func updateCounter() {
        if extraTime{
            if counter < 360{
                counter = counter + 1;
            }
            timer.text = String(counter)
            if counter >= 360{
                reset()
            }
            
        }
        else{
        if counter < 300{
            counter = counter + 1;
        }
        timer.text = String(counter)
        if counter >= 300{
            addMin.isHidden = false
            // at 3 mins update info and reset timer for next use
            lwc = greaterThanZero()
            reset()
        }
        }
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
                if current>longest{
                    longest = current
                }
                stats["currentStreak"] = current as Int
                stats["longestStreak"] = longest as Int
                stats["totalWordcount"] = total as Int
                stats["totalEntries"] = entries as Int
                stats["avgWordcount"] = total/entries as Int
                
                
                // Set value and report transaction success
                currentData.value = stats
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                //error
                print(error.localizedDescription)
            }
        }
        if !extraTime{
            if Goals.hasGoal{
                Goals.current += 1
                 ref?.child("Goals").child(Goals.goalId).child("currentGoal").setValue(Goals.current)
            }
        }
        // this will submit the entry to firebase
        // at this point the information has left the client side
        post()
    }
    
    func smallUpdate(){
        let userStats = ref?.child("users").child(uid).child("Stats")
        userStats?.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var stats = currentData.value as? [String : Int]{
                let entries:Int = stats["totalEntries"]!
                let total = Int(stats["totalWordcount"]! - self.lwc + self.greaterThanZero())
                stats["avgWordcount"] = total/entries as Int
                currentData.value = stats
                return FIRTransactionResult.success(withValue: currentData)
            }
        return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                //error
            }
        }
        post()
    }
    
    
    //submit struct to FB
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(greaterThanZero())
        mdata[Constants.Entry.date] = dateToString()
        mdata[Constants.Entry.uid] = uid
        mdata[Constants.Entry.emotion] = imFeeling
        mdata[Constants.Entry.timestamp] = getTimeStamp()
        let key:String = (entryRef?.key)!
        if markKey != nil{
            mdata[Constants.Entry.mark] = markName
            ref?.child("Marks").child(markKey).child("entries").setValue([key:key])
            mdata[Constants.Entry.textStart] = concatString(str: currentString)
        }
        else{
            mdata[Constants.Entry.textStart] = textField.text
        }
        entryRef?.setValue(mdata)
        updateLastAccess(date: dateToString())
    }
    
    func concatString(str:String) -> String{
        if textField.text.range(of:loadedString) != nil{
            let copyText = textField.text
            let newString = copyText?.replacingOccurrences(of: loadedString, with: "")
            return newString!
        }
        let length = currentString.characters.count
        if length < 35 {
            let startIndex = str.index(str.startIndex, offsetBy: length - 1)
            return(str.substring(to: startIndex))
        }
        let startIndex = str.index(str.startIndex, offsetBy: 35)
        return(str.substring(to: startIndex))
    }
    
    //make sure wordCount > 0
    func greaterThanZero() -> Int{
        if(Int(wordCount(str: textField.text!)) - loadedWordCount) < 0{
            return 0
        }
        print(wordCount(str: textField.text!))
        print(loadedWordCount)
        return (Int(wordCount(str: textField.text!)) - loadedWordCount)
    }
    
    func updateLastAccess(date: String){
        ref?.child("users").child(String(describing: uid )).updateChildValues(["LastAccess": date])
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
    
    //puts info into a struct
    func post(){
        let text = textField.text
        let data = [Constants.Entry.text: text]
        addToFB(withData: data as! [String : String])
    }
    
    //resets timer, buttons, and access
    func reset(){
        iTimer.invalidate()
        backButton.isHidden = false
        textField.isEditable = false
        textField.isUserInteractionEnabled = false
        if extraTime{
            smallUpdate()
            extraTime = false
        }
        else{
            updateStats()
        }
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
        currentString = textField.text
        iTimer.invalidate()
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
        addMin.isHidden = true
        addMin.isUserInteractionEnabled = false
        textField.isEditable = true
        textField.isUserInteractionEnabled = true
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

}
