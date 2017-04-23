//
//  GoalsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 4/13/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import PopupDialog
import Firebase
import CircleProgressView
import ChameleonFramework

class GoalsViewController: UIViewController {
    
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var initGoalButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var mainGoalLabel: UILabel!
    @IBOutlet weak var CSgoalLabel: UILabel!
    
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    var ref:FIRDatabaseReference?

    var goalNumber = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: view.frame, colors: [.flatSkyBlue,.flatMint])
        initGoalButton.isHidden = true;
        initGoalButton.isUserInteractionEnabled = false;
        initGoalButton.layer.cornerRadius = 5
        setGoal()
        ref = FIRDatabase.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToFB(withData data: [String: AnyObject]){
        var mdata = data
        mdata[Constants.Goal.currentGoal] = 0 as AnyObject
        mdata[Constants.Goal.uid] = uid as AnyObject
        mdata[Constants.Goal.inProgress] = true as AnyObject
        ref?.child("Goals").childByAutoId().setValue(mdata)
        Goals.current = 1
        Goals.endGoal = goalNumber
    }
    
    func post(){
        let goal = goalNumber
        let data = [Constants.Goal.endGoal: goal]
        addToFB(withData: data as [String : AnyObject] )
    }
    
    func setGoal(){
        if Goals.hasGoal{
            CSgoalLabel.text = String(Goals.current)
            goalLabel.text = "/" + String(goalNumber)
            initGoalButton.isHidden = true
            initGoalButton.isUserInteractionEnabled = false;
            //testing purposes delete b4 prod
            let fractionalProgress = 1 / Float(Goals.endGoal)
            //let fractionalProgress = Float(Goals.current) / Float(Goals.endGoal)
            print(Goals.current)
            print(Goals.endGoal)
            print(fractionalProgress)
            progressView.setProgress(Double(fractionalProgress), animated: true)
        }
        else{
            initGoalButton.isHidden = false
            initGoalButton.isUserInteractionEnabled = true;
            CSgoalLabel.isHidden = true;
            goalLabel.isHidden = true;
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
            self.goalNumber = Int(goalVC.commentTextField.text!)!
            if self.goalNumber > 0{
                Goals.hasGoal = true
                self.setGoal()
                self.post()
            }
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }

    @IBAction func addGoal(_ sender: Any) {
        showCustomDialog()
    }
}
