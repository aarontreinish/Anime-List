//
//  Recommendations.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Recommendations: Codable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let recommendations: [Recommendations_results]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case recommendations = "recommendations"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        recommendations = try values.decodeIfPresent([Recommendations_results].self, forKey: .recommendations)
    }
}
