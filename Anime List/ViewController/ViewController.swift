//
//  ViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var id = 2
    var networkManager = NetworkManager()
    
    var topAiringArray: [TopElement] = []
    var topRankedArray: [TopElement] = []
    var topUpcomingArray: [TopElement] = []
    var mostPopularArray: [TopElement] = []
    
    var selection = 0
    
    var viewHasShown = false
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(getData), for: .valueChanged)
        
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
        getTopRanked()
        getTopUpcoming()
        getTopAiring()
        getMostPopular()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
    }
    
    @objc func getData() {
        getTopRanked()
        getTopUpcoming()
        getTopAiring()
        getMostPopular()
        
        refresher.endRefreshing()
        
        tableView.isHidden = false
    }
    
    func getTopRanked() {
        
        tableView.isHidden = true
        
        networkManager.getTopRanked { (topRanked, error) in
            if let error = error {
                print(error)
            }
            
            if let topRanked = topRanked {
                self.topRankedArray = topRanked
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getMostPopular() {
        networkManager.getMostPopular { (mostPopular, error) in
            if let error = error {
                print(error)
            }
            
            if let mostPopular = mostPopular {
                self.mostPopularArray = mostPopular
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getTopAiring() {
        networkManager.getTopAiring { (topAiring, error) in
            if let error = error {
                print(error)
            }
            
            if let topAiring = topAiring {
                self.topAiringArray = topAiring
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getTopUpcoming() {
        networkManager.getTopUpcoming { (topUpcoming, error) in
            if let error = error {
                print(error)
            }
            
            if let topUpcoming = topUpcoming {
                self.topUpcomingArray = topUpcoming
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
        
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

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        }
    }
    
    
}