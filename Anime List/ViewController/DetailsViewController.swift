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
        
        callFunctions()
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

        group.enter()
        self.getAnimeDetails()
        group.leave()
    
        group.enter()
        self.getAnimeCharacters()
        group.leave()
        
//        group.enter()
//        self.getAnimeRecommendations()
//        group.leave()
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    func checkIfDataIsAllThere() {
        if animeDetailsArray == nil || animeCharactersArray.isEmpty {
            allGenresArray.removeAll()
            allStudiosArray.removeAll()
            getAllData()
        }
    }
    
    func callFunctions() {
        let group = DispatchGroup()
        
        group.enter()
        getAllData()
        group.leave()
        
        group.enter()
        let deadlineTime = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkIfDataIsAllThere()
        }
        group.leave()
        
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
    
    }
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        return animeCharactersArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
        
        let characters: Characters
        
        characters = animeCharactersArray[indexPath.row]
        charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
        charactersCell.label.text = characters.name
        
        return charactersCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let characters: Characters
        characters = animeCharactersArray[indexPath.row]
        selection = characters.mal_id ?? 0
        
        self.performSegue(withIdentifier: "animeDetailsCharacterSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "animeDetailsCharacterSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
    }
}
