//
//  CharacterResults.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/21/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct CharacterResults: Codable {
    let mal_id: Int?
    let url: String?
    let image_url: String?
    let name: String?
    let alternative_names: [String]?
    let anime: [CharacterAnime]?
    let manga: [CharacterManga]?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case name = "name"
        case alternative_names = "alternative_names"
        case anime = "anime"
        case manga = "manga"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        alternative_names = try values.decodeIfPresent([String].self, forKey: .alternative_names)
        anime = try values.decodeIfPresent([CharacterAnime].self, forKey: .anime)
        manga = try values.decodeIfPresent([CharacterManga].self, forKey: .manga)
    }

}
