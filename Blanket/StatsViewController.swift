//
//  StatsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/19/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController{

    @IBOutlet weak var CurrentStreak: UILabel!
    @IBOutlet weak var LongestStreak: UILabel!
    @IBOutlet weak var DaysActive: UILabel!
    @IBOutlet weak var AverageWordCount: UILabel!
    @IBOutlet weak var TotalWordCount: UILabel!
    
    var entries : [Entry] = []
    
    let myDefaults = UserDefaults.standard
    var total : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setLabels(){
        CurrentStreak.text = String(myDefaults.integer(forKey: "streak"))
        LongestStreak.text = String(myDefaults.integer(forKey: "high"))
        AverageWordCount.text = String(averageWordCount())
        TotalWordCount.text = String(total)
        //DaysActive.text = findActiveDates()
    }
    
    func findActiveDates(){
        let calendar = NSCalendar.current
        let today = calendar.startOfDay(for: NSDate() as Date)
        let startDate = myDefaults.object(forKey: "lastAccessDate") as! Date
        //let components = calendar.dateComponents([.day], fromDate: startDate, toDate: today)
        
       // return components.day
    }
    
    func averageWordCount() -> Int{

        for entry in entries{
            print(entry.word_count)
            total += Int(entry.word_count)
        }
        return total/entries.count
    }
    
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            entries = try context.fetch(Entry.fetchRequest())
            
        }
        catch{
            print("failed")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    
}
