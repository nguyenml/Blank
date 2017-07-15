//
//  SettingsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/15/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

   
    }

    @IBAction func signOut(_ sender: Any) {
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }



}
