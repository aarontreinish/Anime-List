//
//  DetailViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/23/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import NotificationBannerSwift

class DetailsViewController: UIViewController {
    
    let persistenceManager = PersistanceManager()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titlesView: UIView!
    
    @IBOutlet weak var myListLabel: UILabel!
    @IBOutlet weak var myListTitleLabel: UILabel!
    @IBOutlet weak var genreTitleLabel: UILabel!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var studioTitleLabel: UILabel!
    @IBOutlet weak var seasonTitleLabel: UILabel!
    @IBOutlet weak var episodesTypeLabel: UILabel!
    @IBOutlet weak var typeTitleLabel: UILabel!
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
    @IBOutlet weak var japaneseLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var airedAiringTitleLabel: UILabel!
    @IBOutlet weak var airedAiringLabel: UILabel!
    
    let activityIndicator = UIActivityIndicatorView()
    
    let reviewService = ReviewService.shared
    
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
    
    func getAllData() {
        let group = DispatchGroup()
        
        if animeDetailsArray == nil {
            group.enter()
            networkManager.getNewAnime(id: selection) { [weak self] (anime, error) in
                if let error = error {
                    print(error)
                }
                if let anime = anime {
                    self?.animeDetailsArray = anime
                    
                    self?.setUpData()
                    
                    self?.screenWillShow = true
                    
                    DispatchQueue.main.async {
                        self?.setLabels()
                    }
                    group.leave()
                }
            }
        }
        
        if animeCharactersArray.isEmpty {
            group.enter()
            networkManager.getCharacters(id: selection) { [weak self] (characters, error) in
                if let error = error {
                    print(error)
                }
                
                if let characters = characters {
                    self?.animeCharactersArray = characters
                    DispatchQueue.main.async {
                        self?.charactersCollectionView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.animeRecommendationsArray.isEmpty {
                group.enter()
                self.networkManager.getRecommendations(id: self.selection) { [weak self] (recommendations, error) in
                    if let error = error {
                        print(error)
                    }
                    
                    if let recommendations = recommendations {
                        self?.animeRecommendationsArray = recommendations
                        
                        DispatchQueue.main.async {
                            self?.recommendationsCollectionView.reloadData()
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.recommendationsCollectionView.reloadData()
            self.charactersCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
            self.mainView.isHidden = false
        }
    }
    
    func setLabels() {
        self.navigationItem.title = animeDetailsArray?.title
        typeTitleLabel.text = "TYPE"
        mainImageView.layer.cornerRadius = 10
        mainImageView.loadImageUsingCacheWithUrlString(urlString: animeDetailsArray?.image_url ?? "")
        descriptionLabel.text = animeDetailsArray?.synopsis
        seasonLabel.text = animeDetailsArray?.premiered
        rankLabel.text = rankString
        studioLabel.text = allStudios
        episodesLabel.text = episodesString
        typeLabel.text = animeDetailsArray?.type
        genreLabel.text = allGenres
        scoreLabel.text = scoreString
        japaneseLabel.text = animeDetailsArray?.title_japanese ?? ""
        englishLabel.text = animeDetailsArray?.title_english ?? ""
        
        if animeDetailsArray?.airing == true {
            airedAiringTitleLabel.text = "AIRING"
            
            airedAiringLabel.text = "\(animeDetailsArray?.aired?.string ?? "")"
            
        } else if animeDetailsArray?.airing == false {
            airedAiringTitleLabel.text = "AIRED"
            
            airedAiringLabel.text = "\(animeDetailsArray?.aired?.string ?? "")"
        }
        
        if checkIfSavedAtAll() == true {
            myListLabel.text = checkWhichEntityAnimeIsSavedIn()
        } else {
            myListTitleLabel.isHidden = true
            myListLabel.isHidden = true
        }
        
        trailerWebView.layer.cornerRadius = 10
        loadYoutube(url: animeDetailsArray?.trailer_url ?? "")
    }
    
    func checkDevice() {
        let modelName = UIDevice.modelName
        
        if modelName == "Simulator iPhone SE (2nd generation)" || modelName == "iPhone SE (2nd generation)" {
            seasonLabel.font = seasonLabel.font.withSize(12)
            seasonTitleLabel.font = seasonTitleLabel.font.withSize(12)
            typeLabel.font = typeLabel.font.withSize(12)
            typeTitleLabel.font = typeTitleLabel.font.withSize(12)
            rankLabel.font = rankLabel.font.withSize(12)
            rankTitleLabel.font = rankTitleLabel.font.withSize(12)
            genreTitleLabel.font = genreTitleLabel.font.withSize(12)
            genreLabel.font = genreLabel.font.withSize(12)
            episodesLabel.font = episodesLabel.font.withSize(12)
            episodesTypeLabel.font = episodesTypeLabel.font.withSize(12)
            studioLabel.font = studioLabel.font.withSize(12)
            studioTitleLabel.font = studioTitleLabel.font.withSize(12)
            scoreLabel.font = scoreLabel.font.withSize(12)
            scoreTitleLabel.font = scoreTitleLabel.font.withSize(12)
            myListLabel.font = myListLabel.font.withSize(12)
            myListTitleLabel.font = myListTitleLabel.font.withSize(12)
            
        }
        
        print(modelName)
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
        let deadlineTime = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.checkIfDataIsAllThere()
        }
        group.leave()
        
    }
    
    func loadYoutube(url: String) {
        guard let youtubeURL = URL(string: url) else { return }
        trailerWebView.load(URLRequest(url: youtubeURL))
    }
    
    func addToPlanToWatch() {
        
        if checkIfAlreadySaved(entity: PlanToWatch.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(animeDetailsArray?.mal_id ?? 0)
            
            let planToWatch = PlanToWatch(context: persistenceManager.context)
            planToWatch.mal_id = malId
            planToWatch.image_url = animeDetailsArray?.image_url
            planToWatch.name = animeDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToWatching() {
        
        if checkIfAlreadySaved(entity: Watching.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(animeDetailsArray?.mal_id ?? 0)
            
            let watching = Watching(context: persistenceManager.context)
            watching.mal_id = malId
            watching.image_url = animeDetailsArray?.image_url
            watching.name = animeDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToCompleted() {
        
        if checkIfAlreadySaved(entity: SavedAnime.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(animeDetailsArray?.mal_id ?? 0)
            
            let savedAnime = SavedAnime(context: persistenceManager.context)
            savedAnime.mal_id = malId
            savedAnime.image_url = animeDetailsArray?.image_url
            savedAnime.name = animeDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToDropped() {
        
        if checkIfAlreadySaved(entity: DroppedAnime.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(animeDetailsArray?.mal_id ?? 0)
            
            let dropped = DroppedAnime(context: persistenceManager.context)
            dropped.mal_id = malId
            dropped.image_url = animeDetailsArray?.image_url
            dropped.name = animeDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToOnHold() {
        
        if checkIfAlreadySaved(entity: OnHoldAnime.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(animeDetailsArray?.mal_id ?? 0)
            
            let onHold = OnHoldAnime(context: persistenceManager.context)
            onHold.mal_id = malId
            onHold.image_url = animeDetailsArray?.image_url
            onHold.name = animeDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(animeDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func requestReview() {
        let deadline = DispatchTime.now() + .seconds(6)
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.reviewService.requestReview()
        }
    }
    
    func deleteAnime<T: NSManagedObject>(entity: T.Type) {
        persistenceManager.delete(entity.self, malId: Float(selection))
    }
    
    func checkIfAlreadySaved<T: NSManagedObject>(entity: T.Type) -> Bool {
        let isSaved = persistenceManager.checkIfExists(entity.self, malId: Float(selection), attributeName: "mal_id")
        
        return isSaved
        
    }
    
    func checkIfSavedAtAll() -> Bool {
        let isCompleted = persistenceManager.checkIfExists(SavedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: Float(selection), attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        
        if isCompleted == true || isPlanToWatch == true || isWatching == true || isOnHold == true || isDropped == true {
            return true
        } else {
            return false
        }
    }
    
    func checkWhichEntityAnimeIsSavedIn() -> String {
        let isCompleted = persistenceManager.checkIfExists(SavedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: Float(selection), attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        if isCompleted == true {
            return "Completed"
        }
        
        if isPlanToWatch == true {
            return "Plan to watch"
        }
        
        if isWatching == true {
            return "Watching"
        }
        
        if isOnHold == true {
            return "On hold"
        }
        
        if isDropped == true {
            return "Dropped"
        }
        
        return ""
    }
    
    func removeFromEntity() {
        let isCompleted = persistenceManager.checkIfExists(SavedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToWatch = persistenceManager.checkIfExists(PlanToWatch.self, malId: Float(selection), attributeName: "mal_id")
        
        let isWatching = persistenceManager.checkIfExists(Watching.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedAnime.self, malId: Float(selection), attributeName: "mal_id")
        
        if isCompleted == true {
            deleteAnime(entity: SavedAnime.self)
        }
        
        if isPlanToWatch == true {
            deleteAnime(entity: PlanToWatch.self)
        }
        
        if isWatching == true {
            deleteAnime(entity: Watching.self)
        }
        
        if isOnHold == true {
            deleteAnime(entity: OnHoldAnime.self)
        }
        
        if isDropped == true {
            deleteAnime(entity: DroppedAnime.self)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let planToWatchAction = UIAlertAction(title: "Add to Plan to Watch", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Plan to watch"
            
            self.addToPlanToWatch()
        }
        
        let watchingAction = UIAlertAction(title: "Add to Watching", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Watching"
            
            self.addToWatching()
        }
        
        let completedAction = UIAlertAction(title: "Add to Completed", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Completed"
            
            self.addToCompleted()
        }
        
        let onHoldAction = UIAlertAction(title: "Add to On Hold", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "On hold"
            
            self.addToOnHold()
        }
        
        let droppedAction = UIAlertAction(title: "Add to Dropped", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Dropped"
            
            self.addToDropped()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(planToWatchAction)
        optionMenu.addAction(watchingAction)
        optionMenu.addAction(completedAction)
        optionMenu.addAction(onHoldAction)
        optionMenu.addAction(droppedAction)
        if checkIfSavedAtAll() == true {
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                self.removeFromEntity()
                
                self.myListTitleLabel.isHidden = true
                self.myListLabel.isHidden = true
                
                let banner = StatusBarNotificationBanner(title: "\(self.animeDetailsArray?.title ?? "") removed successfully", style: .danger)
                banner.show()
            }
            
            optionMenu.addAction(removeAction)
        }
        optionMenu.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
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
