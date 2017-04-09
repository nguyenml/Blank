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
        checkUser()
        currentDate = Date()
        getData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLabels()
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
        ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").observe(FIRDataEventType.value, with: {
            (snapshot) in
            self.stats = snapshot.value as? [String : Int] ?? [:]
            self.textLabel.text = ("Day" + " " + String(describing: self.stats["currentStreak"]!))
            
            Stats.avgWordcount = (self.stats["avgWordcount"]!)
            Stats.currentStreak = (self.stats["currentStreak"])!
            Stats.longestStreak = (self.stats["longestStreak"])!
            Stats.totalWordcount = (self.stats["totalWordcount"])!
            Stats.daysActive = (self.stats["daysActive"])!
            myBadges.checkBadge()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TEMP TEMP TEMP TEMP TEMP FIX
    //PLEASE FIX THIS CANNOT GO PRODUCTION
    //THIS LITERALY MAKES NO SENSE
    //THIS IS LITERALLY THE SHITTIEST CODE IN THE WHOLE LIBRARY
    // 4/09/17 3:49 a.m.
    
    func checkUser(){
        if FIRAuth.auth()?.currentUser != nil {
            let firebaseAuth = FIRAuth.auth()
            ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Stats").observe(FIRDataEventType.value, with: {
                (snapshot) in
                self.stats = snapshot.value as? [String : Int] ?? [:]
                if(self.stats["currentStreak"] == nil){
                    do {
                        try firebaseAuth?.signOut()
                        self.dismiss(animated: true, completion: nil)
                    } catch let signOutError as NSError {
                        print ("Error signing out: \(signOutError.localizedDescription)")
                    }
                }
            })
        }else {
        }
    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    
}

