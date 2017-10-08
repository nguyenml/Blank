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
            (imageName: "brush", title: "Write Every Day", description: "The mission is simple. Everyday you must write something for however long duration. If you miss a day, your progress will be reset.", iconName: "", color: backgroundColor1, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
            (imageName: "clock_image_white", title: "A Base Time", description: "You can pick a base time depending on your experience. As long as you meet the time, you get a completion for that day. As your streak increases, so does your base time.", iconName: "", color: backgroundColor2, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                (imageName: "calendar", title: "Track your progress", description: "It is easy to visualize your progress with stats and a calendar view. Watching yourself grow is one of the best motivators to keep writing.", iconName: "", color: backgroundColor3, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                
                ] [index] as! OnboardingItemInfo
        
    }

}
