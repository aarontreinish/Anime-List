//
//  Anime.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Anime : Codable {
    let request_hash : String?
    let request_cached : Bool?
    let request_cache_expiry : Int?
    let mal_id : Int?
    let url : String?
    let image_url : String?
    let trailer_url : String?
    let title : String?
    let title_english : String?
    let title_japanese : String?
    let title_synonyms : [String]?
    let type : String?
    let source : String?
    let episodes : Int?
    let status : String?
    let airing : Bool?
    let aired : Aired?
    let duration : String?
    let rating : String?
    let score : Double?
    let scored_by : Int?
    let rank : Int?
    let popularity : Int?
    let members : Int?
    let favorites : Int?
    let synopsis : String?
    let background : String?
    let premiered : String?
    let broadcast : String?
    let related : Related?
    let producers : [Producers]?
    let licensors : [Licensors]?
    let studios : [Studios]?
    let genres : [Genres]?
    let opening_themes : [String]?
    let ending_themes : [String]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case trailer_url = "trailer_url"
        case title = "title"
        case title_english = "title_english"
        case title_japanese = "title_japanese"
        case title_synonyms = "title_synonyms"
        case type = "type"
        case source = "source"
        case episodes = "episodes"
        case status = "status"
        case airing = "airing"
        case aired = "aired"
        case duration = "duration"
        case rating = "rating"
        case score = "score"
        case scored_by = "scored_by"
        case rank = "rank"
        case popularity = "popularity"
        case members = "members"
        case favorites = "favorites"
        case synopsis = "synopsis"
        case background = "background"
        case premiered = "premiered"
        case broadcast = "broadcast"
        case related = "related"
        case producers = "producers"
        case licensors = "licensors"
        case studios = "studios"
        case genres = "genres"
        case opening_themes = "opening_themes"
        case ending_themes = "ending_themes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        trailer_url = try values.decodeIfPresent(String.self, forKey: .trailer_url)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        title_english = try values.decodeIfPresent(String.self, forKey: .title_english)
        title_japanese = try values.decodeIfPresent(String.self, forKey: .title_japanese)
        title_synonyms = try values.decodeIfPresent([String].self, forKey: .title_synonyms)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        episodes = try values.decodeIfPresent(Int.self, forKey: .episodes)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        airing = try values.decodeIfPresent(Bool.self, forKey: .airing)
        aired = try values.decodeIfPresent(Aired.self, forKey: .aired)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
        rating = try values.decodeIfPresent(String.self, forKey: .rating)
        score = try values.decodeIfPresent(Double.self, forKey: .score)
        scored_by = try values.decodeIfPresent(Int.self, forKey: .scored_by)
        rank = try values.decodeIfPresent(Int.self, forKey: .rank)
        popularity = try values.decodeIfPresent(Int.self, forKey: .popularity)
        members = try values.decodeIfPresent(Int.self, forKey: .members)
        favorites = try values.decodeIfPresent(Int.self, forKey: .favorites)
        synopsis = try values.decodeIfPresent(String.self, forKey: .synopsis)
        background = try values.decodeIfPresent(String.self, forKey: .background)
        premiered = try values.decodeIfPresent(String.self, forKey: .premiered)
        broadcast = try values.decodeIfPresent(String.self, forKey: .broadcast)
        related = try values.decodeIfPresent(Related.self, forKey: .related)
        producers = try values.decodeIfPresent([Producers].self, forKey: .producers)
        licensors = try values.decodeIfPresent([Licensors].self, forKey: .licensors)
        studios = try values.decodeIfPresent([Studios].self, forKey: .studios)
        genres = try values.decodeIfPresent([Genres].self, forKey: .genres)
        opening_themes = try values.decodeIfPresent([String].self, forKey: .opening_themes)
        ending_themes = try values.decodeIfPresent([String].self, forKey: .ending_themes)
    }

}
