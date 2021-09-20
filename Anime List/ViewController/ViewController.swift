//
//  ViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import NotificationBannerSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var id = 2
    var networkManager = NetworkManager()
    
    var topAiringArray: [TopElement] = []
    var topRankedArray: [TopElement] = []
    var topUpcomingArray: [TopElement] = []
    var mostPopularArray: [TopElement] = []
    
    private var errorArray: [String] = []
    
    var selection = 0
    
    var nsfwAnimeArray: [Int] = []
    
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
        
        fetchFirebaseData()
        
        callFunctions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
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
    
    func fetchFirebaseData() {
        
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
    }
    
    func filterTopRankedData() {
        for (index, malId) in topRankedArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                topRankedArray.remove(at: index)
            }
        }
    }
    
    func filterTopUpcomingData() {
        for (index, malId) in topUpcomingArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                topUpcomingArray.remove(at: index)
            }
        }
    }
    
    func filterMostPopularData() {
        for (index, malId) in mostPopularArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                mostPopularArray.remove(at: index)
            }
        }
    }
    
    func callFunctions() {
        let group = DispatchGroup()
        
        group.enter()
        getAllData()
        group.leave()
        
        group.enter()
        let deadlineTime = DispatchTime.now() + 3.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            if self?.topUpcomingArray.count == 0 || self?.topRankedArray.count == 0 || self?.topAiringArray.count == 0 || self?.mostPopularArray.count == 0 {
                self?.getAllData()
                group.leave()
            }
            
            
            group.enter()
            if self?.topUpcomingArray.count == 0 && self?.topRankedArray.count == 0 && self?.topAiringArray.count == 0 && self?.mostPopularArray.count == 0 {
                let banner = StatusBarNotificationBanner(title: "Could not fetch anime, please try again later", style: .danger)
                banner.show()
                self?.activityIndicator.stopAnimating()
            }
            group.leave()
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
            
            self.networkManager.getTopRanked(type: "anime") { [weak self] (topRanked, error) in
                if let error = error {
                    print(error)
                    self?.errorArray.append(error)
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
                    self?.errorArray.append(error)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.topAiringArray.count == 0 {
                group.enter()
                
                self?.networkManager.getTopAiring(type: "anime") { [weak self] (topAiring, error) in
                    if let error = error {
                        print(error)
                        self?.errorArray.append(error)
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
            
            if self?.topUpcomingArray.count == 0 {
                group.enter()
                
                self?.networkManager.getTopUpcoming(type: "anime") { [weak self] (topUpcoming, error) in
                    if let error = error {
                        print(error)
                        self?.errorArray.append(error)
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
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
        }
        
    }
    
    func checkIfDataIsAllThere() {
        if topUpcomingArray.count == 0 || topRankedArray.count == 0 || topAiringArray.count == 0 || mostPopularArray.count == 0 {
            
        }
    }
    
    @objc func topAiringSeeAllButtonPressed() {
        seeAllNavTitle = "Top Airing Anime"
        seeAllInitialData = topAiringArray
        seeAllSubtype = "airing"
        performSegue(withIdentifier: "seeAllAnimeSegue", sender: self)
    }
    
    @objc func topRankedSeeAllButtonPressed() {
        seeAllNavTitle = "Top Ranked Anime"
        seeAllInitialData = topRankedArray
        seeAllSubtype = ""
        performSegue(withIdentifier: "seeAllAnimeSegue", sender: self)
    }
    
    @objc func mostPopularSeeAllButtonPressed() {
        seeAllNavTitle = "Most Popular Anime"
        seeAllInitialData = mostPopularArray
        seeAllSubtype = "bypopularity"
        performSegue(withIdentifier: "seeAllAnimeSegue", sender: self)
    }
    
    @objc func topUpcomingSeeAllButtonPressed() {
        seeAllNavTitle = "Top Upcoming Anime"
        seeAllInitialData = topUpcomingArray
        seeAllSubtype = "upcoming"
        performSegue(withIdentifier: "seeAllAnimeSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: 250, height: 20)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: (tableView.frame.width - 120), y: 0, width: 150, height: 20)
        button.setTitle("See all", for: .normal)
        
        switch Section(rawValue: section) {
        case .topAiringAnime:
            label.text = "Top Airing Anime"
            button.addTarget(self, action: #selector(topAiringSeeAllButtonPressed), for: .touchUpInside)
        case .topRankedAnime:
            label.text = "Top Ranked Anime"
            button.addTarget(self, action: #selector(topRankedSeeAllButtonPressed), for: .touchUpInside)
        case .mostPopularAnime:
            label.text = "Most Popular Anime"
            button.addTarget(self, action: #selector(mostPopularSeeAllButtonPressed), for: .touchUpInside)
        case .topUpcomingAnime:
            label.text = "Top Upcoming Anime"
            button.addTarget(self, action: #selector(topUpcomingSeeAllButtonPressed), for: .touchUpInside)
        case .none:
            label.text = "No Anime available"
        }
        
        view.addSubview(label)
        view.addSubview(button)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HomeCollectionViewCell
        
        let topElement: TopElement
        
        if topAiringArray.count != 0 && topRankedArray.count != 0 && mostPopularArray.count != 0 && topUpcomingArray.count != 0 {
            
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as? HomeTableViewCell
        
        cell?.collectionView.tag = indexPath.row
        
        let topElement: TopElement
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        } else if segue.identifier == "seeAllAnimeSegue" {
            let seeAllViewController = segue.destination as? SeeAllViewController
            
            seeAllViewController?.navTitle = seeAllNavTitle
            seeAllViewController?.initialData = seeAllInitialData
            seeAllViewController?.subtype = seeAllSubtype
            seeAllViewController?.type = "anime"
            seeAllViewController?.isAnime = true
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
