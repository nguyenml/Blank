//
//  OnboardingViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/25/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var onboarding: OnboardingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onboarding.dataSource = self
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColor1 = UIColor(hex:0x86BAA1)
        let backgroundColor2 = UIColor(hex:0x247BA0)
        let backgroundColor3 = UIColor(hex:0x498467)
        
        let titleFont = UIFont(name:"Abel", size:32)
        let descriptionFont = UIFont(name: "OpenSans-Regular", size: 17)
        
        return [
            (imageName: "brush", title: "Straight Forward", description: "Every day, when you open the app, you are given till the end of the day to complete an entry.", iconName: "", color: backgroundColor1, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
            (imageName: "clock_image_white", title: "5 Minutes", description: "5 minutes a day is all you need to write. Just write about whatever comes to mind. If you feel like you need more time, just double tap to continue.", iconName: "", color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                (imageName: "calendar", title: "Keep track of your progress", description: "Blankit's simple design helps you visualize how much and how often you write. Just looking at your progress is a reward itself.", iconName: "", color: backgroundColor3, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                
                ] [index] as! OnboardingItemInfo
        
    }

}
