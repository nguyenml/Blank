//
//  IndividualEntryViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/11/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class IndividualEntryViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var entry:Packet!

    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var wordCount: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry.hasMark(){
            markLabel.text = entry.mark
        }
        if entry.hasTopic(){
            markLabel.text = entry.topic
        }
        textView.isEditable = false;
        textView.font = UIFont(name: "OpenSans-Regular", size: 17)
        textView.text = entry.text
        wordCount.text = entry.wordCount
        timeLabel.text = String(Int(entry.totalTime)!/60)
        dateLabel.text = seperateDate()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func seperateDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: (entry.date))
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "unwindToLogs", sender: self)
    }

    @IBAction func unwindToEntry(segue: UIStoryboardSegue) {}
    

}
