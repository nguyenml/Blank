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
    var entry : [String:String] = [:]

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var wordCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false;
        textView.text = entry[Constants.Entry.text]
        wordCount.text = entry[Constants.Entry.wordCount]
        dateLabel.text = seperateDate()
    }
    
    func seperateDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: (entry[Constants.Entry.date]!))
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "unwindToLogs", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
