//
//  GoalsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/13/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import PopupDialog

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
        initGoalButton.isHidden = true;
        initGoalButton.isUserInteractionEnabled = false;
        setGoal()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGoal(){
        if hasGoal{
            goalLabel.text = String(goalNumber)
        }
        else{
            initGoalButton.isHidden = false
            initGoalButton.isUserInteractionEnabled = true;
        }
    }
    /*!
     Displays a custom view controller instead of the default view.
     Buttons can be still added, if needed
     */
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        //CHANGE NAME
        let goalVC = NewGoalViewController(nibName: "RatingViewController", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: goalVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = DefaultButton(title: "Done", height: 60) {
        }
        
        // Add buttons to dialog
        //popup.addButtons([buttonOne])
        
        goalNumber = goalVC.goalTarget
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }

    @IBAction func addGoal(_ sender: Any) {
        showCustomDialog()
        if goalNumber > 0{
            hasGoal = true
            setGoal()
        }
    }
}
