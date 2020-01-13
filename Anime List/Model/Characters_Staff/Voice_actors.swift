//
//  Voice_actors.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Voice_actors: Codable {
    let mal_id: Int?
    let name: String?
    let url: String?
    let image_url: String?
    let language: String?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case name = "name"
        case url = "url"
        case image_url = "image_url"
        case language = "language"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        language = try values.decodeIfPresent(String.self, forKey: .language)
    }

}
