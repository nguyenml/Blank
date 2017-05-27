//
//  CustomTableCell.swift
//  
//
//  Created by Marvin Nguyen on 4/19/17.
//
//

import Foundation
import UIKit
import SwipeCellKit

class CustomTableCell: UITableViewCell {
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    var animator: Any?
    var indicatorView = IndicatorView(frame: .zero)
    
    func setupIndicatorView(bool:Bool) {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        if bool{
            indicatorView.color = UIColor(hex: 0x17DF82)
        }
        else{
            indicatorView.color = UIColor.clear
        }
        indicatorView.backgroundColor = .clear
        contentView.addSubview(indicatorView)
        let size: CGFloat = 12
        indicatorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor).isActive = true
        indicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
    }
}

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}
