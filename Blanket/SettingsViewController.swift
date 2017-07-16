//
//  SettingsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/15/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
   
    }

    @IBAction func signOut(_ sender: Any) {
        //let vc : AnyObject! = self.storyboard.instantiateViewControllerWithIdentifier("SIgnInViewController")
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            safeReset()
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    
    //resets all the local structs and classes that held the users local data
    func safeReset(){
        Stats.avgWordcount = 0
        Stats.currentStreak = 0
        Stats.daysActive = 0
        Stats.longestStreak = 0
        Stats.totalEntries = 0
        Stats.totalWordcount = 0
        
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }



}
