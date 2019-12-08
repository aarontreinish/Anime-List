//
//  TopResults.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct TopResults: Codable {
    let mal_id : Int?
    let rank : Int?
    let title : String?
    let url : String?
    let image_url : String?
    let type : String?
    let episodes : Int?
    let start_date : String?
    let end_date : String?
    let members : Int?
    let score : Double?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case rank = "rank"
        case title = "title"
        case url = "url"
        case image_url = "image_url"
        case type = "type"
        case episodes = "episodes"
        case start_date = "start_date"
        case end_date = "end_date"
        case members = "members"
        case score = "score"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        rank = try values.decodeIfPresent(Int.self, forKey: .rank)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        episodes = try values.decodeIfPresent(Int.self, forKey: .episodes)
        start_date = try values.decodeIfPresent(String.self, forKey: .start_date)
        end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
        members = try values.decodeIfPresent(Int.self, forKey: .members)
        score = try values.decodeIfPresent(Double.self, forKey: .score)
    }

}

