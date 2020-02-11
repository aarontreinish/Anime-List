//
//  Published_Manga.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/11/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

struct Published_Manga : Codable {
    let position : String?
    let manga : VoiceActorsManga?

    enum CodingKeys: String, CodingKey {

        case position = "position"
        case manga = "manga"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        position = try values.decodeIfPresent(String.self, forKey: .position)
        manga = try values.decodeIfPresent(VoiceActorsManga.self, forKey: .manga)
    }

}
