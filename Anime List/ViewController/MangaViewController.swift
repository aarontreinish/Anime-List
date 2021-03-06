//
//  MangaViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class MangaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var networkManager = NetworkManager()
    
    var topRankedArray: [TopElement] = []
    var topFavoritesArray: [TopElement] = []
    var mostPopularArray: [TopElement] = []
    
    var selection = 0
    
    var nsfwMangaArray: [Int] = []
    
    var viewHasShown = false
    
    var seeAllNavTitle = ""
    var seeAllInitialData: [TopElement] = []
    var seeAllSubtype = ""
    
    let activityIndicator = UIActivityIndicatorView()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    private enum Section: Int {
        case topRankedManga
        case mostPopularManga
        case topFavoriteManga
        
        static var numberOfSections: Int { return 3 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refresher
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        activityIndicator.startAnimating()
        
        fetchFirebaseData()
        callFunctions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
    }
    
    func fetchFirebaseData() {
        
        Database.database().reference().child("MangaCache").child("nsfw").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if !snapshot.exists() {
                return
                
            } else {
                let mangaNfwCache = snapshot.value
                
                self?.nsfwMangaArray = mangaNfwCache as! [Int]
            }
        }
    }
    
    func filterTopRankedData() {
        for (index, malId) in topRankedArray.enumerated().reversed() {
            if nsfwMangaArray.contains(malId.mal_id ?? 0) {
                topRankedArray.remove(at: index)
            }
        }
    }
    
    func filterTopFavoritesData() {
        for (index, malId) in topFavoritesArray.enumerated().reversed() {
            if nsfwMangaArray.contains(malId.mal_id ?? 0) {
                topFavoritesArray.remove(at: index)
            }
        }
    }
    
    func filterMostPopularData() {
        for (index, malId) in mostPopularArray.enumerated().reversed() {
            if nsfwMangaArray.contains(malId.mal_id ?? 0) {
                mostPopularArray.remove(at: index)
            }
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
    
    @objc func refreshData() {
        getAllData()
        
        refresher.endRefreshing()
        
        tableView.isHidden = false
    }
    
    func getAllData() {
        tableView.isHidden = true
        
        let group = DispatchGroup()
        
        if topRankedArray.count == 0 {
            group.enter()
            
            self.networkManager.getTopRanked(type: "manga") { [weak self] (topRanked, error) in
                if let error = error {
                    print(error)
                }
                
                if let topRanked = topRanked {
                    self?.topRankedArray = topRanked
                    self?.filterTopRankedData()
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        if mostPopularArray.count == 0 {
            group.enter()
            
            self.networkManager.getMostPopular(type: "manga") { [weak self] (mostPopular, error) in
                if let error = error {
                    print(error)
                }
                
                if let mostPopular = mostPopular {
                    self?.mostPopularArray = mostPopular
                    self?.filterMostPopularData()
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if self?.topFavoritesArray.count == 0 {
                group.enter()
                
                self?.networkManager.getTopFavorties(type: "manga") { [weak self] (topUpcoming, error) in
                    if let error = error {
                        print(error)
                    }
                    
                    if let topUpcoming = topUpcoming {
                        self?.topFavoritesArray = topUpcoming
                        self?.filterTopFavoritesData()
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
        }
    }
    
    func checkIfDataIsAllThere() {
        if topFavoritesArray.isEmpty || mostPopularArray.isEmpty || topRankedArray.isEmpty {
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
            group.leave()
            
            
            group.enter()
            if self?.topFavoritesArray.count == 0 && self?.mostPopularArray.count == 0 && self?.topRankedArray.count == 0 {
                let banner = StatusBarNotificationBanner(title: "Could not fetch manga, please try again later", style: .danger)
                banner.show()
                self?.activityIndicator.stopAnimating()
            }
            group.leave()
        }
    }
    
    @objc func topRankedSeeAllButtonPressed() {
        seeAllNavTitle = "Top Ranked Manga"
        seeAllInitialData = topRankedArray
        seeAllSubtype = "ranked"
        performSegue(withIdentifier: "seeAllMangaSegue", sender: self)
    }
    
    @objc func mostPopularSeeAllButtonPressed() {
        seeAllNavTitle = "Most Popular Manga"
        seeAllInitialData = mostPopularArray
        seeAllSubtype = "bypopularity"
        performSegue(withIdentifier: "seeAllMangaSegue", sender: self)
    }
    
    @objc func favoriteSeeAllButtonPressed() {
        seeAllNavTitle = "Favorite Manga"
        seeAllInitialData = mostPopularArray
        seeAllSubtype = "favorite"
        performSegue(withIdentifier: "seeAllMangaSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: 250, height: 20)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: (tableView.frame.width - 120), y: 0, width: 150, height: 20)
        button.setTitle("See all", for: .normal)
        
        switch Section(rawValue: section) {
        case .topRankedManga:
            label.text = "Top Ranked Manga"
            button.addTarget(self, action: #selector(topRankedSeeAllButtonPressed), for: .touchUpInside)
        case .mostPopularManga:
            label.text = "Most Popular Manga"
            button.addTarget(self, action: #selector(mostPopularSeeAllButtonPressed), for: .touchUpInside)
        case .topFavoriteManga:
            label.text = "Favorite Manga"
            button.addTarget(self, action: #selector(favoriteSeeAllButtonPressed), for: .touchUpInside)
        case .none:
            label.text = "No Manga available"
        }
        
        view.addSubview(label)
        view.addSubview(button)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mangaCell") as? MangaTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let mangaTableViewCell = cell as? MangaTableViewCell else { return }
        
        mangaTableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
    }
}

extension MangaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch Section(rawValue: section) {
        case .topRankedManga:
            return topRankedArray.count
        case .mostPopularManga:
            return mostPopularArray.count
        case .topFavoriteManga:
            return topFavoritesArray.count
        case .none:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 156.0, height: 283.0)
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mangaCollectionCell", for: indexPath) as! MangaCollectionViewCell
        
        let topElement: TopElement
        
        if topRankedArray.count != 0 && mostPopularArray.count != 0 && topFavoritesArray.count != 0 {
            
            switch Section(rawValue: collectionView.tag) {
            case .topRankedManga:
                topElement = topRankedArray[indexPath.row]
                cell.titleLabel.text = topElement.title
                cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
            case .mostPopularManga:
                topElement = mostPopularArray[indexPath.row]
                cell.titleLabel.text = topElement.title
                cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
            case .topFavoriteManga:
                topElement = topFavoritesArray[indexPath.row]
                cell.titleLabel.text = topElement.title
                cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
            case .none:
                cell.titleLabel.text = "No Manga Available"
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mangaCell") as? MangaTableViewCell
        
        cell?.collectionView.tag = indexPath.row
        
        let topElement: TopElement
        
        switch Section(rawValue: collectionView.tag) {
        case .topRankedManga:
            topElement = topRankedArray[indexPath.row]
            selection = topElement.mal_id ?? 0
            self.performSegue(withIdentifier: "mangaDetailsSegue", sender: self)
        case .mostPopularManga:
            topElement = mostPopularArray[indexPath.row]
            selection = topElement.mal_id ?? 0
            self.performSegue(withIdentifier: "mangaDetailsSegue", sender: self)
        case .topFavoriteManga:
            topElement = topFavoritesArray[indexPath.row]
            selection = topElement.mal_id ?? 0
            self.performSegue(withIdentifier: "mangaDetailsSegue", sender: self)
        case .none:
            selection = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mangaDetailsSegue" {
            let mangaDetailsViewController = segue.destination as? MangaDetailsViewController
            
            mangaDetailsViewController?.selection = selection
        } else if segue.identifier == "seeAllMangaSegue" {
            let seeAllViewController = segue.destination as? SeeAllViewController
            
            seeAllViewController?.navTitle = seeAllNavTitle
            seeAllViewController?.initialData = seeAllInitialData
            seeAllViewController?.subtype = seeAllSubtype
            seeAllViewController?.type = "manga"
            seeAllViewController?.isAnime = false
        }
    }
    
}
