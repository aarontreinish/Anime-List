//
//  MangaDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MangaDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var selection = 0
    var networkManager = NetworkManager()
    
    var mangaDetailsArray: Manga?
    var mangaCharactersArray: [Characters] = []
    var mangaRecommendationsArray: [Recommendations_results] = []
    
    var allAuthors = ""
    var allGenres = ""
    var allGenresArray: [String] = []
    var allAuthorsArray: [String] = []
    
    var volumesString = ""
    var rankString = ""
    var scoreString = ""
    var chaptersString = ""
    
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
    
    func getMangaDetails() {
        
        networkManager.getNewManga(id: selection) { [weak self] (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                self?.mangaDetailsArray = anime
            }
            
            self?.screenWillShow = true
            self?.setUpData()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func setUpData() {
        volumesString = String(mangaDetailsArray?.volumes ?? 0)
        rankString = String(mangaDetailsArray?.rank ?? 0)
        scoreString = String(mangaDetailsArray?.score ?? 0)
        chaptersString = String(mangaDetailsArray?.chapters ?? 0)
        
        for authors in mangaDetailsArray?.authors ?? [] {
            allAuthorsArray.append(authors.name ?? "")
        }
        allAuthors = allAuthorsArray.joined(separator: ", ")
        
        for genres in self.mangaDetailsArray?.genres ?? [] {
            allGenresArray.append(genres.name ?? "")
        }
        allGenres = allGenresArray.joined(separator: ", ")
    }
    
    func getMangaCharacters() {
        networkManager.getMangaCharacters(id: selection) { [weak self] (characters, error) in
            if let error = error {
                print(error)
            }
            if let characters = characters {
                self?.mangaCharactersArray = characters
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
                self?.mangaRecommendationsArray = recommendations
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getAllData() {
        let group = DispatchGroup()
        
        group.enter()
        self.getMangaDetails()
        group.leave()
        
        group.enter()
        self.getMangaCharacters()
        group.leave()
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
            //self.activityIndicator.stopAnimating()
            // self.tableView.isHidden = false
        }
    }
    
    func checkIfDataIsAllThere() {
        if mangaDetailsArray == nil || mangaCharactersArray.isEmpty {
            allGenresArray.removeAll()
            allAuthorsArray.removeAll()
            getAllData()
        }
    }
    
    func callFunctions() {
        let group = DispatchGroup()
        
        group.enter()
        getAllData()
        group.leave()
        
        group.enter()
        let deadlineTime = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkIfDataIsAllThere()
        }
        group.leave()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mangaDetailsCell") as? MangaDetailsTableViewCell else { return UITableViewCell() }
        
        if self.allGenres != "" && self.allAuthors != "" {
            
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            
            cell.detailsImageView.loadImageUsingCacheWithUrlString(urlString: mangaDetailsArray?.image_url ?? "")
            cell.titleLabel.text = mangaDetailsArray?.title
            cell.descriptionLabel.text = mangaDetailsArray?.synopsis
            cell.typeLabel.text = mangaDetailsArray?.type
            cell.chaptersLabel.text = chaptersString
            cell.volumesLabel.text = volumesString
            cell.rankLabel.text = rankString
            cell.scoreLabel.text = scoreString
            cell.authorLabel.text = allAuthors
            cell.genreLabel.text = allGenres
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let mangaDetailsTableViewCell = cell as? MangaDetailsTableViewCell else { return }
        
        mangaDetailsTableViewCell.setCharactersCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
    }
}

extension MangaDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        return mangaCharactersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
        
        let characters: Characters
        
        characters = mangaCharactersArray[indexPath.row]
        charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
        charactersCell.label.text = characters.name
        
        return charactersCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let characters: Characters
        characters = mangaCharactersArray[indexPath.row]
        selection = characters.mal_id ?? 0
        
        self.performSegue(withIdentifier: "mangaDetailsCharacterSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mangaDetailsCharacterSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
    }
}
