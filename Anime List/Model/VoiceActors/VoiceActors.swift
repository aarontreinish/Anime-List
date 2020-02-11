//
//  VoiceActors.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/24/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct VoiceActors : Codable {
    let request_hash : String?
    let request_cached : Bool?
    let request_cache_expiry : Int?
    let mal_id : Int?
    let url : String?
    let image_url : String?
    let website_url : String?
    let name : String?
    let given_name : String?
    let family_name : String?
    let alternate_names : [String]?
    let birthday : String?
    let member_favorites : Int?
    let about : String?
    let voice_acting_roles : [Voice_acting_roles]?
    let anime_staff_positions : [Anime_staff_positions]?
    let published_manga : [Published_Manga]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case website_url = "website_url"
        case name = "name"
        case given_name = "given_name"
        case family_name = "family_name"
        case alternate_names = "alternate_names"
        case birthday = "birthday"
        case member_favorites = "member_favorites"
        case about = "about"
        case voice_acting_roles = "voice_acting_roles"
        case anime_staff_positions = "anime_staff_positions"
        case published_manga = "published_manga"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        website_url = try values.decodeIfPresent(String.self, forKey: .website_url)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        given_name = try values.decodeIfPresent(String.self, forKey: .given_name)
        family_name = try values.decodeIfPresent(String.self, forKey: .family_name)
        alternate_names = try values.decodeIfPresent([String].self, forKey: .alternate_names)
        birthday = try values.decodeIfPresent(String.self, forKey: .birthday)
        member_favorites = try values.decodeIfPresent(Int.self, forKey: .member_favorites)
        about = try values.decodeIfPresent(String.self, forKey: .about)
        voice_acting_roles = try values.decodeIfPresent([Voice_acting_roles].self, forKey: .voice_acting_roles)
        anime_staff_positions = try values.decodeIfPresent([Anime_staff_positions].self, forKey: .anime_staff_positions)
        published_manga = try values.decodeIfPresent([Published_Manga].self, forKey: .published_manga)
    }

}
