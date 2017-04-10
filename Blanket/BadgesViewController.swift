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
    //array of badges
    var items = [myBadges.badgeForADay,
                 myBadges.badgeFor3Days,
                 myBadges.badgeFor10Days,
                 myBadges.badgeFor20Days,
                 myBadges.badgeFor50Days,
                 myBadges.badgeFor100Days,
                 myBadges.badgeFor200Words,
                 myBadges.badgeFor500Words,
                 myBadges.badgeFor1000Words,
                 myBadges.badgeFor2000Words,
                 myBadges.badgeFor5000Words,
                 myBadges.badgeFor10000Words,
                 myBadges.badgeFor25000Words]
    
    //array of badge titles
    var itemTitles = ["First Day",
                     "Third Times The Charm",
                     "Double Digits",
                     "Long Run",
                     "100 Days",
                     "Title",
                     "Title",
                     "Title",
                     "Title",
                     "Title"
        ]
    
    //array of badge messages
    var itemMessages=["Congratulations on your first entry. This is the beginning of a long challenging journey, but you have the determination to travel it.",
                      "Three Days! You already passed all the people who quit on the first day. Pat yourself on the back for commiting to this challenge",
                      "message",
                      "message",
                      "message",
                      "message",
                      "message",
                      "message",
                      "message",
                      "message"]
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionCellView
        let badge = items[indexPath.row]
        if badge{
            cell.BadgeLabel.text = " "
            cell.backgroundColor = UIColor.green
        }else{
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.BadgeLabel.text = "?"
        cell.backgroundColor = UIColor.gray // make cell more visible in our example project
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
        if(items[indexPath.row]){
        showImageDialog(item: indexPath.row)
        }
    }
    
    //popup when a user presses on a badge they have completed
    func showImageDialog(animated: Bool = true, item:Int) {
        
        // Prepare the popup assets
        let title = itemTitles[item]
        let message = itemMessages[item]
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
