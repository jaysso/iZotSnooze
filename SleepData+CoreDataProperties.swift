//
//  SleepData+CoreDataProperties.swift
//  
//
//  Created by Gerald Post  on 3/7/21.
//
//

import Foundation
import CoreData


extension SleepData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepData> {
        return NSFetchRequest<SleepData>(entityName: "SleepData")
    }

    @NSManaged public var date: String?
    @NSManaged public var sleep: String?
    @NSManaged public var wake: String?
    @NSManaged public var timeSlept: String?
    @NSManaged public var dayOfWeek: String?
    @NSManaged public var mood: String?
    @NSManaged public var noise: String?
    @NSManaged public var heartRate: String?
    @NSManaged public var breathRate: String?

}
