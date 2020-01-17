//
//  MangaViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MangaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var networkManager = NetworkManager()
    
    var topRankedArray: [TopElement] = []
    var topFavoritesArray: [TopElement] = []
    var mostPopularArray: [TopElement] = []
    
    var selection = 0
    
    var viewHasShown = false
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    group.leave()
                }
            }
        }
        
        if topFavoritesArray.count == 0 {
            group.enter()
            
            self.networkManager.getTopFavorties(type: "manga") { [weak self] (topUpcoming, error) in
                if let error = error {
                    print(error)
                }
                
                if let topUpcoming = topUpcoming {
                    self?.topFavoritesArray = topUpcoming
                    
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
        let deadlineTime = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkIfDataIsAllThere()
        }
        group.leave()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabelPadding.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
        
        switch Section(rawValue: section) {
        case .topRankedManga:
            headerView.text = "Top Ranked Manga"
        case .mostPopularManga:
            headerView.text = "Most Popular Manga"
        case .topFavoriteManga:
            headerView.text = "Favorite Manga"
        case .none:
            headerView.text = "No Manga available"
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
        }
    }
    
}