//
//  DetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/9/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var selection = 0
    var networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(selection)
        
        getAnimeDetails()
    }
    
    func getAnimeDetails() {
        networkManager.getNewAnime(id: selection) { (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                print(anime)
            }
        }
    }
}
