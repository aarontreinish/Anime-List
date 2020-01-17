//
//  Related.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Related: Codable {
    let adaptation: [Adaptation]?
    let sideStory: [SideStory]?
    let summary: [Summary]?

    enum CodingKeys: String, CodingKey {

        case adaptation = "Adaptation"
        case sideStory = "Side story"
        case summary = "Summary"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        adaptation = try values.decodeIfPresent([Adaptation].self, forKey: .adaptation)
        sideStory = try values.decodeIfPresent([SideStory].self, forKey: .sideStory)
        summary = try values.decodeIfPresent([Summary].self, forKey: .summary)
    }

}
