//
//  Results.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Results : Codable {
    let mal_id : Int?
    let url : String?
    let image_url : String?
    let title : String?
    let airing : Bool?
    let synopsis : String?
    let type : String?
    let episodes : Int?
    let score : Double?
    let start_date : String?
    let end_date : String?
    let members : Int?
    let rated : String?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case title = "title"
        case airing = "airing"
        case synopsis = "synopsis"
        case type = "type"
        case episodes = "episodes"
        case score = "score"
        case start_date = "start_date"
        case end_date = "end_date"
        case members = "members"
        case rated = "rated"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        airing = try values.decodeIfPresent(Bool.self, forKey: .airing)
        synopsis = try values.decodeIfPresent(String.self, forKey: .synopsis)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        episodes = try values.decodeIfPresent(Int.self, forKey: .episodes)
        score = try values.decodeIfPresent(Double.self, forKey: .score)
        start_date = try values.decodeIfPresent(String.self, forKey: .start_date)
        end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
        members = try values.decodeIfPresent(Int.self, forKey: .members)
        rated = try values.decodeIfPresent(String.self, forKey: .rated)
    }

}

