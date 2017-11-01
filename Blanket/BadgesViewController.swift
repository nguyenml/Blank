//
//  BadgesViewController.swift
//  Blanket
//  Trophy by Diego Cordero from the Noun Project
//  Trophy by Edward Boatman from the Noun Project
//  Medal by iconsphere from the Noun Project
//  Created by Marvin Nguyen on 3/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class BadgesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var popupImage: UIImageView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupMessage: UILabel!
    @IBOutlet weak var popupButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var popupView: UIView!
    
    var effect:UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effect = blurView.effect
        blurView.effect = nil
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myBadges.badges.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionCellView
        let badge = myBadges.badges[indexPath.row]
        if badge.earned{
            cell.BadgeImage.image = badge.image as UIImage?
        }else{
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.BadgeLabel.text = String(myBadges.badges[indexPath.row].number)
            cell.BadgeImage.image = UIImage(named: "grey_oval")// make cell more visible in our example project
        }
        
        return cell
    }
    
    //return to stats page
    @IBAction func backToStats(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        if(myBadges.badges[indexPath.row].earned){
        showImageDialog(item: indexPath.row)
        }
    }
    
    //popup when a user presses on a badge they have completed
    func showImageDialog(animated: Bool = true, item:Int) {
        
        // Prepare the popup assets
        let title = myBadges.badges[item].name
        let message = myBadges.badges[item].message
        let image = myBadges.badges[item].image
        
        // Create the dialog
         animateIn(image: image, title: title, message: message)
    }

    @IBAction func popupClose(_ sender: Any) {
        animateOut()
    }
    
    func animateIn(image:UIImage, title:String, message:String){
        self.view.addSubview(popupView)
        popupImage.image = image
        popupTitle.text = title
        popupMessage.text = message
        
        popupView.center = self.view.center
        
        popupView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
        
        dropShadow(color: .lightGray, offSet: CGSize(width: -1, height: 3), radius: 10, scale: true)
        
        UIView.animate(withDuration:0.4){
            self.blurView.effect = self.effect
            self.popupView.alpha = 1
            self.popupView.transform = CGAffineTransform.identity
            
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration:0.3, animations: {
            self.popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupView.alpha = 0
            
            self.blurView.effect = nil
        }) { (Bool) in
            self.popupView.removeFromSuperview()
        }
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.7, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        popupView.layer.masksToBounds = false
        popupView.layer.shadowColor = color.cgColor
        popupView.layer.shadowOpacity = opacity
        popupView.layer.shadowOffset = offSet
        popupView.layer.shadowRadius = radius
        
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).cgPath
        popupView.layer.shouldRasterize = true
        popupView.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        popupButton.layer.masksToBounds = false
        popupButton.layer.shadowColor = color.cgColor
        popupButton.layer.shadowOpacity = opacity
        popupButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupButton.layer.shadowRadius =  4
        
        popupButton.layer.shadowPath = UIBezierPath(rect: popupButton.bounds).cgPath
        popupButton.layer.shouldRasterize = true
        popupButton.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
