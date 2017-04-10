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

    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    var iTimer = Timer();
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    
    
    var stats:[String:Int] = [:]
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref  = FIRDatabase.database().reference()
        
        //change this timer
        iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        backButton.isHidden = true
        // Do any advarional setup after loadingvare view.
    }
    
    //return to main view
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    //Sets a timer up for 3 mins and shows user how long they spent
    func updateCounter() {
        //you code, this is an example
        if counter < 180{
        counter = counter + 1;
        }
        timer.text = String(counter)
        if counter >= 180{
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
        // this will submit the entry to firebase
        // at this point the information has left the client side
        post()
    }
    
    
    //submit struct to FB
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(wordCount(str: textField.text!))
        mdata[Constants.Entry.date] = dateToString()
        mdata[Constants.Entry.uid] = uid
        ref?.child("Entry").childByAutoId().setValue(mdata)
        
    }
    
    //converts date to a string to be but into the db
    func dateToString() -> String{
        let dateform = DateFormatter()
        dateform.dateFormat = "MMM dd, yyyy h:mm a"
        
        return dateform.string(from: NSDate() as Date)
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
        timer.isHidden = false
        textField.isEditable = false
        textField.isUserInteractionEnabled = false
        updateStats()
        UserDefaults.lastAccessDate = Date()
        
        
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

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
