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
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var wordCount: UILabel!
    
    //Recieve from views
    //----------------
    var key:String!
    var markName:String!
    var topicOrMark:Bool!
    //-----------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry.hasMark(){
            markLabel.text = entry.mark
            self.markButton.isHidden = true
        }
        if entry.hasTopic(){
            markLabel.text = entry.topic
            self.markButton.isHidden = true
        }
        textView.isEditable = false;
        textView.text = entry.text
        wordCount.text = entry.wordCount
        dateLabel.text = seperateDate()
        key = entry.key
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if markName != nil{
            if topicOrMark{
                entry.topic = markName
                markLabel.text = entry.topic
            }else{
                entry.mark = markName
                markLabel.text = entry.mark
            }
        }
        if entry.hasMark() || entry.hasTopic(){
            markButton.isHidden = true
        }
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
