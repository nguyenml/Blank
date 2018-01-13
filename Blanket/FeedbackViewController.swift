//
//  FeedbackViewController.swift
//  Pods
//
//  Created by Marvin Nguyen on 12/31/17.
//
//

import Foundation
import UIKit
import MessageUI
import Firebase

class FeedbackViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UIButton!
    @IBOutlet weak var feedbackText: UITextView!

    @IBOutlet weak var emailText: UITextField!
    var ref:FIRDatabaseReference?
    
    var keyShift = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackText.delegate = self
        emailText.delegate = self
        ref = FIRDatabase.database().reference()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendFeedbacl(_ sender: UIButton) {
         let data = ["info": feedbackText.text!]
         addToFB(withData: data )
         self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    
    func addToFB(withData data: [String: String]){
        var mdata = data
        mdata["email"] = String(describing: emailText.text)
        ref?.child("Feedback").childByAutoId().setValue(mdata)
    }
    
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
