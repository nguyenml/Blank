//
//  InputViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class InputViewController: UIViewController {
    
    var ref:FIRDatabaseReference?
    var entryRef:FIRDatabaseReference?

    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    var iTimer = Timer();
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    
    //sent by previous view
    var loadedString:String!
    var markKey:String!
    //-----------------------
    
    var loadedWordCount = 0
    
    var stats:[String:Int] = [:]
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref  = FIRDatabase.database().reference()
        entryRef = ref?.child("Entry").childByAutoId()
        
        //change this timer
        iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        backButton.isHidden = true
        // Do any advarional setup after loadingvare view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.text = loadedString
        loadedWordCount = Int(wordCount(str: textField.text!))
    }
    
    //return to main view
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    //Sets a timer up for 3 mins and shows user how long they spent
    func updateCounter() {
        //you code, this is an example
        if counter < 300{
        counter = counter + 1;
        }
        timer.text = String(counter)
        if counter >= 300{
            iTimer.invalidate()
            // at 3 mins update info and reset timer for next use
            reset()
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
                let total = Int(stats["totalWordcount"]! + self.wordCount(str: self.textField.text!))
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
        if Goals.hasGoal{
            ref?.child("Goals").child(Goals.goalId).child("currentGoal").setValue(Goals.current + 1)
        }
        // this will submit the entry to firebase
        // at this point the information has left the client side
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
            mdata[Constants.Entry.mark] = markKey
            ref?.child("Marks").child(markKey).child("entries").setValue([key:key])
        }
        entryRef?.setValue(mdata)
        updateLastAccess(date: dateToString())
    }
    
    //make sure wordCount > 0
    func greaterThanZero() -> Int{
        if(Int(wordCount(str: textField.text!)) - loadedWordCount) < 0{
            return 0
        }
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
        backButton.isHidden = false
        timer.isHidden = true
        textField.isEditable = false
        textField.isUserInteractionEnabled = false
        updateStats()
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
        let key:String = (entryRef?.key)!
        performSegue(withIdentifier: "segueToContinue", sender: key)
    }
    
    @IBAction func unwindToInput(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToContinue"{
            guard let object = sender as? String else {return}
            let dvc = segue.destination as! ContinueViewController
            dvc.key = object
        }
        
    }

}
