//
//  IntroViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 11/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class IntroViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var reason: UITextView!
    
    var ref:FIRDatabaseReference?
    
    override func  viewDidLoad() {
        ref = FIRDatabase.database().reference()
        ref = ref?.child("users").child(String(describing: FIRAuth.auth()!.currentUser!.uid)).child("Statement")
        reason.font = UIFont(name: "OpenSans-Regular", size:17)
        reason.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func updateTextView(notification:Notification){
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to:view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            reason.contentInset = UIEdgeInsets.zero
        }else{
            reason.contentInset = UIEdgeInsets(top:0,left:0,bottom:keyboardEndFrame.height - 100, right:0)
            reason.scrollIndicatorInsets = reason.contentInset
        }
        reason.scrollRangeToVisible(reason.selectedRange)
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
        ref?.updateChildValues(["WEB":reason.text!])
    }
}
