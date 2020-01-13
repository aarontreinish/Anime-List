//
//  Characters.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Characters: Codable {
    let mal_id: Int?
    let url: String?
    let image_url: String?
    let name: String?
    let role: String?
    let voice_actors: [Voice_actors]?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case name = "name"
        case role = "role"
        case voice_actors = "voice_actors"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        voice_actors = try values.decodeIfPresent([Voice_actors].self, forKey: .voice_actors)
    }

}
