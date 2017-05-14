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
import KYCircularProgress
import ChameleonFramework

class GoalsViewController: UIViewController {
    
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var percentProgress: UILabel!
    @IBOutlet weak var initGoalButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var CSgoalLabel: UILabel!
    @IBOutlet weak var circleProgress: KYCircularProgress!
    
    let uid = FIRAuth.auth()!.currentUser!.uid
    var descSwitch = true
    
    var ref:FIRDatabaseReference?

    var goalNumber = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        initGoalButton.isUserInteractionEnabled = false;
        initGoalButton.layer.cornerRadius = 5
        setUI()
        setGoal()
        ref = FIRDatabase.database().reference()
        CSgoalLabel.isHidden = true
        daysLabel.isHidden = true
        updateGoal()
        // Do any additional setup after loading the view.
    }
    func updateGoal(){
        if Goals.hasGoal{
            ref?.child("Goals").child(Goals.goalId).child("currentGoal").observe(FIRDataEventType.value, with: { (snapshot) -> Void in
                        Goals.current = snapshot.value as! Int
            })

        }
    }
    
    func setUI(){
        circleProgress.colors = [UIColor(rgba: 0xF5A623),UIColor(rgba: 0xF5A623),UIColor(rgba: 0xF5A623)]
        
        flag.image = flag.image!.withRenderingMode(.alwaysTemplate)
        flag.tintColor = UIColor.white
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
    
    @IBAction func desc(_ sender: UIButton) {
        descSwitch = !descSwitch
        if descSwitch{
            CSgoalLabel.isHidden = true
            daysLabel.isHidden = true
            percentProgress.isHidden = false
        }else{
            CSgoalLabel.isHidden = false
            daysLabel.isHidden = false
            percentProgress.isHidden = true
        }
    }
    
    func setGoal(){
        let progress = Double(Goals.current) / Double(Goals.endGoal)
        if Goals.hasGoal{
            let attrsA = [NSFontAttributeName: UIFont.systemFont(ofSize: 19)]
            let current = String(Goals.current)
            let attrText = NSMutableAttributedString(string:current)
            let end = "/ " + String(Goals.endGoal)
            attrText.append(NSAttributedString(string: end, attributes: attrsA))
            CSgoalLabel.attributedText = attrText
            initGoalButton.isUserInteractionEnabled = false;
            initGoalButton.backgroundColor = UIColor.flatGray
            circleProgress.progress = progress / Double(UInt8.max)
            percentProgress.text = String(Double(round(progress*100)/1)) + "%"
            print(progress)
        }
        else{
            initGoalButton.isUserInteractionEnabled = true;
            CSgoalLabel.isHidden = true;
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
