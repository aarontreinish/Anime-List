//
//  Results.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Recommendations_results: Codable {
    let mal_id: Int?
    let url: String?
    let image_url: String?
    let recommendation_url: String?
    let title: String?
    let recommendation_count: Int?

    enum CodingKeys: String, CodingKey {

        case mal_id = "mal_id"
        case url = "url"
        case image_url = "image_url"
        case recommendation_url = "recommendation_url"
        case title = "title"
        case recommendation_count = "recommendation_count"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mal_id = try values.decodeIfPresent(Int.self, forKey: .mal_id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
        recommendation_url = try values.decodeIfPresent(String.self, forKey: .recommendation_url)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        recommendation_count = try values.decodeIfPresent(Int.self, forKey: .recommendation_count)
    }

}
