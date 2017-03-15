//
//  LogsViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/11/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var entries : [Entry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let entry = entries[indexPath.row]
        
        let dateform = DateFormatter()
        dateform.dateFormat = "MMM dd, yyyy"
        
        cell.textLabel?.text = dateform.string(from: entry.date as! Date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("test")
        let entry = entries[indexPath.row]

        self.performSegue(withIdentifier: "segueToEntry", sender: entry);
        
        
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToEntry" {
            guard let object = sender as? Entry else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    @IBAction func unwindToLogs(segue: UIStoryboardSegue) {}
}
