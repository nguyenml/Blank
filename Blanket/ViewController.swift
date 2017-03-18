//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    
    @IBOutlet weak var completedText: UILabel!
    
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
        setLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(UserDefaults.lastAccessDate as Any)
        if Calendar.current.isDateInToday(UserDefaults.lastAccessDate as Any as! Date) {
            entryButton.isHidden = true
            completedText.isHidden = false
        }
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}


}

