//
//  InputViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InputViewController: UIViewController {
    
    var ref:FIRDatabaseReference?

    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    var iTimer = Timer();
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref  = FIRDatabase.database().reference()
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
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let myDefaults = UserDefaults.standard
        
        var streak = myDefaults.integer(forKey: "streak")
        var total = myDefaults.integer(forKey: "total")
        var high = myDefaults.integer(forKey: "high")
        streak += 1
        total += 1
        if streak > high{
            high = streak
        }
        
        //let entry = Entry(context:context);
        
        //entry.text = textField.text!
        //entry.date = NSDate()
        //entry.word_count = wordCount(str: textField.text!)
        
        myDefaults.set(streak, forKey: "streak")
        myDefaults.set(total, forKey: "total")
        myDefaults.set(high, forKey: "high")
        
        post()
        
       // (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata[Constants.Entry.wordCount] = String(wordCount(str: textField.text!))
        mdata[Constants.Entry.date] = dateToString()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
