//
//  MangaDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/23/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MangaDetailsViewController: UIViewController {
    
    let persistenceManager = PersistanceManager()
    var savedManga = [SavedManga]()
    var isAlreadySaved: Bool = false
    var didSave: Bool = false
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var genreTitleLabel: UILabel!
    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var chaptersTitleLabel: UILabel!
    @IBOutlet weak var volumesTitleLabel: UILabel!
    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var volumesLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var japaneseLabel: UILabel!
    @IBOutlet weak var publishedPublishingLabel: UILabel!
    @IBOutlet weak var publishedPublishingTitleLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var recommendationsCollectionView: UICollectionView!
    
    let activityIndicator = UIActivityIndicatorView()
    
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
        
        checkDevice()
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
        
        checkIfAlreadySaved()
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
    
    func checkDevice() {
        let modelName = UIDevice.modelName
        
        if modelName == "Simulator iPhone SE (2nd generation)" || modelName == "iPhone SE (2nd generation)" {
            chaptersLabel.font = chaptersLabel.font.withSize(12)
            chaptersTitleLabel.font = chaptersTitleLabel.font.withSize(12)
            typeLabel.font = typeLabel.font.withSize(12)
            typeTitleLabel.font = typeTitleLabel.font.withSize(12)
            rankLabel.font = rankLabel.font.withSize(12)
            rankTitleLabel.font = rankTitleLabel.font.withSize(12)
            genreTitleLabel.font = genreTitleLabel.font.withSize(12)
            genreLabel.font = genreLabel.font.withSize(12)
            volumesLabel.font = volumesLabel.font.withSize(12)
            volumesTitleLabel.font = volumesTitleLabel.font.withSize(12)
            authorLabel.font = authorLabel.font.withSize(12)
            authorTitleLabel.font = authorTitleLabel.font.withSize(12)
            scoreLabel.font = scoreLabel.font.withSize(12)
            scoreTitleLabel.font = scoreTitleLabel.font.withSize(12)
            
        }
        
        print(modelName)
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
    
    func getAllData() {
        let group = DispatchGroup()
        
        if mangaDetailsArray == nil {
            group.enter()
            networkManager.getNewManga(id: selection) { [weak self] (manga, error) in
                if let error = error {
                    print(error)
                }
                if let manga = manga {
                    self?.mangaDetailsArray = manga
                    self?.screenWillShow = true
                    self?.setUpData()
                    
                    DispatchQueue.main.async {
                        self?.setLabels()
                    }
                    group.leave()
                }
            }
        }
        
        if mangaCharactersArray.isEmpty {
            group.enter()
            networkManager.getMangaCharacters(id: selection) { [weak self] (characters, error) in
                if let error = error {
                    print(error)
                }
                if let characters = characters {
                    self?.mangaCharactersArray = characters
                    
                    DispatchQueue.main.async {
                        self?.charactersCollectionView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        if mangaRecommendationsArray.isEmpty {
            group.enter()
            networkManager.getMangaRecommendations(id: selection) { [weak self] (recommendations, error) in
                if let error = error {
                    print(error)
                }
                if let recommendations = recommendations {
                    self?.mangaRecommendationsArray = recommendations
                    
                    DispatchQueue.main.async {
                        self?.recommendationsCollectionView.reloadData()
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            self.charactersCollectionView.reloadData()
            self.recommendationsCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
            self.mainView.isHidden = false
        }
    }
    
    func setLabels() {
        self.navigationItem.title = mangaDetailsArray?.title
        imageView.loadImageUsingCacheWithUrlString(urlString: mangaDetailsArray?.image_url ?? "")
        descriptionLabel.text = mangaDetailsArray?.synopsis
        chaptersLabel.text = chaptersString
        rankLabel.text = rankString
        authorLabel.text = allAuthors
        volumesLabel.text = volumesString
        typeLabel.text = mangaDetailsArray?.type
        genreLabel.text = allGenres
        scoreLabel.text = scoreString
        
        japaneseLabel.text = mangaDetailsArray?.title_japanese ?? ""
        englishLabel.text = mangaDetailsArray?.title_english ?? ""
        
        if mangaDetailsArray?.publishing == true {
            publishedPublishingTitleLabel.text = "PUBLISHING"
            
            publishedPublishingLabel.text = "\(mangaDetailsArray?.published?.string ?? "")"
            
        } else if mangaDetailsArray?.publishing == false {
            publishedPublishingTitleLabel.text = "AIRED"
            
            publishedPublishingLabel.text = "\(mangaDetailsArray?.published?.string ?? "")"
        }
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
        let deadlineTime = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkIfDataIsAllThere()
        }
        group.leave()
        
    }
    
    func saveManga() {
           let malId = Float(mangaDetailsArray?.mal_id ?? 0)
           
           let savedManga = SavedManga(context: persistenceManager.context)
           savedManga.mal_id = malId
           savedManga.image_url = mangaDetailsArray?.image_url
           savedManga.name = mangaDetailsArray?.title
           
           persistenceManager.save()
       }
       
       func deleteManga() {
           persistenceManager.delete(SavedManga.self, malId: Float(selection))
       }
       
       func getSavedManga() {
           let savedManga = persistenceManager.fetch(SavedManga.self)
           self.savedManga = savedManga
           
       }
       
       func checkIfAlreadySaved() {
           
           isAlreadySaved = persistenceManager.checkIfExists(SavedManga.self, malId: Float(selection), attributeName: "mal_id")
           
           if isAlreadySaved == true {
               if #available(iOS 13.0, *) {
                   navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
                didSave = true
               } else {
                   // Fallback on earlier versions
               }
           }
       }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        if didSave == true {
            deleteManga()
            didSave = false
            if #available(iOS 13.0, *) {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            } else {
                // Fallback on earlier versions
            }
        } else if didSave == false {
            saveManga()
            didSave = true
            if #available(iOS 13.0, *) {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                // Fallback on earlier versions
            }
        }
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
            self.show(viewController, sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mangaDetailsCharacterSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
    }
    
}
