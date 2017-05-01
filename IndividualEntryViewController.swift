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

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var wordCount: UILabel!
    
    var key:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false;
        textView.text = entry.text
        wordCount.text = entry.wordCount
        dateLabel.text = seperateDate()
        key = entry.key
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
    
    
    @IBAction func markBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToMark", sender: key);
    }

    @IBAction func unwindToEntry(segue: UIStoryboardSegue) {}
    
    //Creates a segue to take the user to a specific entry
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToMark"{
            guard let object = sender as? String else { return }
            let dvc = segue.destination as! MarkOptionsViewController
            dvc.key = object
        }
        
    }

}
