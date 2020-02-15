//
//  Anime+CoreDataProperties.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedAnime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedAnime> {
        return NSFetchRequest<SavedAnime>(entityName: "SavedAnime")
    }

    @NSManaged public var name: String?
    @NSManaged public var mal_id: Float
    @NSManaged public var image_url: String?

}
