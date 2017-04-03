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
        getData()
        print(stats)
        iTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        backButton.isHidden = true

        // Do any advarional setup after loadingvare view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func updateCounter() {
        //you code, this is an example
        if counter < 180{
        counter = counter + 1;
        }
        timer.text = String(counter)
        if counter >= 180{
            iTimer.invalidate()
            reset()
        }
    }
    
    func updateStats(){
        let userStats = ref?.child("users").child(uid).child("Stats")
        
        let current = stats["currentStreak"]! + 1
        let longest = stats["longestStreak"]!
        let total = stats["totalWordcount"]! + wordCount(str: textField.text!)
        
        userStats?.updateChildValues(["currentStreak":current])
        if current>longest{
            userStats?.updateChildValues(["longestStreak":current])
        }
        
        userStats?.updateChildValues(["totalWordcount": total])
        
        post()
        
       // (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(wordCount(str: textField.text!))
        mdata[Constants.Entry.date] = dateToString()
        mdata[Constants.Entry.uid] = uid
        ref?.child("Entry").childByAutoId().setValue(mdata)
        
    }
    
    func dateToString() -> String{
        let dateform = DateFormatter()
        dateform.dateFormat = "MMM dd, yyyy"
        
        return dateform.string(from: NSDate() as Date)
    }
    
    func post(){
        let text = textField.text
        let data = [Constants.Entry.text: text]
        addToFB(withData: data as! [String : String])
        
    }
    
    func reset(){
        backButton.isHidden = false
        timer.isHidden = false
        textField.isEditable = false
        textField.isUserInteractionEnabled = false
        updateStats()
        UserDefaults.lastAccessDate = Date()
        
        
    }
    
    func wordCount(str:String) -> Int16{
        
        let wordList =  str.components(separatedBy: NSCharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{$0 != ""}
        
        return Int16(wordList.count)
    }
    
    func SpecificWordCount(str:String, word:String) ->Int {
        let words = str.components(separatedBy: " "); var count = 0
        for thing in words {
            if thing == word {
                count += 1
            }
        }
        return count
    }
    
    func getData(){
        ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            print(self.stats)
        })
        
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
