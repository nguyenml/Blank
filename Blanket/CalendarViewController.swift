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
    
    let formatter = DateFormatter()
    
    let todaysDates = Date()
    
    var entries: [Packet]! = []
    var entryDate: [String:Packet] = [:]
    
    var ref:FIRDatabaseReference?
    
    let uid = String(describing: FIRAuth.auth()!.currentUser!.uid)
    var handle: FIRAuthStateDidChangeListenerHandle?
    var connectedRef:FIRDatabaseReference?
    
    @IBOutlet weak var percentChange: UILabel!
    
    @IBOutlet weak var triangleChange: UIImageView!

    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        getSetupDateFromEntries()
        setupCalendarView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    func configureData(){
        
        ref = FIRDatabase.database().reference()
        
        var lastEntry = 1
        
        self.ref?.child("Entry").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            
            guard let strongSelf = self else { return }
            guard let entrySnap = snapshot.value as? [String: Any] else { return }
            let entry = Packet.init(date: entrySnap[Constants.Entry.date] as! String,
                                    text: entrySnap[Constants.Entry.text]! as! String,
                                    wordCount: entrySnap[Constants.Entry.wordCount]! as! String,
                                    uid: entrySnap[Constants.Entry.uid]! as! String,
                                    timeStamp: entrySnap[Constants.Entry.timestamp]! as! String,
                                    key: snapshot.key,
                                    totalTime: entrySnap[Constants.Entry.totalTime]! as! String
            )
            entry.setOrder(order: entry.timestamp)
            strongSelf.formatter.dateFormat = "MMM dd, yyyy h:mm a"
            let newDate = strongSelf.formatter.date(from: entry.date)
            strongSelf.formatter.dateFormat = "yyyy MM dd"
            strongSelf.entryDate[strongSelf.formatter.string(from: newDate!)] = entry
            strongSelf.calendarView.reloadData()
            
            if lastEntry == Stats.totalEntries{
                
                strongSelf.calendarView.scrollToDate(Date(), animateScroll:true)
                strongSelf.calendarView.selectDates([Date()])
                
                self?.getLastWeekDates()
            }
            lastEntry = lastEntry + 1
        
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
    
    func setupCalendarView(){
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing  = 0
        
        calendarView.visibleDates{ dateSegment in
            self.setupViewsOfCalendar(dateSegments: dateSegment)
        }
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
                cell.selectedView.backgroundColor = UIColor(hex: 0x777777)
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
            cell.entryDot.isHidden = false
            if cellState.date.isEqual(to: todaysDates){
                cell.entryDot.backgroundColor = UIColor(hex:0xFF7F00)
            }else{
                cell.entryDot.backgroundColor = UIColor(hex: 0x17DF82)
            }
                cell.dateLabel.textColor = UIColor.white
        }
        else{
            cell.entryDot.isHidden = true
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            if ((cellState.date < yesterday!) && (cellState.date > formatter.date(from: StartDate.firstDay)!) ){
                cell.missedDay.isHidden = false
            }
            else{
                cell.missedDay.isHidden = true
            }

        }
        
    }
    
    func goToEntry(cell:JTAppleCell?,cellState:CellState){
        guard ((cell as? CalenderCell) != nil) else { return }
        
        let date = formatter.string(from: cellState.date)
        let hasEntry = entryDate[date] != nil
        if !hasEntry { return }
        self.performSegue(withIdentifier: "segueToEntry", sender: entryDate[date]);
    }
    
    func getLastWeekDates(){
        let cal = Calendar.current
        let date = cal.startOfDay(for: Date())
        var thisWeekPackets = [Packet]()
        var lastWeekPackets = [Packet]()
        let firstDay = Date()
        var lastDate = Date()
        formatter.dateFormat = "yyyy MM dd"
        
        for i in 1 ... 7 {
            let newDate = cal.date(byAdding: .day, value: -i, to: date)!
            let str = formatter.string(from: newDate)
            if entryDate[str] != nil {
                thisWeekPackets.append(entryDate[str]!)
            }
        }
        
        for i in 8 ... 14 {
            let newDate = cal.date(byAdding: .day, value: -i, to: date)!
            if i == 14 {
                lastDate = newDate
            }
            let str = formatter.string(from: newDate)
            if entryDate[str] != nil {
                lastWeekPackets.append(entryDate[str]!)
            }
        }
        
        formatter.dateFormat = "MMM dd"
        startDate.text = formatter.string(from: firstDay)
        startDate.text = startDate.text?.uppercased()
        endDate.text = formatter.string(from: lastDate)
        endDate.text = endDate.text?.uppercased()
        formatter.dateFormat = "yyyy MM dd"
        
        getAverageTime(thisWeek: thisWeekPackets,lastWeek: lastWeekPackets)
    }
    
    func getAverageTime(thisWeek:[Packet], lastWeek:[Packet]){
        var thisWeekAverage = 0.0
        var lastWeekAverage = 0.0
        var time = 0
        for packet in thisWeek {
            time = time + Int(packet.totalTime)!
        }
        
        thisWeekAverage = Double(time)/Double(thisWeek.count)
        time = 0
        
        for packet in lastWeek {
            time = time + Int(packet.totalTime)!
        }
        
        lastWeekAverage = Double(time)/Double(lastWeek.count)
        
        let change = Double((thisWeekAverage - 400)/thisWeekAverage * 100)
        percentChange.text = "\(Double(round(10*change)/10))%"
        
        if change > 0 {
            triangleChange.image = UIImage(named: "up_triangle")
            percentChange.textColor = UIColor(hex: 0x2ECC71)
        } else {
            percentChange.text = percentChange.text?.replacingOccurrences(of: "-", with: "")
            triangleChange.image = UIImage(named: "down_arrow_yellow")
            percentChange.textColor = UIColor(hex: 0x333333)
        }
        
        if lastWeek.count == 0 {
            triangleChange.image = UIImage(named: "up_triangle")
            percentChange.text = "0%"
        }

    }

}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let startDate = formatter.date(from: StartDate.firstDay)!
        var dateComponent = DateComponents()
        dateComponent.month = 1
        let endDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!)
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
