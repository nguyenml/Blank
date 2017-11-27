//
//  IntroViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 11/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class IntroViewController: UIViewController {
    
    //users goals for writing
    @IBOutlet weak var reasons2: UITextField!

    //user reasons for writing everyday
    @IBOutlet weak var reasons1: UITextField!
    
    var ref:FIRDatabaseReference?
    
    override func  viewDidLoad() {
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Statement")
    }
    
    func checkNotEmpty(){
        if (reasons1.text?.isEmpty)! {
            reasons1.text = " "
        }
        
        if (reasons2.text?.isEmpty)! {
            reasons2.text = " "
        }
    }
    
    
    @IBAction func saveContinue(_ sender: UIButton) {
        ref?.updateChildValues(["WEB":reasons1.text!])
        ref?.updateChildValues(["GOAL":reasons2.text!])
    }
}
