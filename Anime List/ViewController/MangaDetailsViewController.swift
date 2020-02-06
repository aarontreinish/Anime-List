//
//  MangaDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/23/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MangaDetailsViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var volumesLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var recommendationsCollectionView: UICollectionView!
    
    let activityIndicator = UIActivityIndicatorView()
        //UIActivityIndicatorView(style: .large)
    
    var selection = 0
    var networkManager = NetworkManager()
    
    var mangaDetailsArray: Manga?
    var mangaCharactersArray: [Characters] = []
    var mangaRecommendationsArray: [Recommendations_results] = []
    var mangaAdaptationsArray: [Adaptation] = []
    
    var allAuthors = ""
    var allGenres = ""
    var allGenresArray: [String] = []
    var allAuthorsArray: [String] = []
    
    var volumesString = ""
    var rankString = ""
    var scoreString = ""
    var chaptersString = ""
    
    var screenWillShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        
        recommendationsCollectionView.dataSource = self
        recommendationsCollectionView.delegate = self
        
        callFunctions()
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
        
    }
    
    func getMangaDetails() {
        networkManager.getNewManga(id: selection) { [weak self] (manga, error) in
            if let error = error {
                print(error)
            }
            if let manga = manga {
                self?.mangaDetailsArray = manga
            }
            
            self?.screenWillShow = true
            self?.setUpData()
            
            DispatchQueue.main.async {
                self?.setLabels()
            }
        }
    }
    
    func setUpData() {
        volumesString = String(mangaDetailsArray?.volumes ?? 0)
        rankString = String(mangaDetailsArray?.rank ?? 0)
        scoreString = String(mangaDetailsArray?.score ?? 0)
        chaptersString = String(mangaDetailsArray?.chapters ?? 0)
        
        for studios in mangaDetailsArray?.authors ?? [] {
            allAuthorsArray.append(studios.name ?? "")
        }
        allAuthors = allAuthorsArray.joined(separator: ", ")
        
        for genres in mangaDetailsArray?.genres ?? [] {
            allGenresArray.append(genres.name ?? "")
        }
        allGenres = allGenresArray.joined(separator: ", ")
        
        for adaptations in mangaDetailsArray?.related?.adaptation ?? [] {
            mangaAdaptationsArray.append(adaptations)
        }
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
                self?.charactersCollectionView.reloadData()
            }
        }
    }
    
    func getMangaRecommendations() {
        networkManager.getMangaRecommendations(id: selection) { [weak self] (recommendations, error) in
            if let error = error {
                print(error)
            }
            if let recommendations = recommendations {
                self?.mangaRecommendationsArray = recommendations
            }
            
            DispatchQueue.main.async {
                self?.recommendationsCollectionView.reloadData()
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
        
        group.enter()
        self.getMangaRecommendations()
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
        titleLabel.text = mangaDetailsArray?.title
        imageView.loadImageUsingCacheWithUrlString(urlString: mangaDetailsArray?.image_url ?? "")
        descriptionLabel.text = mangaDetailsArray?.synopsis
        chaptersLabel.text = chaptersString
        rankLabel.text = rankString
        authorLabel.text = allAuthors
        volumesLabel.text = volumesString
        typeLabel.text = mangaDetailsArray?.type
        genreLabel.text = allGenres
        scoreLabel.text = scoreString
    }
    
    func checkIfDataIsAllThere() {
        if mangaDetailsArray == nil || mangaCharactersArray.isEmpty || mangaRecommendationsArray.isEmpty {
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
        let deadlineTime = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkIfDataIsAllThere()
            self.activityIndicator.stopAnimating()
            self.mainView.isHidden = false
        }
        group.leave()
        
    }
    
}

extension MangaDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            return mangaCharactersArray.count
        } else if collectionView == recommendationsCollectionView {
            return mangaRecommendationsArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == recommendationsCollectionView {
            let recommendationsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "adaptationsCell", for: indexPath) as! RecommendationsCollectionViewCell
            
            let recommendations: Recommendations_results
            
            recommendations = mangaRecommendationsArray[indexPath.row]
            recommendationsCell.imageView.loadImageUsingCacheWithUrlString(urlString: recommendations.image_url ?? "")
            recommendationsCell.label.text = recommendations.title
            
            return recommendationsCell
        }
        
        
        let charactersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "charactersCell", for: indexPath) as! CharactersCollectionViewCell
        
        let characters: Characters
        
        characters = mangaCharactersArray[indexPath.row]
        charactersCell.imageView.loadImageUsingCacheWithUrlString(urlString: characters.image_url ?? "")
        charactersCell.label.text = characters.name
        
        return charactersCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == charactersCollectionView {
            let characters: Characters
            characters = mangaCharactersArray[indexPath.row]
            selection = characters.mal_id ?? 0
            
            self.performSegue(withIdentifier: "mangaDetailsCharacterSegue", sender: self)
            
        } else if collectionView == recommendationsCollectionView {
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MangaDetailsViewController") as! MangaDetailsViewController
            
            let recommendations: Recommendations_results
            recommendations = mangaRecommendationsArray[indexPath.row]
    
            viewController.selection = recommendations.mal_id ?? 0
            self.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mangaDetailsCharacterSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
    }
    
}
