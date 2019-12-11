//
//  JikanEndPoint.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum JikanAPI {
//    case recommended(id:Int)
//    case popular(page:Int)
//    case newMovies(page:Int)
//    case video(id:Int)
    //https://api.jikan.moe/v3/top/anime/1/bypopularity
    case topAiring
    case mostPopular
    case anime(id: Int)
    case searchAnime(name: String)
    case topRanked
    case topUpcoming
}

extension JikanAPI: EndPointType {
    
    var environmentBaseURL : String {
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
        case .topAiring:
            return "/top/anime/1/airing"
        case .anime(let id):
            return "/anime/\(id)"
        case .searchAnime:
            return "/search/anime"
        case .topRanked:
            return "/top/anime/"
        case .topUpcoming:
            return "/top/anime/1/upcoming"
        case .mostPopular:
            return "/top/anime/1/bypopularity"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .searchAnime(let name):
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


