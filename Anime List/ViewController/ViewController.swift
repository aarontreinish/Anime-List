//
//  ViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var id = 2
    var networkManager = NetworkManager()
    
    var topAiringArray: [TopElement] = []
    var topRankedArray: [TopElement] = []
    var topUpcomingArray: [TopElement] = []
    var mostPopularArray: [TopElement] = []
    
    var initialDataTopAiring: [TopElement] = []
    var initialDataTopRanked: [TopElement] = []
    var initialDataTopUpcoming: [TopElement] = []
    var initialDataMostPopular: [TopElement] = []
    
    var selection = 0
    
    let ref = Database.database().reference(withPath: "anime-reference")

    let animeMalIdCache = Bundle.main.decode(MalIdCache.self, from: "anime_cache.json")
    var nsfwAnimeArray: [Int] = []
    var nsfwAnimeDictionary: [Int: AnyObject] = [:]
    
    var viewHasShown = false
    
    let initialDataConfig = RemoteConfig.remoteConfig().configValue(forKey: "initialAnimeData").stringValue
    
    let activityIndicator = UIActivityIndicatorView()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    var homeTableViewCell = HomeTableViewCell()
    
    private enum Section: Int {
        case topAiringAnime
        case topRankedAnime
        case mostPopularAnime
        case topUpcomingAnime
        
        static var numberOfSections: Int { return 4 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refresher
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        activityIndicator.startAnimating()
        
        setUpData()
        
        callFunctions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupRemoteConfigDefaults()
        fetchRemoteConfig()
        
        setupActivityIndicator()
    }
    
    func setupRemoteConfigDefaults() {
        let defaultValues = [
            "initialAnimeData": "" as NSObject]
        
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }
    
    func fetchRemoteConfig() {
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
            if status == .success {
                print("Config fetched")
                
                RemoteConfig.remoteConfig().activate { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            } else {
                print("Config not fetched")
                print(error?.localizedDescription)
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
    
    func setUpData() {
        
        Database.database().reference().child("AnimeCache").child("nsfw").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if !snapshot.exists() {
                return
                
            } else {
                let animeNfwCache = snapshot.value
                
                self?.nsfwAnimeArray = animeNfwCache as! [Int]
                
            }
        }
    }
    
    func filterTopAiringData() {
        for (index, malId) in topAiringArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                topAiringArray.remove(at: index)
            }
        }
        
        var counter = 0
        
        if initialDataConfig == "0" {
            for (_, objects) in topAiringArray.enumerated() {
                initialDataTopAiring.append(objects)
                counter += 1
                
                if counter == 5 {
                    break
                }
            }
        }
    }
    
    func filterTopRankedData() {
        for (index, malId) in topRankedArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                topRankedArray.remove(at: index)
            }
        }
        
        var counter = 0
        
        if initialDataConfig == "0" {
            for (_, objects) in topRankedArray.enumerated() {
                initialDataTopRanked.append(objects)
                counter += 1
                
                if counter == 5 {
                    break
                }
            }
        }
    }
    
    func filterTopUpcomingData() {
        for (index, malId) in topUpcomingArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                topUpcomingArray.remove(at: index)
            }
        }
        
        var counter = 0
        
        if initialDataConfig == "0" {
            for (_, objects) in topUpcomingArray.enumerated() {
                initialDataTopUpcoming.append(objects)
                counter += 1
                
                if counter == 5 {
                    break
                }
            }
        }
    }
    
    func filterMostPopularData() {
        for (index, malId) in mostPopularArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                mostPopularArray.remove(at: index)
            }
        }
        
        var counter = 0
        
        if initialDataConfig == "0" {
            for (_, objects) in mostPopularArray.enumerated() {
                initialDataMostPopular.append(objects)
                counter += 1
                
                if counter == 5 {
                    break
                }
            }
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
            
            self.networkManager.getTopRanked(type: "anime") { [weak self] (topRanked, error) in
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
            
            self.networkManager.getMostPopular(type: "anime") { [weak self] (mostPopular, error) in
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
        
        if topAiringArray.count == 0 {
            group.enter()
            
            self.networkManager.getTopAiring(type: "anime") { [weak self] (topAiring, error) in
                if let error = error {
                    print(error)
                }
                
                if let topAiring = topAiring {
                    self?.topAiringArray = topAiring
                    self?.filterTopAiringData()
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        if topUpcomingArray.count == 0 {
            group.enter()
            
            self.networkManager.getTopUpcoming(type: "anime") { [weak self] (topUpcoming, error) in
                if let error = error {
                    print(error)
                }
                
                if let topUpcoming = topUpcoming {
                    self?.topUpcomingArray = topUpcoming
                    self?.filterTopUpcomingData()
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    group.leave()
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
        if topUpcomingArray.count == 0 || topRankedArray.count == 0 || topAiringArray.count == 0 || mostPopularArray.count == 0 {
            getAllData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabelPadding.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
        
        switch Section(rawValue: section) {
        case .topAiringAnime:
            headerView.text = "Top Airing Anime"
        case .topRankedAnime:
            headerView.text = "Top Ranked Anime"
        case .mostPopularAnime:
            headerView.text = "Most Popular Anime"
        case .topUpcomingAnime:
            headerView.text = "Top Upcoming Anime"
        case .none:
            headerView.text = "No Anime available"
        }
        
        return headerView
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as? HomeTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let homeTableViewCell = cell as? HomeTableViewCell else { return }
        
        homeTableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if initialDataConfig == "0" {
            switch Section(rawValue: section) {
            case .topAiringAnime:
                return initialDataTopAiring.count
            case .topRankedAnime:
                return initialDataTopRanked.count
            case .mostPopularAnime:
                return initialDataMostPopular.count
            case .topUpcomingAnime:
                return initialDataTopUpcoming.count
            case .none:
                return 1
            }
        } else {
            switch Section(rawValue: section) {
            case .topAiringAnime:
                return topAiringArray.count
            case .topRankedAnime:
                return topRankedArray.count
            case .mostPopularAnime:
                return mostPopularArray.count
            case .topUpcomingAnime:
                return topUpcomingArray.count
            case .none:
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width / 2.2, height: collectionView.bounds.height)
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HomeCollectionViewCell
        
        let topElement: TopElement
        
        if topAiringArray.count != 0 && topRankedArray.count != 0 && mostPopularArray.count != 0 && topUpcomingArray.count != 0 {
            
            if initialDataConfig == "0" {
                switch Section(rawValue: collectionView.tag) {
                case .topAiringAnime:
                    topElement = initialDataTopAiring[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .topRankedAnime:
                    topElement = initialDataTopRanked[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .mostPopularAnime:
                    topElement = initialDataMostPopular[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .topUpcomingAnime:
                    topElement = initialDataTopUpcoming[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .none:
                    cell.titleLabel.text = "No Anime Available"
                }
            } else {
                switch Section(rawValue: collectionView.tag) {
                case .topAiringAnime:
                    topElement = topAiringArray[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .topRankedAnime:
                    topElement = topRankedArray[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .mostPopularAnime:
                    topElement = mostPopularArray[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .topUpcomingAnime:
                    topElement = topUpcomingArray[indexPath.row]
                    cell.titleLabel.text = topElement.title
                    cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
                case .none:
                    cell.titleLabel.text = "No Anime Available"
                }
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as? HomeTableViewCell
        
        cell?.collectionView.tag = indexPath.row
        
        let topElement: TopElement
        
        if initialDataConfig == "0" {
            switch Section(rawValue: collectionView.tag) {
            case .topAiringAnime:
                topElement = initialDataTopAiring[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .topRankedAnime:
                topElement = initialDataTopRanked[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .mostPopularAnime:
                topElement = initialDataMostPopular[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .topUpcomingAnime:
                topElement = initialDataTopUpcoming[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .none:
                selection = 0
            }
        } else {
            switch Section(rawValue: collectionView.tag) {
            case .topAiringAnime:
                topElement = topAiringArray[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .topRankedAnime:
                topElement = topRankedArray[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .mostPopularAnime:
                topElement = mostPopularArray[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .topUpcomingAnime:
                topElement = topUpcomingArray[indexPath.row]
                selection = topElement.mal_id ?? 0
                self.performSegue(withIdentifier: "detailsSegue", sender: self)
            case .none:
                selection = 0
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        }
    }
    
}

class UILabelPadding: UILabel {
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
