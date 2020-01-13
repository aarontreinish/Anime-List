//
//  Top.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

// MARK: - Top
struct Top: Codable {
    let requestHash: String?
    let requestCached: Bool?
    let requestCacheExpiry: Int?
    let top: [TopElement]?

    enum CodingKeys: String, CodingKey {
        case requestHash
        case requestCached
        case requestCacheExpiry
        case top
    }
}

struct TopElement: Codable {
    let mal_id: Int?
    let title: String?
    let image_url: String?
    
}

//// MARK: - TopElement
//struct TopElement: Codable {
//    let malID, rank: Int?
//    let title: String?
//    let url: String?
//    let imageURL: String?
//    let episodes: Int?
//    let startDate: String?
//    let endDate: String?
//    let members: Int?
//    let score: Double?
//
//    enum CodingKeys: String, CodingKey {
//        case malID
//        case rank, title, url
//        case imageURL
//        case type, episodes
//        case startDate
//        case endDate
//        case members, score
//    }
//}
