//
//  RatingViewController.swift
//  PopupDialog
//
//  Created by Martin Wildfeuer on 11.07.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class NewGoalViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    
    var goalTarget = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextField.keyboardType = UIKeyboardType.decimalPad

        commentTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func endEditing() {
        view.endEditing(true)
    }
}

extension NewGoalViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        goalTarget = Int(commentTextField.text!)!
        return true
    }
}
