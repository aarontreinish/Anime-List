//
//  DetailViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/23/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainImageView: CustomImageView!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var episodesLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var trailerWebView: WKWebView!
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var recommendationsCollectionView: UICollectionView!
    
    let activityIndicator = UIActivityIndicatorView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        
        recommendationsCollectionView.dataSource = self
        recommendationsCollectionView.delegate = self
        
        callFunctions()
        
        //getAllData()
        //fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        setupActivityIndicator()
        
        if screenWillShow == false {
            mainView.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            activityIndicator.color = UIColor.black
        }
        
    }
    
    func getAnimeDetails() {
        networkManager.getNewAnime(id: selection) { [weak self] (anime, error) in
            if let error = error {
                print(error)
            }
            if let anime = anime {
                self?.animeDetailsArray = anime
            }
            
            self?.setUpData()
            
            self?.screenWillShow = true
            
            DispatchQueue.main.async {
                self?.setLabels()
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
                self?.charactersCollectionView.reloadData()
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
                self?.recommendationsCollectionView.reloadData()
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
        
        group.enter()
        self.getAnimeRecommendations()
        group.leave()
        
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//            self.mainView.isHidden = false
//        }
        group.notify(queue: .main) {
            self.charactersCollectionView.reloadData()
            self.recommendationsCollectionView.reloadData()
        }
        
    }
    
    func setLabels() {
        self.navigationItem.title = animeDetailsArray?.title
        mainImageView.loadImageUsingCacheWithUrlString(urlString: animeDetailsArray?.image_url ?? "")
        descriptionLabel.text = animeDetailsArray?.synopsis
        seasonLabel.text = animeDetailsArray?.premiered
        rankLabel.text = rankString
        studioLabel.text = allStudios
        episodesLabel.text = episodesString
        typeLabel.text = animeDetailsArray?.type
        genreLabel.text = allGenres
        scoreLabel.text = scoreString
        loadYoutube(url: animeDetailsArray?.trailer_url ?? "")
    }
    
    func checkIfDataIsAllThere() {
        if animeDetailsArray == nil || animeCharactersArray.isEmpty || animeRecommendationsArray.isEmpty {
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
            self.activityIndicator.stopAnimating()
            self.mainView.isHidden = false
        }
        group.leave()
        
    }
    
    func loadYoutube(url: String) {
        guard let youtubeURL = URL(string: url) else { return }
        trailerWebView.load(URLRequest(url: youtubeURL))
    }
    
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        
        if collectionView == charactersCollectionView {
            return animeCharactersArray.count
        } else if collectionView == recommendationsCollectionView {
            return animeRecommendationsArray.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == recommendationsCollectionView {
            let recommendationsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendationsCell", for: indexPath) as! RecommendationsCollectionViewCell
            
            let recommendations: Recommendations_results
            
            recommendations = animeRecommendationsArray[indexPath.row]
            recommendationsCell.imageView.loadImageUsingCacheWithUrlString(urlString: recommendations.image_url ?? "")
            recommendationsCell.label.text = recommendations.title
            
            return recommendationsCell
        }
        
        
        let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
        
        let characters: Characters
        
        characters = animeCharactersArray[indexPath.row]
        charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
        charactersCell.label.text = characters.name
        
        return charactersCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == charactersCollectionView {
            let characters: Characters
            characters = animeCharactersArray[indexPath.row]
            selection = characters.mal_id ?? 0
            
            self.performSegue(withIdentifier: "animeDetailsCharacterSegue", sender: self)
            
        } else if collectionView == recommendationsCollectionView {
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            
            let recommendations: Recommendations_results
            recommendations = animeRecommendationsArray[indexPath.row]
            
            viewController.selection = recommendations.mal_id ?? 0
            self.show(viewController, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "animeDetailsCharacterSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
    }
    
}
