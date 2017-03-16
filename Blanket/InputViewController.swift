//
//  InputViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet var backButton: UIButton!
    @IBOutlet var textField: UITextView!
    
    @IBOutlet var timer: UILabel!
    var counter = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        backButton.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goBack(_ sender: UIButton) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let entry = Entry(context: context)
        
        entry.text = textField.text!
        entry.date = NSDate()
        entry.word_count = wordCount(str: textField.text!)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func updateCounter() {
        //you code, this is an example
        if counter < 180{
        counter = counter + 1;
        }
        timer.text = String(counter)
        if counter >= 180{
            backButton.isHidden = false
            timer.isHidden = false
            textField.isEditable = false
            textField.isUserInteractionEnabled = false
        }
    }
    
    func wordCount(str:String) -> Int16{
        
        let wordList =  str.components(separatedBy: NSCharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{$0 != ""}
        
        return Int16(wordList.count)
    }
    
    func SpecificWordCount(str:String, word:String) ->Int {
        let words = str.components(separatedBy: " "); var count = 0
        for thing in words {
            if thing == word {
                count += 1
            }
        }
        return count
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
