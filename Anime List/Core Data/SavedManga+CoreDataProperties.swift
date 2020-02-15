//
//  SavedManga+CoreDataProperties.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/15/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedManga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedManga> {
        return NSFetchRequest<SavedManga>(entityName: "SavedManga")
    }

    @NSManaged public var mal_id: Float
    @NSManaged public var name: String?
    @NSManaged public var image_url: String?

}
