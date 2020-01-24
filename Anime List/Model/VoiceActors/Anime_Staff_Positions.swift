//
//  Anime_Staff_Positions.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/24/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Anime_staff_positions : Codable {
    let position : String?
    let anime : Anime?

    enum CodingKeys: String, CodingKey {

        case position = "position"
        case anime = "anime"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        position = try values.decodeIfPresent(String.self, forKey: .position)
        anime = try values.decodeIfPresent(Anime.self, forKey: .anime)
    }

}
