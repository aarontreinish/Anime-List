//
//  DetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/9/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var selection = 0
    var networkManager = NetworkManager()
    
    var animeDetailsArray: Anime?
    var animeGenresArray: [Genres] = []
    var animeStudiosArray: [Studios] = []
    var animeCharactersArray: [Characters] = []
    var animeRecommendationsArray: [Recommendations_results] = []
    
    var allStudios = ""
    var allGenres = ""
    var allGenresArray: [String] = []
    var allStudiosArray: [String] = []
    
    var episodesString = ""
    var rankString = ""
    var scoreString = ""
    
    var screenWillShow = false
    
    private enum Section: Int {
        case characters
        case recommendations
        
        static var numberOfSections: Int { return 2 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        setupActivityIndicator()
    
        if screenWillShow == false {
            tableView.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        screenWillShow = false
        
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
    }
    
    func getGenres() {
        networkManager.getNewAnimeGenres(id: selection) { (genres, error) in
            if let error = error {
                print(error)
            }
            
            if let genres = genres {
                self.animeGenresArray = genres
            }
            
            self.allGenresArray = self.animeGenresArray.map { ($0.name ?? "") }
            self.allGenres = self.allGenresArray.joined(separator: ", ")
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getStudios() {
        networkManager.getNewAnimeStudios(id: selection) { (studios, error) in
            if let error = error {
                print(error)
            }
            if let studios = studios {
                self.animeStudiosArray = studios
            }
            
            self.allStudiosArray = self.animeStudiosArray.map { ($0.name ?? "") }
            self.allStudios = self.allStudiosArray.joined(separator: ", ")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getAnimeDetails() {
        
        networkManager.getNewAnime(id: selection) { (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                self.animeDetailsArray = anime
            }
            
            self.screenWillShow = true
            
            self.episodesString = String(self.animeDetailsArray?.episodes ?? 0)
            self.rankString = String(self.animeDetailsArray?.rank ?? 0)
            self.scoreString = String(self.animeDetailsArray?.score ?? 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
               // self.title = self.animeDetailsArray?.title
            }
        }
    }
    
    func getAnimeCharacters() {
        networkManager.getCharacters(id: selection) { [weak self] (characters, error) in
            if let error = error {
                print(error)
            }
            if let characters = characters {
                self?.animeCharactersArray = characters
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getAnimeRecommendations() {
        networkManager.getRecommendations(id: selection) { [weak self] (recommendations, error) in
            if let error = error {
                print(error)
            }
            if let recommendations = recommendations {
                self?.animeRecommendationsArray = recommendations
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getAllData() {
        let group = DispatchGroup()
        
        group.enter()
        getAnimeRecommendations()
        group.leave()
        
        group.enter()
        getAnimeCharacters()
        group.leave()
        
        group.enter()
        getGenres()
        group.leave()
        
        group.enter()
        getStudios()
        group.leave()
        
        group.enter()
        getAnimeDetails()
        group.leave()
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
            //self.activityIndicator.stopAnimating()
           // self.tableView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell1") as? DetailsTableViewCell else { return UITableViewCell() }
            
            if self.allGenres != "" && self.allStudios != "" {
                
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                
                cell.loadYoutube(url: animeDetailsArray?.trailer_url ?? "")
                cell.detailsImageView.loadImageUsingCacheWithUrlString(urlString: animeDetailsArray?.image_url ?? "")
                cell.titleLabel.text = animeDetailsArray?.title
                cell.descriptionLabel.text = animeDetailsArray?.synopsis
                cell.typeLabel.text = animeDetailsArray?.type
                cell.seasonLabel.text = animeDetailsArray?.premiered
                cell.episodesLabel.text = episodesString
                cell.rankLabel.text = rankString
                cell.scoreLabel.text = scoreString
                cell.studioLabel.text = allStudios
                cell.genreLabel.text = allGenres
            }
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell2") as? DetailsTableViewCell else { return UITableViewCell() }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let detailsTableViewCell = cell as? DetailsTableViewCell else { return }
        
        detailsTableViewCell.setCharactersCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        detailsTableViewCell.setRecommendationsCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        
    }
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        
        if collectionView.tag == 1 {
            return animeRecommendationsArray.count
        }
        return animeCharactersArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
        
        let characters: Characters
        
        characters = animeCharactersArray[indexPath.row]
        charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
        charactersCell.label.text = characters.name
        
        if collectionView.tag == 1 {
            let recommendationsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendationsCell", for: indexPath) as! RecommendationsCollectionViewCell
            
            let recommendations: Recommendations_results
            
            recommendations = animeRecommendationsArray[indexPath.row]
            recommendationsCell.imageView.loadImageUsingCacheWithUrlString(urlString: recommendations.image_url ?? "")
            recommendationsCell.label.text = recommendations.title
            
            return recommendationsCell
        }
        
        return charactersCell
    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as? HomeTableViewCell
//
//        cell?.collectionView.tag = indexPath.row
//
//        let topElement: TopElement
//
//        switch Section(rawValue: collectionView.tag) {
//        case .topAiringAnime:
//            topElement = topAiringArray[indexPath.row]
//            selection = topElement.mal_id ?? 0
//            self.performSegue(withIdentifier: "detailsSegue", sender: self)
//        case .topRankedAnime:
//            topElement = topRankedArray[indexPath.row]
//            selection = topElement.mal_id ?? 0
//            self.performSegue(withIdentifier: "detailsSegue", sender: self)
//        case .mostPopularAnime:
//            topElement = mostPopularArray[indexPath.row]
//            selection = topElement.mal_id ?? 0
//            self.performSegue(withIdentifier: "detailsSegue", sender: self)
//        case .topUpcomingAnime:
//            topElement = topUpcomingArray[indexPath.row]
//            selection = topElement.mal_id ?? 0
//            self.performSegue(withIdentifier: "detailsSegue", sender: self)
//        case .none:
//            selection = 0
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "detailsSegue" {
//            let detailsViewController = segue.destination as? DetailsViewController
//
//            detailsViewController?.selection = selection
//        }
//    }
}
