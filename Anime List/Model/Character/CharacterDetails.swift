//
//  CharacterDetails.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/21/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct CharacterDetails: Codable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let mal_id: Int?
    let url: String?
    let name: String?
    let name_kanji: String?
    let nicknames: [String]?
    let about: String?
    let member_favorites: Int?
    let image_url: String?
    let animeography: [Animeography]?
    let mangaography: [Mangaography]?
    let voice_actors: [Voice_actors]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case mal_id = "mal_id"
        case url = "url"
        case name = "name"
        case name_kanji = "name_kanji"
        case nicknames = "nicknames"
        case about = "about"
        case member_favorites = "member_favorites"
        case image_url = "image_url"
        case animeography = "animeography"
        case mangaography = "mangaography"
        case voice_actors = "voice_actors"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        name_kanji = try values.decodeIfPresent(String.self, forKey: .name_kanji)
        nicknames = try values.decodeIfPresent([String].self, forKey: .nicknames)
        about = try values.decodeIfPresent(String.self, forKey: .about)
        member_favorites = try values.decodeIfPresent(Int.self, forKey: .member_favorites)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        animeography = try values.decodeIfPresent([Animeography].self, forKey: .animeography)
        mangaography = try values.decodeIfPresent([Mangaography].self, forKey: .mangaography)
        voice_actors = try values.decodeIfPresent([Voice_actors].self, forKey: .voice_actors)
    }

}
