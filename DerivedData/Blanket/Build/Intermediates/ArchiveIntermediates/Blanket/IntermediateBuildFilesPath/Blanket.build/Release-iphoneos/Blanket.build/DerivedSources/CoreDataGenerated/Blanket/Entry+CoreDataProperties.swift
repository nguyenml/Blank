//
//  Entry+CoreDataProperties.swift
//  
//
//  Created by Marvin Nguyen on 6/28/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var word_count: Int16

}
