//
//  Staff.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Staff: Codable {
    let mal_id: Int?
    let url: String?
    let name: String?
    let image_url: String?
    let positions: [String]?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case url = "url"
        case name = "name"
        case image_url = "image_url"
        case positions = "positions"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        positions = try values.decodeIfPresent([String].self, forKey: .positions)
    }

}
