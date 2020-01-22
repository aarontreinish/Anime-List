//
//  NetworkManager.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {
    static let environment: NetworkEnvironment = .production
    //static let MovieAPIKey = ""
    let router = Router<JikanAPI>()
    
    func getSearchedAnime(name: String, completion: @escaping (_ searchedAnime: [Results]?, _ error: String?) -> ()) {
        router.request(.searchAnime(name: name)) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        // let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        // print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Searched.self, from: responseData)
                        completion(apiResponse.results, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
            
        }
    }
    
    func getSearchedManga(name: String, completion: @escaping (_ searchedAnime: [Results]?, _ error: String?) -> ()) {
        router.request(.searchManga(name: name)) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        // let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        // print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Searched.self, from: responseData)
                        completion(apiResponse.results, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
            
        }
    }

    func getSearchedCharacters(name: String, completion: @escaping (_ searchedAnime: [CharacterResults]?, _ error: String?) -> ()) {
        router.request(.searchCharacter(name: name)) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        // let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        // print(jsonData)
                        let apiResponse = try JSONDecoder().decode(CharacterSearch.self, from: responseData)
                        completion(apiResponse.results, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
            
        }
    }
    
    func getTopRanked(type: String, completion: @escaping (_ topRanked: [TopElement]?, _ error: String?) -> ()) {
        router.request(.topRanked(type: type)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Top.self, from: responseData)
                        completion(apiResponse.top, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getTopFavorties(type: String, completion: @escaping (_ topRanked: [TopElement]?, _ error: String?) -> ()) {
        router.request(.favorites(type: type)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Top.self, from: responseData)
                        completion(apiResponse.top, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getTopUpcoming(type: String, completion: @escaping (_ topUpcoming: [TopElement]?,_ error: String?)->()) {
        router.request(.topUpcoming(type: type)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Top.self, from: responseData)
                        completion(apiResponse.top, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getTopAiring(type: String, completion: @escaping (_ topAiring: [TopElement]?,_ error: String?)->()) {
        router.request(.topAiring(type: type)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Top.self, from: responseData)
                        completion(apiResponse.top, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getMostPopular(type: String, completion: @escaping (_ topRanked: [TopElement]?, _ error: String?) -> ()) {
        router.request(.mostPopular(type: type)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Top.self, from: responseData)
                        completion(apiResponse.top, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getNewAnime(id: Int, completion: @escaping (_ anime: Anime?,_ error: String?)->()){
        router.request(.anime(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Anime.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getNewManga(id: Int, completion: @escaping (_ anime: Manga?,_ error: String?)->()){
        router.request(.manga(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Manga.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getMondaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.monday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getTuesdaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.tuesday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getWednesdaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.wednesday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getThursdaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.thursday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getFridaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.friday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getSaturdaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.saturday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getSundaySchedule(day: String, completion: @escaping (_ topRanked: [Day]?, _ error: String?) -> ()) {
        router.request(.schedule(day: day)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Schedule.self, from: responseData)
                        completion(apiResponse.sunday, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getCharacters(id: Int, completion: @escaping (_ anime: [Characters]?,_ error: String?)->()) {
        router.request(.characters_staff(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Characters_staff.self, from: responseData)
                        completion(apiResponse.characters, nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getMangaCharacters(id: Int, completion: @escaping (_ anime: [Characters]?,_ error: String?)->()) {
        router.request(.mangaCharacters(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Characters_staff.self, from: responseData)
                        completion(apiResponse.characters, nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getRecommendations(id: Int, completion: @escaping (_ anime: [Recommendations_results]?,_ error: String?)->()) {
        router.request(.recommendations(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Recommendations.self, from: responseData)
                        completion(apiResponse.recommendations, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getCharacterDetails(id: Int, completion: @escaping (_ anime: CharacterDetails?,_ error: String?)->()) {
        router.request(.character(id: id)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(CharacterDetails.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        print(response.statusCode)
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
