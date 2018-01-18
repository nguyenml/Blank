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
        setupText()
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
    
    func setupText(){
        //check null
        var text = ""
        //has tags
        if !entry.hashtags.isEmpty {
            var sentence = ""
            for hash in entry.hashtags{
                sentence += (hash + " ")
            }
            let tags = "\(sentence)\n"
            text = "\(sentence) \n"
            let attrs:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "OpenSans-Bold", size: 15)!]
            let attrsRegular:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "OpenSans-Regular", size: 17)!]
            let regularString = NSMutableAttributedString(string:entry.text, attributes:attrsRegular)
            let boldString = NSMutableAttributedString(string: tags, attributes:attrs)
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(boldString)
            mutableAttributedString.append(regularString)
            textView.attributedText = mutableAttributedString
        } else {
            //does not have tags, set to regular text
            textView.font = UIFont(name: "OpenSans-Regular", size: 17)
            textView.text = entry.text
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
       // performSegue(withIdentifier: "unwindToLogs", sender: self)
    }

    @IBAction func unwindToEntry(segue: UIStoryboardSegue) {}
    

}
