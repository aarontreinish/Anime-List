//
//  VoiceActingRoles.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/24/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Voice_acting_roles : Codable {
    let role : String?
    let anime : VoiceActorsAnime?
    let character : VoiceActorsCharacters?

    enum CodingKeys: String, CodingKey {

        case role = "role"
        case anime = "anime"
        case character = "character"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        anime = try values.decodeIfPresent(VoiceActorsAnime.self, forKey: .anime)
        character = try values.decodeIfPresent(VoiceActorsCharacters.self, forKey: .character)
    }

}
