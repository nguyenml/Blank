//
//  GoalsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/13/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController {
    @IBOutlet weak var progressBar: UIProgressView!

    @IBOutlet weak var initGoalButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var mainGoalLabel: UILabel!
    
    var hasGoal = false;
    var goalNumber = 0;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGoal(){
        if hasGoal{
            goalLabel.text = goalNumber
        }
        else{
            
        }
        
    }
    
    @IBAction func initGoal(_ sender: UIButton) {
        
    }

}
