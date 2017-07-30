//
//  CalendarViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase


class CalendarViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var longestStreakLabel: UILabel!
    @IBOutlet weak var totalDaysLabel: UILabel!
    
    let formatter = DateFormatter()
    
    let todaysDates = Date()
    
    var entries: [Packet]! = []
    var entryDate: [String:Packet] = [:]
    
    var ref:FIRDatabaseReference?
    
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    var handle: FIRAuthStateDidChangeListenerHandle?
    var connectedRef:FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        setupLabels()
        setupCalendarView()
        getSetupDateFromEntries()

        // Do any additional setup after loading the view.
    }

    func configureData(){
        
        ref = FIRDatabase.database().reference()
        
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]!,
                                    text: entrySnap[Constants.Entry.text]!,
                                    wordCount: entrySnap[Constants.Entry.wordCount]!,
                                    uid: entrySnap[Constants.Entry.uid]!,
                                    emotion: entrySnap[Constants.Entry.emotion]!,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]!,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]!
            )
            
            if snapshot.hasChild(Constants.Entry.topic){
                entry.topic = entrySnap[Constants.Entry.topic]!
            }
            
            if snapshot.hasChild(Constants.Entry.mark){
                entry.mark = entrySnap[Constants.Entry.mark]!
            }
            entry.setOrder(order: entry.timestamp)
            strongSelf.formatter.dateFormat = "MMM dd, yyyy h:mm a"
            let newDate = strongSelf.formatter.date(from: entry.date)
            strongSelf.formatter.dateFormat = "yyyy MM dd"
            strongSelf.entryDate[strongSelf.formatter.string(from: newDate!)] = entry
            strongSelf.calendarView.reloadData()
        })
        
        updateDataOnChange()
    }
    
    func updateDataOnChange(){
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childChanged, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let entrySnap = snapshot.value as? [String: String] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date]!,
                                    text: entrySnap[Constants.Entry.text]!,
                                    wordCount: entrySnap[Constants.Entry.wordCount]!,
                                    uid: entrySnap[Constants.Entry.uid]!,
                                    emotion: entrySnap[Constants.Entry.emotion]!,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]!,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]!
            )
            strongSelf.formatter.dateFormat = "MMM dd, yyyy h:mm a"
            let newDate = strongSelf.formatter.date(from: entry.date)
            strongSelf.formatter.dateFormat = "yyyy MM dd"
            strongSelf.entryDate.updateValue(entry, forKey:strongSelf.formatter.string(from: newDate!))
        })
    }
    
    func getSetupDateFromEntries(){
        if entries.isEmpty { return }
        let dates:[String] = entries.map({ $0.date})
        for date in dates{
            formatter.dateFormat = "MMM dd, yyyy h:mm a"
            let newDate = formatter.date(from: date)
            formatter.dateFormat = "yyyy MM dd"
            if newDate != nil{
                entryDate[formatter.string(from: newDate!)] = entries.filter{ $0.date == date}.first
            }
        }
    }
    
    func setupLabels(){
        currentStreakLabel.text = String(Stats.currentStreak)
        longestStreakLabel.text = String(Stats.longestStreak)
        totalDaysLabel.text = String(Stats.totalEntries)
    }
    
    func setupCalendarView(){
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing  = 0
        
        calendarView.visibleDates{ dateSegment in
            self.setupViewsOfCalendar(dateSegments: dateSegment)
        }
        
        calendarView.scrollToDate(Date(), animateScroll:true)
        calendarView.selectDates([Date()])
        
    }
    
    func setupViewsOfCalendar(dateSegments:DateSegmentInfo){
        guard let date = dateSegments.monthDates.first?.date else {return}
        
        self.formatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = self.formatter.string(from:date)
    }
    
    func configureCell(cell: JTAppleCell?, cellState:CellState){
        guard let validCell = cell as? CalenderCell else { return }
        
        handleCellVisibility(cell: validCell, cellState: cellState)
        handleTextColor(cell: validCell, cellState: cellState)
        handleSelectedView(cell: validCell, cellState: cellState)
        handleEntry(cell: validCell, cellState: cellState)
        
    }
    
    func handleCellVisibility(cell:CalenderCell, cellState: CellState){
        cell.isHidden = cellState.dateBelongsTo == .thisMonth ? false : true
    }
    
    func handleTextColor(cell: CalenderCell, cellState: CellState){
        
        formatter.dateFormat = "yyyy MM dd"
        let todayDateString = formatter.string(from: todaysDates)
        let monthDateString = formatter.string(from: cellState.date)
        
        if todayDateString == monthDateString {
            cell.dateLabel.textColor = UIColor(hex: 0xFF7F00)
            if cellState.isSelected{
                cell.selectedView.backgroundColor = UIColor(hex: 0xFF7F00)
                cell.dateLabel.textColor = UIColor.white
            }
        } else {
            if cellState.isSelected{
                cell.dateLabel.textColor = UIColor.white
            }
            else {
                if cellState.dateBelongsTo == .thisMonth {
                    cell.dateLabel.textColor = UIColor(hex:0x333333)
                } else {
                    cell.dateLabel.textColor = UIColor.gray
                }
            }
        }
    }
    
    func handleSelectedView(cell:CalenderCell, cellState: CellState){
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }

    func handleEntry(cell:CalenderCell, cellState:CellState){
        let hasEntry = entryDate[formatter.string(from: cellState.date)] != nil
        if hasEntry{
            print(cellState.date)
            cell.entryDot.isHidden = false
            if cellState.date.isEqual(to: todaysDates){
                cell.entryDot.backgroundColor = UIColor(hex:0xFF7F00)
            }else{
                cell.entryDot.backgroundColor = UIColor(hex: 0x17DF82)
            }
                cell.dateLabel.textColor = UIColor.white
        }
        else{
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            if ((cellState.date < yesterday!) && (cellState.date > formatter.date(from: StartDate.firstDay)!) ){
                cell.missedDay.isHidden = false
            }
            else{
                cell.missedDay.isHidden = true
            }
            cell.entryDot.isHidden = true
        }
        
    }
    
    func goToEntry(cell:JTAppleCell?,cellState:CellState){
        guard ((cell as? CalenderCell) != nil) else { return }
        
        let date = formatter.string(from: cellState.date)
        let hasEntry = entryDate[date] != nil
        if !hasEntry { return }
        self.performSegue(withIdentifier: "segueToEntry", sender: entryDate[date]);
    }

}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: StartDate.firstDay)!
        let endDate = formatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        goToEntry(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupViewsOfCalendar(dateSegments: visibleDates)
        
    }

    
}

extension CalendarViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToEntry" {
            guard let object = sender as? Packet else { return }
            let dvc = segue.destination as! IndividualEntryViewController
            dvc.entry = object
        }
    }
}
