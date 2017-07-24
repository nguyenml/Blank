//
//  CalenderCell.swift
//  Blanket
//
//  Created by Marvin Nguyen on 7/21/17.
//  Copyright © 2017 Marvin Nguyen. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalenderCell: JTAppleCell {
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var selectedView:UIView!
    @IBOutlet weak var entryDot:UIView!
    @IBOutlet weak var missedDay:UIView!
}
