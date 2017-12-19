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
        fetchUser()
        setSlides()
        setText()
    }
    
    func fetchUser()-> String {
        let user = FIRAuth.auth()?.currentUser
        var name = ""
        //name = (user?.displayName?.capitalizingFirstLetter())!
        return name
    }
    
    func setSlides(){
        let name:String = "Hello " + fetchUser()
        let slide1 = name+", Welcome to Blankit"
        slides.append(slide1)
        let slide2 = "Blankit is an app that will help you develop a strong writing habit"
        slides.append(slide2)
        let slide3 = "To build this long lasting habit, we need to start by writing everyday."
        slides.append(slide3)
        let slide4 = "It's okay if you don't have any experience of writing on your own."
        slides.append(slide4)
        let slide5 = "A little bit everyday. Thats all it takes."
        slides.append(slide5)
        let slide6  = "It doesnt matter if it's just a couple sentences or a hundred paragraphs. It only matters that you write something."
        slides.append(slide6)
        let slide7 = "Everyday you are given a chance to complete an entry with a minimum time constraint."
        slides.append(slide7)
        let slide8 = "As you continue to write everday, the time constraint will gradually increase."
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
        ref?.child("Settings").child("userCount").observeSingleEvent(of: .value, with: { snapshot in
            var value = snapshot.value as! Int
            value = value + 1
            self.ref?.child("Settings").child("userCount").setValue(value)
        })
        
    }

}
