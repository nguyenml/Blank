//
//  ELViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 3/11/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class ELViewController: UITableViewController{

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var entriesLabel: UILabel!
    
    var ref:FIRDatabaseReference?
    
    var entries: [Packet]! = []
    
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    //var entries: [FIRDataSnapshot]! = []
    var handle: FIRAuthStateDidChangeListenerHandle?
    var connectedRef:FIRDatabaseReference?
    
    var connected:Bool = true;
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular

    var testCalendar = Calendar(identifier: .gregorian)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    func labelUI(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: entriesLabel.frame.size.height - width, width:  entriesLabel.frame.size.width, height: entriesLabel.frame.size.height)
        border.borderWidth = width
        entriesLabel.layer.addSublayer(border)
        entriesLabel.layer.masksToBounds = true
        defaultOptions.transitionStyle = .reveal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.bc
        currentDate = Date()
        checkConnectionWithFB()
        configureDatabase()
        labelUI()
    }
    
    func seperateDate(dateS:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: dateS)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }
    
    func seperateTime(dateS:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: dateS)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date!)
    }
    
    //Temporary measure before adding persistent state
    func checkConnectionWithFB(){
        connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef?.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.connected = true
            } else {
                self.connected = false
            }
        })
    }
    
    //This function retrieves data form FB and puts starts to enter it into the tableview
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]!,
                                    text: entrySnap[Constants.Entry.text]!,
                                    wordCount: entrySnap[Constants.Entry.wordCount]!,
                                    uid: entrySnap[Constants.Entry.uid]!,
                                    emotion: entrySnap[Constants.Entry.emotion]!,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]!,
                                    key: snapshot.key)
            entry.setOrder(order: entry.timestamp)
            strongSelf.entries.append(entry)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.entries.count-1, section: 0)], with: .automatic)
            
            strongSelf.entries.sort(by: {$0.order < $1.order})
            strongSelf.tableView.reloadData()
        })
    }
    
    // Creates each individual cell given the data of that cell's entry
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableCell") as! CustomTableCell
        cell.delegate = self
        // Unpack message from Firebase DataSnapshot
        let entry = self.entries[indexPath.row]
        let words = entry.wordCount
        let preview = entry.text
        cell.dateLabel?.text = seperateDate(dateS: entry.date)
        cell.previewLabel?.text = preview
        cell.wordCount?.text = words
        cell.timeLabel?.text = seperateTime(dateS: entry.date)
        //when emotions come in
        // cell.imageView?.image = UIImage(named: "ic_account_circle")
        
        //Change color
        if ( indexPath.row % 2 == 0 ){
            cell.backgroundColor = Constants.backgroundColor.bc
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    //Returns the number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    //On selection of a cell, this function take the user to the entry the cell contains
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = self.entries[indexPath.row]
        print(indexPath.row)
        
        self.performSegue(withIdentifier: "segueToEntry", sender: entry);
    }
    
    //date
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        
        _ = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        _ = DateFormatter().shortWeekdaySymbols[weekday-1]
        
        _ = testCalendar.component(.day, from: currentDate)
    }
    
    //Creates a segue to take the user to a specific entry
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToEntry" {
            guard let object = sender as? Packet else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
            print(dvc.key)
        }
        
        if segue.identifier == "segueToMark"{
            guard let object = sender as? String else { return }
            let dvc = segue.destination as! MarkOptionsViewController
            dvc.key = object
            print(dvc.key)
        }
        
    }
    
    //Go back to main view
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    @IBAction func unwindToLogs(segue: UIStoryboardSegue) {}
    
    
}

extension ELViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let entry = entries[indexPath.row]
        
        if orientation == .left {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            return[flag]
        } else {
            
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableCell
            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
                self.present(controller, animated: true, completion: nil)
            }
            configure(action: more, with: .more)
            
                return [more]
        }
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        action.backgroundColor = .clear
        action.textColor = descriptor.color
        action.font = .systemFont(ofSize: 13)
        action.transitionDelegate = ScaleTransition.default
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        options.buttonSpacing = 4
        options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        return options
    }

}

enum ActionDescriptor {
    case more, flag
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .more: return "More"
        case .flag: return "Flag"
            
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .more: name = "more"
        case .flag: name = "flag"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        }
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}
