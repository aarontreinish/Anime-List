//
//  Section.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/8/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

enum Section: Int {
    case topAiringAnime
    case topRankedAnime
    case topUpcomingAnime

    init?(indexPath: NSIndexPath) {
        self.init(rawValue: indexPath.section)
    }

    static var numberOfSections: Int { return 3 }
}
