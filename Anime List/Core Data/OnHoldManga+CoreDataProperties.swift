//
//  OnHoldManga+CoreDataProperties.swift
//  Anime List
//
//  Created by Aaron Treinish on 5/28/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//
//

import Foundation
import CoreData


extension OnHoldManga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OnHoldManga> {
        return NSFetchRequest<OnHoldManga>(entityName: "OnHoldManga")
    }

    @NSManaged public var image_url: String?
    @NSManaged public var name: String?
    @NSManaged public var mal_id: Float

}
