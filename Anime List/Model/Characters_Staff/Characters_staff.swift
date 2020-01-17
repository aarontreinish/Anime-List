//
//  Characters_staff.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Characters_staff: Codable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let characters: [Characters]?
    let staff: [Staff]?

    enum CodingKeys: String, CodingKey {

        case request_hash = "request_hash"
        case request_cached = "request_cached"
        case request_cache_expiry = "request_cache_expiry"
        case characters = "characters"
        case staff = "staff"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        request_hash = try values.decodeIfPresent(String.self, forKey: .request_hash)
        request_cached = try values.decodeIfPresent(Bool.self, forKey: .request_cached)
        request_cache_expiry = try values.decodeIfPresent(Int.self, forKey: .request_cache_expiry)
        characters = try values.decodeIfPresent([Characters].self, forKey: .characters)
        staff = try values.decodeIfPresent([Staff].self, forKey: .staff)
    }

}
