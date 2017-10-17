//
//  PickLevelViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 10/6/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class PickLevelViewController: UIViewController {


    @IBOutlet weak var boxOutline3: UIView!
    @IBOutlet weak var boxOutline1: UIView!
    @IBOutlet weak var boxOutline2: UIView!
    @IBOutlet weak var lvl3Button: UIButton!
    @IBOutlet weak var lvl2Button: UIButton!
    @IBOutlet weak var lvl1Button: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet var descriptionText: UITextView!
    
    var ref:FIRDatabaseReference?
    var lvl = 0
    
    let desc1 = "If you have never tried writing before other than highschool english and that one college class you were forced to take, this is a good start for you. It starts off easy and gradually increases in duration as you get used to the feeling of writing."
    
    let desc2 = "For most people this is a good duration to begin with. 3 minutes gives you enough time to write down most of your thoughts without giving you that nasty \"forced writing\" feeling. The duration of your writing will slowly increase without you noticing "
    
    let desc3 = "If you blog regularely or have habitually written in the past, this is a great choice. Starting at the 5, this set is a bit more challenging. Time will be increased slowly, but will add up very quickly before you even notice it.   "
    
    override func  viewDidLoad() {
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("EntryTime")
        lvl2Button.sendActions(for: .touchUpInside)
    }
    
    @IBAction func btn3Pressed(_ sender: UIButton) {
        descriptionText.text = desc3
        resetOutlines()
        boxOutline3.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        lvl = 3
    }
    
    @IBAction func btn2Pressed(_ sender: UIButton) {
        descriptionText.text = desc2
        resetOutlines()
        boxOutline2.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        lvl = 2
    }
    
    @IBAction func btn1Pressed(_ sender: UIButton) {
        descriptionText.text = desc1
        resetOutlines()
        boxOutline1.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        lvl = 1
    }
    
    func resetOutlines(){

        boxOutline1.layer.borderColor = UIColor.clear.cgColor
        boxOutline2.layer.borderColor = UIColor.clear.cgColor
        boxOutline3.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setupWithLvl(){
        switch lvl {
        case 1:
            EntryTime.level = 1
            EntryTime.regularTime = 60
            ref?.updateChildValues(["level":1])
            ref?.updateChildValues(["regularTime":60])
            FIRAnalytics.logEvent(withName: "UserEntryTime", parameters: ["lvl":1 as NSObject,"regularTime":60 as NSObject])
            break
        case 2:
            EntryTime.level = 2
            EntryTime.regularTime = 180
            ref?.updateChildValues(["level":2])
            ref?.updateChildValues(["regularTime":180])
            FIRAnalytics.logEvent(withName: "UserEntryTime", parameters: ["lvl":2 as NSObject,"regularTime":180 as NSObject ])
            break
        case 3:
            EntryTime.level = 3
            EntryTime.regularTime = 300
            ref?.updateChildValues(["level":3])
            ref?.updateChildValues(["regularTime":300])
            FIRAnalytics.logEvent(withName: "UserEntryTime", parameters: ["lvl":3 as NSObject,"regularTime":300 as NSObject])
            break
        default:
            EntryTime.level = 2
            EntryTime.regularTime = 180
            ref?.updateChildValues(["level":2])
            ref?.updateChildValues(["regularTime":180])
            FIRAnalytics.logEvent(withName: "UserEntryTime", parameters: ["lvl":2 as NSObject,"regularTime":180 as NSObject])
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        setupWithLvl()
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }
    
}
