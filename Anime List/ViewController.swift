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
    
    var homeTableViewCell = HomeTableViewCell()
    
    private enum Section: Int {
        case topAiringAnime
        case topRankedAnime
        case topUpcomingAnime

//        init?(indexPath: IndexPath) {
//            self.init(rawValue: indexPath.section)
//        }

        static var numberOfSections: Int { return 3 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
                
        //        networkManager.getSearchedAnime(name: "TokyoGhoul") { (searchedAnime, error) in
        //            if let error = error {
        //                print(error)
        //            }
        //
        //            if let searchedAnime = searchedAnime {
        //                print(searchedAnime)
        //            }
        //        }
        
        //        networkManager.getNewAnime(id: 1) { (anime, error) in
        //            if let error = error {
        //                print(error)
        //            }
        //            if let anime = anime {
        //                print(anime)
        //            }
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTopRanked()
        getTopUpcoming()
        getTopAiring()
    }
    
    func getTopRanked() {
         networkManager.getTopRanked { (topRanked, error) in
             if let error = error {
                 print(error)
             }
             
             DispatchQueue.main.async {
                 if let topRanked = topRanked {
                     self.topRankedArray = topRanked
                     self.tableView.reloadData()
                     print(self.topRankedArray.count)
                 }
             }
         }
     }
     
     func getTopAiring() {
         networkManager.getTopAiring { (topAiring, error) in
             if let error = error {
                 print(error)
             }
             
             DispatchQueue.main.async {
                 if let topAiring = topAiring {
                     self.topAiringArray = topAiring
                     self.tableView.reloadData()
                     print(self.topAiringArray.count)
                 }
             }
         }
     }
     
     func getTopUpcoming() {
         networkManager.getTopUpcoming { (topUpcoming, error) in
             if let error = error {
                 print(error)
             }
             
             DispatchQueue.main.async {
                 if let topUpcoming = topUpcoming {
                     self.topUpcomingArray = topUpcoming
                     self.tableView.reloadData()
                     print(self.topUpcomingArray.count)
                 }
             }
         }
     }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        switch Section(rawValue: section) {
        case .topAiringAnime:
            headerView.text = "Top Airing Anime"
        case .topRankedAnime:
            headerView.text = "Top Ranked Anime"
        case .topUpcomingAnime:
            headerView.text = "Top Upcoming Anime"
        case .none:
            headerView.text = "No Anime available"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
        case .topUpcomingAnime:
            return topUpcomingArray.count
        case .none:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HomeCollectionViewCell
        
        let topElement: TopElement
        
        switch Section(rawValue: cell.tag) {
        case .topAiringAnime:
            topElement = topAiringArray[indexPath.row]
            cell.textView.text = topElement.title
          //  cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
        case .topRankedAnime:
            topElement = topRankedArray[indexPath.row]
            cell.textView.text = topElement.title
            //cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
        case .topUpcomingAnime:
            topElement = topUpcomingArray[indexPath.row]
            cell.textView.text = topElement.title
            //cell.imageView.loadImageUsingCacheWithUrlString(urlString: topElement.image_url ?? "")
        case .none:
            cell.textView.text = "No Anime Available"
        }
        
        return cell
    }
    
    
}
