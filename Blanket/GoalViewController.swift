//
//  GoalViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 12/28/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class GoalViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var reason: UITextView!
    
    var ref:FIRDatabaseReference?
    
    override func  viewDidLoad() {
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Statement")
        reason.font = UIFont(name: "OpenSans-Regular", size:17)
        reason.delegate = self
    }
    
    func checkNotEmpty(){
        if (reason.text?.isEmpty)! {
            reason.text = " "
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    @IBAction func saveContinue(_ sender: UIButton) {
        ref?.updateChildValues(["GOAL":reason.text!])
    }
}

