//
//  Aired.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Aired : Codable {
    let from : String?
    let to : String?
    let prop : Prop?
    let string : String?

    enum CodingKeys: String, CodingKey {

        case from = "from"
        case to = "to"
        case prop = "prop"
        case string = "string"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        from = try values.decodeIfPresent(String.self, forKey: .from)
        to = try values.decodeIfPresent(String.self, forKey: .to)
        prop = try values.decodeIfPresent(Prop.self, forKey: .prop)
        string = try values.decodeIfPresent(String.self, forKey: .string)
    }

}
