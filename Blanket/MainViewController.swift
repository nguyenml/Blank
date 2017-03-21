//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var completedText: UILabel!
    @IBOutlet weak var entryBtn: UIButton!
    
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    let myDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        _ = UserDefaults.isFirstLaunch()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLabels()
        if Calendar.current.isDateInToday(UserDefaults.lastAccessDate as Any as! Date) {
            entryBtn.isHidden = true
            completedText.isHidden = false
        }
        resetStreak()
        
    }
    
    func setLabels(){
        textLabel.text = ("Day" + " " + String(myDefaults.integer(forKey: "streak")))
        completedText.text = "You already wrote today"
        completedText.isHidden = true
    }
    
    
    func setDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        dateLabel.text = (dateFormatter.string(from: NSDate() as Date))
    }
    
    func resetStreak(){
        let currentCalendar     = NSCalendar.current
        let start = currentCalendar.ordinality(of: .day, in: .era, for: UserDefaults.lastAccessDate as Any as! Date)
        let end = currentCalendar.ordinality(of: .day, in: .era, for: NSDate() as Date)
        let daysSinceWriting = end! - start!
        print(daysSinceWriting)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    
}

