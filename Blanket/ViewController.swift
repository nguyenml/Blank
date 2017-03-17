//
//  ViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/8/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = "Let's get Started"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(UserDefaults.lastAccessDate as Any)
        if Calendar.current.isDateInToday(UserDefaults.lastAccessDate as Any as! Date) {
            entryButton.isHidden = true
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}


}

