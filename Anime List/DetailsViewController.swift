//
//  DetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/9/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var networkManager = NetworkManager()
    
    var selection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        networkManager.getSearchedAnime(name: "Tokyo Ghoul") { (searchedAnime, error) in
//            if let error = error {
//                print(error)
//            }
//
//            if let searchedAnime = searchedAnime {
//                print(searchedAnime)
//            }
//        }
//
        
        print(selection)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
