//
//  TimeViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 5/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {

    @IBOutlet weak var hide: UITextField!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var selectedDate = "12:00 pm"

    override func viewDidLoad() {
        super.viewDidLoad()
        hide.isUserInteractionEnabled = false
        hide.isHidden = true
        timePicker.datePickerMode = UIDatePickerMode.time
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        selectedDate = dateFormatter.string(from: timePicker.date)
    }

}
