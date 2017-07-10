//
//  BadgesViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

class BadgesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            cell.BadgeLabel.text = String(myBadges.badges[indexPath.row].number)
            cell.BadgeLabel.adjustsFontSizeToFitWidth = true;
            cell.BadgeLabel.minimumScaleFactor = 0.5
            cell.BadgeImage.image = badge.image as UIImage?
        }else{
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.BadgeLabel.text = "?"
        cell.backgroundColor = UIColor.gray// make cell more visible in our example project
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
        print("You selected cell #\(indexPath.item)!")
        if(myBadges.badges[indexPath.row].earned){
        showImageDialog(item: indexPath.row)
        }
    }
    
    //popup when a user presses on a badge they have completed
    func showImageDialog(animated: Bool = true, item:Int) {
        
        // Prepare the popup assets
        let title = myBadges.badges[item].name
        let message = myBadges.badges[item].message
        let image = UIImage(named: "pexels-photo-103290")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)
        
        // Create third button
        let buttonClose = DefaultButton(title: "Close") {
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonClose])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }

}
