//
//  BadgesViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase

class BadgesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = [myBadges.badgeForADay, myBadges.badgeFor3Days, myBadges.badgeFor200Words, myBadges.badgeFor200Words]
    
    
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
    
    @IBAction func backToStats(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToStats", sender: self)
    }
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }

}
