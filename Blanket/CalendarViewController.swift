//
//  CalendarViewController.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    
    let todaysDates = Date()
    
    var entries: [Packet]!
    var entryDate: [String:Packet] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        getSetupDateFromEntries()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.entryDot.isHidden = false
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
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "unwindToLogs", sender: self)
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
