//
//  Prop.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import Foundation

struct Prop : Codable {
    let from : From?
    let to : To?

    enum CodingKeys: String, CodingKey {

        case from = "from"
        case to = "to"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        from = try values.decodeIfPresent(From.self, forKey: .from)
        to = try values.decodeIfPresent(To.self, forKey: .to)
    }

}
