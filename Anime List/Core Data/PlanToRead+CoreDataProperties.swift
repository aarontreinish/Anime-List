//
//  PlanToRead+CoreDataProperties.swift
//  Anime List
//
//  Created by Aaron Treinish on 5/28/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//
//

import Foundation
import CoreData


extension PlanToRead {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanToRead> {
        return NSFetchRequest<PlanToRead>(entityName: "PlanToRead")
    }

    @NSManaged public var image_url: String?
    @NSManaged public var mal_id: Float
    @NSManaged public var name: String?

}
