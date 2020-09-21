//
//  AnimeWidget.swift
//  Anime List
//
//  Created by Aaron Treinish on 9/15/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct AnimeWidget: Identifiable, Codable {
    var image_url: String
    var name: String
    var mal_id: Int
    var sentToCloud: Int
    
    var id: Int { mal_id }
}
