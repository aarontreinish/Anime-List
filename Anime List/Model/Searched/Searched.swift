//
//  Searched.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Searched: Codable {
    let request_hash : String?
    let request_cached : Bool?
    let request_cache_expiry : Int?
    let results : [Results]?
    let last_page : Int?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case results = "results"
        case last_page = "last_page"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        results = try values.decodeIfPresent([Results].self, forKey: .results)
        last_page = try values.decodeIfPresent(Int.self, forKey: .last_page)
    }

}
