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
    
    var allStudios = ""
    var allGenres = ""
    var allGenresArray: [String] = []
    var allStudiosArray: [String] = []
    
    var episodesString = ""
    var rankString = ""
    var scoreString = ""
    
    var screenWillShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator.startAnimating()
        getAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.isHidden = true
        
        setupActivityIndicator()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeData()
        
        screenWillShow = false
    }
    
    func removeData() {
        allGenresArray.removeAll()
        animeGenresArray.removeAll()
        allGenres.removeAll()
        
        animeStudiosArray.removeAll()
        allStudios.removeAll()
        allStudiosArray.removeAll()
        
        animeDetailsArray = nil
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
            
            self.episodesString = String(self.animeDetailsArray?.episodes ?? 0)
            self.rankString = String(self.animeDetailsArray?.rank ?? 0)
            self.scoreString = String(self.animeDetailsArray?.score ?? 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getAllData() {
        getGenres()
        getStudios()
        getAnimeDetails()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            //self.title = self.animeDetailsArray?.title
            self.tableView.isHidden = false
        }
        
        self.screenWillShow = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell1") as? DetailsTableViewCell else { return UITableViewCell() }
            
            if self.allGenres != "" && self.allStudios != "" {
                cell.detailsImageView.loadImageUsingCacheWithUrlString(urlString: animeDetailsArray?.image_url ?? "")
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
            
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell2") as? DetailsTableViewCell else { return UITableViewCell() }
            
            return cell
        
        } else {
            guard let cell2 = tableView.dequeueReusableCell(withIdentifier: "detailsCell2") as? DetailsTableViewCell else { return UITableViewCell() }
            
            return cell2
        }
    }
}
