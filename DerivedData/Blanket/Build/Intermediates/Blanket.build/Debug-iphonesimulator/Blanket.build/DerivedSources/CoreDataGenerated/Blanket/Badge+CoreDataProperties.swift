//
//  Badge+CoreDataProperties.swift
//  
//
//  Created by Marvin Nguyen on 6/28/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Badge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Badge> {
        return NSFetchRequest<Badge>(entityName: "Badge")
    }

    @NSManaged public var desc: String?
    @NSManaged public var earned: Bool
    @NSManaged public var name: String?

}
