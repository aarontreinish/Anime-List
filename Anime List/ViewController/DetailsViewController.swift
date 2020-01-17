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

    func getAnimeDetails() {
        
        networkManager.getNewAnime(id: selection) { [weak self] (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                self?.animeDetailsArray = anime
            }
            
            self?.screenWillShow = true
            self?.setUpData()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func setUpData() {
        episodesString = String(animeDetailsArray?.episodes ?? 0)
        rankString = String(animeDetailsArray?.rank ?? 0)
        scoreString = String(animeDetailsArray?.score ?? 0)
        
        for studios in animeDetailsArray?.studios ?? [] {
            allStudiosArray.append(studios.name ?? "")
        }
        allStudios = allStudiosArray.joined(separator: ", ")
        
        for genres in self.animeDetailsArray?.genres ?? [] {
            allGenresArray.append(genres.name ?? "")
        }
        allGenres = allGenresArray.joined(separator: ", ")
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
        
        let deadlineTime = DispatchTime.now() + 2.0
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            group.enter()
            self.getAnimeRecommendations()
            group.leave()
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            group.enter()
            self.getAnimeCharacters()
            group.leave()
        }
    
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            group.enter()
            self.getAnimeDetails()
            group.leave()
        }
        
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell1") as? DetailsTableViewCell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let detailsTableViewCell = cell as? DetailsTableViewCell else { return }
        
        detailsTableViewCell.setCharactersCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        //detailsTableViewCell.setRecommendationsCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
        
    }
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: collectionView.bounds.width / 2.2, height: collectionView.bounds.height)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 132.0, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return (section == 0) ? animeCharactersArray.count : animeRecommendationsArray.count
        
        let detailsTableViewCell = DetailsTableViewCell()
        
        if collectionView == detailsTableViewCell.recommendationsCollectionView {
            return animeRecommendationsArray.count
        } else {
            return animeCharactersArray.count
        }
        
//        if collectionView.tag == 50 {
//            return animeRecommendationsArray.count
//        } else {
//            return animeCharactersArray.count
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let detailsTableViewCell = DetailsTableViewCell()
        
        if collectionView == detailsTableViewCell.recommendationsCollectionView {
            let recommendationsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendationsCell", for: indexPath) as! RecommendationsCollectionViewCell
            
            let recommendations: Recommendations_results
            
            recommendations = animeRecommendationsArray[indexPath.row]
            recommendationsCell.imageView.loadImageUsingCacheWithUrlString(urlString: recommendations.image_url ?? "")
            recommendationsCell.label.text = recommendations.title
            
            return recommendationsCell
        } else {
            
            let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
            
            let characters: Characters
            
            characters = animeCharactersArray[indexPath.row]
            charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
            charactersCell.label.text = characters.name
            
            return charactersCell
        }
    
    }
}
