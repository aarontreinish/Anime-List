//
//  DetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/9/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: CustomImageView!
    
    @IBOutlet weak var staticTypeLabel: UILabel!
    @IBOutlet weak var staticSeasonLabel: UILabel!
    @IBOutlet weak var staticStudioLabel: UILabel!
    @IBOutlet weak var staticEpisodesLabel: UILabel!
    @IBOutlet weak var staticGenreLabel: UILabel!
    @IBOutlet weak var staticScoreLabel: UILabel!
    @IBOutlet weak var staticRankLabel: UILabel!
    
    
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var episodesLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    @IBOutlet weak var desctiptionTextView: UITextView!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var selection = 0
    var networkManager = NetworkManager()
    
    var animeDetailsArray: Anime?
    var animeGenresArray: [Genres] = []
    var animeStudiosArray: [Studios] = []
    
    var allStudios = ""
    var allGenres = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        hideUI()
        imageView.layer.cornerRadius = 10.0
        setupActivityIndicator()
        getAnimeDetails()
    }
    
    func hideUI() {
        staticRankLabel.isHidden = true
        staticTypeLabel.isHidden = true
        staticGenreLabel.isHidden = true
        staticScoreLabel.isHidden = true
        staticSeasonLabel.isHidden = true
        staticStudioLabel.isHidden = true
        staticEpisodesLabel.isHidden = true
        imageView.isHidden = true
        studioLabel.isHidden = true
        typeLabel.isHidden = true
        episodesLabel.isHidden = true
        genreLabel.isHidden = true
        seasonLabel.isHidden = true
        scoreLabel.isHidden = true
        rankLabel.isHidden = true
        desctiptionTextView.isHidden = true
    }
    
    func showUI() {
        staticRankLabel.isHidden = false
        staticTypeLabel.isHidden = false
        staticGenreLabel.isHidden = false
        staticScoreLabel.isHidden = false
        staticSeasonLabel.isHidden = false
        staticStudioLabel.isHidden = false
        staticEpisodesLabel.isHidden = false
        imageView.isHidden = false
        studioLabel.isHidden = false
        typeLabel.isHidden = false
        episodesLabel.isHidden = false
        genreLabel.isHidden = false
        seasonLabel.isHidden = false
        scoreLabel.isHidden = false
        rankLabel.isHidden = false
        desctiptionTextView.isHidden = false
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
    }
    
    func getAnimeDetails() {
        
        networkManager.getNewAnimeGenres(id: selection) { (genres, error) in
            if let error = error {
                print(error)
            }
            
            if let genres = genres {
                self.animeGenresArray = genres
            }
            
            self.animeGenresArray.forEach { (genres) in
                self.allGenres.append(contentsOf: genres.name ?? "")
                print(self.allGenres)
            }
        }
        
        networkManager.getNewAnimeStudios(id: selection) { (studios, error) in
            if let error = error {
                print(error)
            }
            if let studios = studios {
                self.animeStudiosArray = studios
            }
            
            self.animeStudiosArray.forEach { (studios) in
                self.allStudios.append(contentsOf: studios.name ?? "")
            }
        }
        
        networkManager.getNewAnime(id: selection) { (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                self.animeDetailsArray = anime
                //print(self.animeDetailsArray ?? "")
            }
            
            let episodes = String(self.animeDetailsArray?.episodes ?? 0)
            let rank = String(self.animeDetailsArray?.rank ?? 0)
            let score = String(self.animeDetailsArray?.score ?? 0)
            
            DispatchQueue.main.async {
                self.title = self.animeDetailsArray?.title
                self.imageView.loadImageUsingCacheWithUrlString(urlString: self.animeDetailsArray?.image_url ?? "")
                self.episodesLabel.text = episodes
                self.desctiptionTextView.text = self.animeDetailsArray?.synopsis
                self.rankLabel.text = rank
                self.scoreLabel.text = score
                self.studioLabel.text = self.allStudios
                self.genreLabel.text = self.allGenres
                self.typeLabel.text = self.animeDetailsArray?.type
                self.seasonLabel.text = self.animeDetailsArray?.premiered
                
                self.activityIndicator.stopAnimating()
                self.showUI()
            }
        }
    }
}
