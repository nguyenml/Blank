//
//  Track+CoreDataProperties.swift
//  
//
//  Created by Marvin Nguyen on 6/28/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var currentStreak: Int16
    @NSManaged public var daysCompleted: Int16

}
