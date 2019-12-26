//
//  Schedule.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/23/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation
struct Schedule : Codable {
    let request_hash : String?
    let request_cached : Bool?
    let request_cache_expiry : Int?
    let monday, tuesday, wednesday, thursday, friday, saturday, sunday : [Day]?
//    let tuesday : [Tuesday]?
//    let wednesday : [Wednesday]?
//    let thursday : [Thursday]?
//    let friday : [Friday]?
//    let saturday : [Saturday]?
//    let sunday : [Sunday]?
//    let other : [Other]?
//    let unknown : [Unknown]?
}
