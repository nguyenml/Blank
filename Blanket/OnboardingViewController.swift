//
//  OnboardingViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/25/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class OnboardingViewController: UIViewController{
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var textDisplay: UITextView!
    var textSlide = 0

    var slides = [String]()
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUsers()
        setSlides()
        setText()
    }
    
    func setSlides(){
        let slide1 = "Hello ,Welcome to Blankit"
        slides.append(slide1)
        let slide2 = "Blankit is an app that will help you develop a strong writing habit."
        slides.append(slide2)
        let slide3 = "To build this long lasting habit, we need to start by writing everyday."
        slides.append(slide3)
        let slide4 = "It's okay if you don't have any experience of writing on your own."
        slides.append(slide4)
        let slide5 = "It just takes a little bit everyday."
        slides.append(slide5)
        let slide6  = "It doesnt matter if it's a couple sentences or a couple pages. It only matters that you write."
        slides.append(slide6)
        let slide7 = "Everyday you are given a chance to complete an entry."
        slides.append(slide7)
        let slide8 = "As you continue to write, your entry length will gradually increase."
        slides.append(slide8)
        let slide9 = "Let's get started."
        slides.append(slide9)
        
    }
    
    func setText(){
        textDisplay.text = slides[textSlide]
        textSlide += 1
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if textSlide < 9{
            setText()
            if textSlide == 9 {
                nextButton.isHidden = true
                startButton.isHidden = false
            }
        }
        
    }
    
    func updateUsers(){
        ref = FIRDatabase.database().reference()
        ref?.child("Settings").observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            var num = value?["userCount"] as? Int
            num = num! + 1
            self.ref?.child("Settings").child("userCount").setValue(num)
            print("TESTING SEETTS")
        })
        
    }

}
