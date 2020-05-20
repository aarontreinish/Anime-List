//
//  PersonSearch.swift
//  Anime List
//
//  Created by Aaron Treinish on 5/20/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

// MARK: - PersonSearched
struct PersonSearch: Codable {
    let request_hash: String?
    let request_cached: Bool?
    let request_cache_expiry: Int?
    let results: [PersonResults]?
    let last_page: Int?

}

// MARK: - Result
struct PersonResults: Codable {
    let mal_id: Int?
    let url: String?
    let image_url: String?
    let name: String?
    let alternative_names: [String]?

}
