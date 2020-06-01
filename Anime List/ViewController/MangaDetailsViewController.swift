//
//  MangaDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/23/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import CoreData
import NotificationBannerSwift

class MangaDetailsViewController: UIViewController {
    
    let persistenceManager = PersistanceManager()
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var myListLabel: UILabel!
    @IBOutlet weak var myListTitleLabel: UILabel!
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
    
    let reviewService = ReviewService.shared
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.mangaRecommendationsArray.isEmpty {
                group.enter()
                self.networkManager.getMangaRecommendations(id: self.selection) { [weak self] (recommendations, error) in
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
            publishedPublishingTitleLabel.text = "PUBLISHED"
            
            publishedPublishingLabel.text = "\(mangaDetailsArray?.published?.string ?? "")"
        }
        
        if checkIfSavedAtAll() == true {
            myListLabel.text = checkWhichEntityMangaIsSavedIn()
        } else {
            myListTitleLabel.isHidden = true
            myListLabel.isHidden = true
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
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.checkIfDataIsAllThere()
        }
        group.leave()
        
    }
    
    func addToPlanToRead() {
        
        if checkIfAlreadySaved(entity: PlanToRead.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(mangaDetailsArray?.mal_id ?? 0)
            
            let planToRead = PlanToRead(context: persistenceManager.context)
            planToRead.mal_id = malId
            planToRead.image_url = mangaDetailsArray?.image_url
            planToRead.name = mangaDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToReading() {
        
        if checkIfAlreadySaved(entity: Reading.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(mangaDetailsArray?.mal_id ?? 0)
            
            let reading = Reading(context: persistenceManager.context)
            reading.mal_id = malId
            reading.image_url = mangaDetailsArray?.image_url
            reading.name = mangaDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToCompleted() {
        
        if checkIfAlreadySaved(entity: SavedManga.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(mangaDetailsArray?.mal_id ?? 0)
            
            let savedManga = SavedManga(context: persistenceManager.context)
            savedManga.mal_id = malId
            savedManga.image_url = mangaDetailsArray?.image_url
            savedManga.name = mangaDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToDropped() {
        
        if checkIfAlreadySaved(entity: DroppedManga.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(mangaDetailsArray?.mal_id ?? 0)
            
            let dropped = DroppedManga(context: persistenceManager.context)
            dropped.mal_id = malId
            dropped.image_url = mangaDetailsArray?.image_url
            dropped.name = mangaDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") added successfully", style: .success)
            banner.show()
            
            requestReview()
        }
    }
    
    func addToOnHold() {
        
        if checkIfAlreadySaved(entity: OnHoldManga.self) == true {
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") is already added", style: .info)
            banner.show()
        } else {
            removeFromEntity()
            
            let malId = Float(mangaDetailsArray?.mal_id ?? 0)
            
            let onHold = OnHoldManga(context: persistenceManager.context)
            onHold.mal_id = malId
            onHold.image_url = mangaDetailsArray?.image_url
            onHold.name = mangaDetailsArray?.title
            
            persistenceManager.save()
            
            let banner = StatusBarNotificationBanner(title: "\(mangaDetailsArray?.title ?? "") added successfully", style: .success)
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
    
    func deleteManga<T: NSManagedObject>(entity: T.Type) {
        persistenceManager.delete(entity.self, malId: Float(selection))
    }
    
    func checkIfAlreadySaved<T: NSManagedObject>(entity: T.Type) -> Bool {
        let isSaved = persistenceManager.checkIfExists(entity.self, malId: Float(selection), attributeName: "mal_id")
        
        return isSaved
        
    }
    
    func checkIfSavedAtAll() -> Bool {
        let isCompleted = persistenceManager.checkIfExists(SavedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToRead = persistenceManager.checkIfExists(PlanToRead.self, malId: Float(selection), attributeName: "mal_id")
        
        let isReading = persistenceManager.checkIfExists(Reading.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        
        if isCompleted == true || isPlanToRead == true || isReading == true || isOnHold == true || isDropped == true {
            return true
        } else {
            return false
        }
    }
    
    func checkWhichEntityMangaIsSavedIn() -> String {
        let isCompleted = persistenceManager.checkIfExists(SavedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToRead = persistenceManager.checkIfExists(PlanToRead.self, malId: Float(selection), attributeName: "mal_id")
        
        let isReading = persistenceManager.checkIfExists(Reading.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        if isCompleted == true {
            return "Completed"
        }
        
        if isPlanToRead == true {
            return "Plan to read"
        }
        
        if isReading == true {
            return "Reading"
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
        let isCompleted = persistenceManager.checkIfExists(SavedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isPlanToRead = persistenceManager.checkIfExists(PlanToRead.self, malId: Float(selection), attributeName: "mal_id")
        
        let isReading = persistenceManager.checkIfExists(Reading.self, malId: Float(selection), attributeName: "mal_id")
        
        let isOnHold = persistenceManager.checkIfExists(OnHoldManga.self, malId: Float(selection), attributeName: "mal_id")
        
        let isDropped = persistenceManager.checkIfExists(DroppedManga.self, malId: Float(selection), attributeName: "mal_id")
        
        if isCompleted == true {
            deleteManga(entity: SavedManga.self)
        }
        
        if isPlanToRead == true {
            deleteManga(entity: PlanToRead.self)
        }
        
        if isReading == true {
            deleteManga(entity: Reading.self)
        }
        
        if isOnHold == true {
            deleteManga(entity: OnHoldManga.self)
        }
        
        if isDropped == true {
            deleteManga(entity: DroppedManga.self)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let planToReadAction = UIAlertAction(title: "Add to Plan to Read", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Plan to read"
            
            self.addToPlanToRead()
        }
        
        let readingAction = UIAlertAction(title: "Add to Reading", style: .default) { (action) in
            self.myListTitleLabel.isHidden = false
            self.myListLabel.isHidden = false
            self.myListLabel.text = "Reading"
            
            self.addToReading()
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
        
        optionMenu.addAction(planToReadAction)
        optionMenu.addAction(readingAction)
        optionMenu.addAction(completedAction)
        optionMenu.addAction(onHoldAction)
        optionMenu.addAction(droppedAction)
        if checkIfSavedAtAll() == true {
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                self.removeFromEntity()
                
                self.myListTitleLabel.isHidden = true
                self.myListLabel.isHidden = true
                
                let banner = StatusBarNotificationBanner(title: "\(self.mangaDetailsArray?.title ?? "") removed successfully", style: .danger)
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
