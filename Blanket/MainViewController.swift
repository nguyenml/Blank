//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var completedText: UILabel!
    @IBOutlet weak var entryBtn: UIButton!
    
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    var ref:FIRDatabaseReference?
    
    var stats:[String:Int] = [:]
    
    @IBOutlet weak var dateLabel: UILabel!
    
    let myDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        currentDate = Date()
        getData()
        setLabels()
        resetStreak()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    func setLabels(){
        completedText.text = "You already wrote today"
        completedText.isHidden = true
    }
    
    
    func setDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        dateLabel.text = (dateFormatter.string(from: NSDate() as Date))
    }
    
    func getData(){
        print("\n\n\n")
        print("data")
        ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            print("\n\n\n")
            print(self.stats["currentStreak"]!)
            self.textLabel.text = ("Day" + " " + String(describing: self.stats["currentStreak"]!))
            print("\n\n\n")
        })

    }
    
    func resetStreak(){
        let currentCalendar     = NSCalendar.current
        let start = currentCalendar.ordinality(of: .day, in: .era, for: UserDefaults.lastAccessDate as Any as! Date)
        let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date)
        let daysSinceWriting = end! - start!
        if daysSinceWriting > 1{
            ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").updateChildValues(["currentStreak":0])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    
}

