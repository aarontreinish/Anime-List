//
//  To.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct To : Codable {
    let day : Int?
    let month : Int?
    let year : Int?

    enum CodingKeys: String, CodingKey {

        case day = "day"
        case month = "month"
        case year = "year"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = try values.decodeIfPresent(Int.self, forKey: .day)
        month = try values.decodeIfPresent(Int.self, forKey: .month)
        year = try values.decodeIfPresent(Int.self, forKey: .year)
    }

}

