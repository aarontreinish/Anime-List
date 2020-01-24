//
//  JikanEndPoint.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum JikanAPI {
    case topAiring(type: String)
    case mostPopular(type: String)
    case anime(id: Int)
    case searchAnime(name: String)
    case searchManga(name: String)
    case searchCharacter(name: String)
    case topRanked(type: String)
    case topUpcoming(type: String)
    case schedule(day: String)
    case characters_staff(id: Int)
    case recommendations(id: Int)
    case favorites(type: String)
    case manga(id: Int)
    case mangaCharacters(id: Int)
    case mangaRecommendations(id: Int)
    case character(id: Int)
    case person(id: Int)
}

extension JikanAPI: EndPointType {
    
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .production: return "https://api.jikan.moe/v3"
        case .qa: return "https://api.jikan.moe/v3"
        case .staging: return "https://api.jikan.moe/v3"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .topAiring(let type):
            return "/top/\(type)/1/airing"
        case .anime(let id):
            return "/anime/\(id)"
        case .searchAnime:
            return "/search/anime"
        case .searchManga:
            return "/search/manga"
        case .searchCharacter:
            return "/search/character"
        case .topRanked(let type):
            return "/top/\(type)/"
        case .topUpcoming(let type):
            return "/top/\(type)/1/upcoming"
        case .mostPopular(let type):
            return "/top/\(type)/1/bypopularity"
        case .schedule(let day):
            return "/schedule/\(day)"
        case .characters_staff(let id):
            return "anime/\(id)/characters_staff"
        case .recommendations(let id):
            return "anime/\(id)/recommendations"
        case .favorites(let type):
            return "/top/\(type)/1/favorite"
        case .manga(let id):
            return "/manga/\(id)"
        case .mangaCharacters(let id):
            return "/manga/\(id)/characters"
        case .mangaRecommendations(let id):
            return "/manga/\(id)/recommendations"
        case .character(let id):
            return "/character/\(id)"
        case .person(let id):
            return "/person/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .searchAnime(let name):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["q":name])
        case .searchManga(let name):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["q":name])
        case .searchCharacter(let name):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["q":name])
//        case .newMovies(let page):
//            return .requestParameters(bodyParameters: nil,
//                                      bodyEncoding: .urlEncoding,
//                                      urlParameters: ["page":page,
//                                                      "api_key":NetworkManager.MovieAPIKey])
//        case .anime(let id):
//            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["":id])
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


