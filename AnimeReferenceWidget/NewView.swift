//
//  NewView.swift
//  Anime List
//
//  Created by Aaron Treinish on 9/15/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import SwiftUI

struct NewView: View {
    @Environment(\.imageCache) var cache: ImageCache
    
    let anime = [
        AnimeWidget(image_url: "https://cdn.myanimelist.net//images//anime//1223//96541.jpg?s=faffcb677a5eacd17bf761edd78bfb3f", name: "Fullmetal Alchemist: Brotherhood", mal_id: 5114, sentToCloud: 1),
        AnimeWidget(image_url: "https://cdn.myanimelist.net//images//anime//5//73199.jpg?s=97b97d568f25a02cf5a22dda13b5371f", name: "Steins;Gate", mal_id: 9253, sentToCloud: 1),
        AnimeWidget(image_url: "https://cdn.myanimelist.net//images//anime//11//33657.jpg?s=5724d8c22ae7a1dad72d8f4229ef803f", name: "Hunter x Hunter (2011)", mal_id: 11061, sentToCloud: 1)
    ]
    
    let animeURL = ["https://cdn.myanimelist.net//images//anime//1223//96541.jpg?s=faffcb677a5eacd17bf761edd78bfb3f", "https://cdn.myanimelist.net//images//anime//5//73199.jpg?s=97b97d568f25a02cf5a22dda13b5371f", "https://cdn.myanimelist.net//images//anime//11//33657.jpg?s=5724d8c22ae7a1dad72d8f4229ef803f"].map { URL(string: $0)! }
    
    var body: some View {
        List(animeURL, id: \.self) { url in
            AsyncImage(
                url: url,
                cache: self.cache,
                placeholder: Text("Loading ..."),
                configuration: { $0.resizable() }
            )
            .frame(idealHeight: UIScreen.main.bounds.width / 2 * 3) // 2:3 aspect ratio
        }
    }
}

struct NewView_Previews: PreviewProvider {
    static var previews: some View {
        NewView()
    }
}
