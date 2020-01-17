//
//  Manga.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Manga: Codable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let mal_id: Int?
    let url: String?
    let title: String?
    let title_english: String?
    let title_synonyms: [String]?
    let title_japanese: String?
    let status: String?
    let image_url: String?
    let type: String?
    let volumes: Int?
    let chapters: Int?
    let publishing: Bool?
    let published: Published?
    let rank: Int?
    let score: Double?
    let scored_by: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let synopsis: String?
    let background: String?
    let related: Related?
    let genres: [Genres]?
    let authors: [Authors]?
    let serializations: [Serializations]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case mal_id = "mal_id"
        case url = "url"
        case title = "title"
        case title_english = "title_english"
        case title_synonyms = "title_synonyms"
        case title_japanese = "title_japanese"
        case status = "status"
        case image_url = "image_url"
        case type = "type"
        case volumes = "volumes"
        case chapters = "chapters"
        case publishing = "publishing"
        case published = "published"
        case rank = "rank"
        case score = "score"
        case scored_by = "scored_by"
        case popularity = "popularity"
        case members = "members"
        case favorites = "favorites"
        case synopsis = "synopsis"
        case background = "background"
        case related = "related"
        case genres = "genres"
        case authors = "authors"
        case serializations = "serializations"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        title_english = try values.decodeIfPresent(String.self, forKey: .title_english)
        title_synonyms = try values.decodeIfPresent([String].self, forKey: .title_synonyms)
        title_japanese = try values.decodeIfPresent(String.self, forKey: .title_japanese)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        volumes = try values.decodeIfPresent(Int.self, forKey: .volumes)
        chapters = try values.decodeIfPresent(Int.self, forKey: .chapters)
        publishing = try values.decodeIfPresent(Bool.self, forKey: .publishing)
        published = try values.decodeIfPresent(Published.self, forKey: .published)
        rank = try values.decodeIfPresent(Int.self, forKey: .rank)
        score = try values.decodeIfPresent(Double.self, forKey: .score)
        scored_by = try values.decodeIfPresent(Int.self, forKey: .scored_by)
        popularity = try values.decodeIfPresent(Int.self, forKey: .popularity)
        members = try values.decodeIfPresent(Int.self, forKey: .members)
        favorites = try values.decodeIfPresent(Int.self, forKey: .favorites)
        synopsis = try values.decodeIfPresent(String.self, forKey: .synopsis)
        background = try values.decodeIfPresent(String.self, forKey: .background)
        related = try values.decodeIfPresent(Related.self, forKey: .related)
        genres = try values.decodeIfPresent([Genres].self, forKey: .genres)
        authors = try values.decodeIfPresent([Authors].self, forKey: .authors)
        serializations = try values.decodeIfPresent([Serializations].self, forKey: .serializations)
    }
}
