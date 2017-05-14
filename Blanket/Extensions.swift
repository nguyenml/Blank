//
//  Extensions.swift
//  CalendarPopUp
//
//  Created by Atakishiyev Orazdurdy on 11/16/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit
import CZPicker

//
// Get humanDate
// Turkmen month
//

func GetHumanDate(month: Int) -> String
{
    let monthArr: [Int: String] =
        [ 01 : "Ýanwar",
          02 : "Fewral",
          03 : "Mart",
          04 : "Aprel",
          05 : "Maý",
          06 : "Iýun",
          07 : "Iýul",
          08 : "Awgust",
          09 : "Sentýabr",
          10 : "Oktýabr",
          11 : "Noýabr",
          12 : "Dekabr"]
    return monthArr[month]!
}

extension Date {
    
    //period -> .WeekOfYear, .Day
    func rangeOfPeriod(period: Calendar.Component) -> (Date, Date) {
        
        var startDate = Date()
        var interval : TimeInterval = 0
        let _ = Calendar.current.dateInterval(of: period, start: &startDate, interval: &interval, for: self)
        let endDate = startDate.addingTimeInterval(interval - 1)
        
        return (startDate, endDate)
    }
    
    func calcStartAndEndOfDay() -> (Date, Date) {
        return rangeOfPeriod(period: .day)
    }
    
    func calcStartAndEndOfWeek() -> (Date, Date) {
        return rangeOfPeriod(period: .weekday)
    }
    
    func calcStartAndEndOfMonth() -> (Date, Date) {
        return rangeOfPeriod(period: .month)
    }
    
    func getSpecificDate(interval: Int) -> Date {
        var timeInterval = DateComponents()
        timeInterval.day = interval
        return Calendar.current.date(byAdding: timeInterval, to: self)!
    }
    
    func getStart() -> Date {
        let (start, _) = calcStartAndEndOfDay()
        return start
    }
    
    func getEnd() -> Date {
        let (_, end) = calcStartAndEndOfDay()
        return end
    }
    
    func isBigger(to: Date) -> Bool {
        return Calendar.current.compare(self, to: to, toGranularity: .day) == .orderedDescending ? true : false
    }
    
    func isSmaller(to: Date) -> Bool {
        return Calendar.current.compare(self, to: to, toGranularity: .day) == .orderedAscending ? true : false
    }
    
    func isEqual(to: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: to)
    }
    
    func isElement(of: [Date]) -> Bool {
        for element in of {
            if self.isEqual(to: element) {
                return true
            }
        }
        return false
    }
    
    func getElement(of: [Date]) -> Date {
        for element in of {
            if self.isEqual(to: element) {
                return element
            }
        }
        return Date()
    }
    
}

//class AnimationView: UIView {
//    func animateWithFlipEffect(withCompletionHandler completionHandler:(() -> Void)?) {
//        AnimationClass.flipAnimation(self, completion: completionHandler)
//    }
//    func animateWithBounceEffect(withCompletionHandler completionHandler:(() -> Void)?) {
//        let viewAnimation = AnimationClass.BounceEffect()
//        viewAnimation(self) { _ in
//            completionHandler?()
//        }
//    }
//    func animateWithFadeEffect(withCompletionHandler completionHandler:(() -> Void)?) {
//        let viewAnimation = AnimationClass.fadeOutEffect()
//        viewAnimation(self) { _ in
//            completionHandler?()
//        }
//    }
//}

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}

extension UserDefaults {
    
    static let defaults = UserDefaults.standard
    
    static var lastAccessDate: Date? {
        get {
            return defaults.object(forKey: "lastAccessDate") as? Date
        }
        set {
            guard let newValue = newValue else { return }
            guard let lastAccessDate = lastAccessDate else {
                defaults.set(newValue, forKey: "lastAccessDate")
                return
            }
            defaults.set(newValue, forKey: "lastAccessDate")
        }
    }
}



extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension MainViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    public func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return emotes.count
    }

    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        return nil
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return emotes[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        switch row{
        case 0:
            imFeeling = Constants.Emotions.angry
            EmojiLabel.text = "😠"
            emotionLabel.text = "Angry"
            
        case 1:
            imFeeling = Constants.Emotions.content
            EmojiLabel.text = "☺️"
            emotionLabel.text = "Content"
            
        case 2:
            imFeeling = Constants.Emotions.excited
            EmojiLabel.text = "😀"
            emotionLabel.text = "Excited"
            
        case 3:
            imFeeling = Constants.Emotions.sad
            EmojiLabel.text = "😢"
            emotionLabel.text = "Unhappy"
            
        default:
            imFeeling = Constants.Emotions.content
            EmojiLabel.text = "☺️"
            emotionLabel.text = "Content"
        }
        print(imFeeling)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension String {
    subscript(pos: Int) -> String {
        precondition(pos >= 0, "character position can't be negative")
        return self[pos...pos]
    }
    subscript(range: Range<Int>) -> String {
        precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
        let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)]
    }
    subscript(range: ClosedRange<Int>) -> String {
        precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
        let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)]
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
}


//extension ELViewController: SwipeTableViewCellDelegate {
//    
//    need a lot of help on this one
//    ------------
//     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: //SwipeActionsOrientation) -> [SwipeAction]? {
//        let entry = entries[indexPath.row]
//       let flag = SwipeAction(style: .default, title: nil, handler: nil)
//       if orientation == .left {
//           flag.hidesWhenSelected = true
//           configure(action: flag, with: .flag)
//       }
//        return[flag]
//}
//
//func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
//    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
//    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
//    action.backgroundColor = .clear
//    action.textColor = descriptor.color
//    action.font = .systemFont(ofSize: 13)
//    action.transitionDelegate = ScaleTransition.default
//}
//
//func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//    var options = SwipeTableOptions()
//    options.expansionStyle = orientation == .left ? .selection : .destructive
//    options.transitionStyle = defaultOptions.transitionStyle
//    options.buttonSpacing = 4
//    options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
//    return options
//}
//
//}

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


