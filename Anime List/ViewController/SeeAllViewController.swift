//
//  SeeAllViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 5/18/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class SeeAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var navTitle = ""
    
    var initialData: [TopElement] = []
    var isAnime: Bool?
    
    var networkManager = NetworkManager()
    
    var type = ""
    var subtype = ""
    var pageNumber = 2
    
    var selection = 0
    
    var fetchingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let tableViewLoadingCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "loadingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = navTitle
    }
    
    func fetchNextData() {
        fetchingMore = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        networkManager.getTopPagination(page: pageNumber, type: type, subtype: subtype) { [weak self] (data, error) in
            
            if let error = error {
                print(error)
            }
            
            if let data = data {
                self?.initialData.append(contentsOf: data)
                
                DispatchQueue.main.async {
                    self?.fetchingMore = false
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return initialData.count
        } else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeAllCell") as? SeeAllTableViewCell else { return UITableViewCell() }
            
            let data = initialData[indexPath.row]
            
            cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: data.image_url ?? "")
            cell.titleLabel.text = data.title ?? ""
            cell.numberLabel.text = "\(indexPath.row + 1)"
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as? LoadingTableViewCell else { return UITableViewCell() }
            cell.activityIndicator.startAnimating()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAnime == true {
            let data = initialData[indexPath.row]
            selection = data.mal_id ?? 0
            self.performSegue(withIdentifier: "seeAllAnimeDetailsSegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let data = initialData[indexPath.row]
            selection = data.mal_id ?? 0
            self.performSegue(withIdentifier: "seeAllMangaDetailsSegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeAllAnimeDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        } else if segue.identifier == "seeAllMangaDetailsSegue" {
            let mangaDetailsViewController = segue.destination as? MangaDetailsViewController
            
            mangaDetailsViewController?.selection = selection
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            if !fetchingMore {
                fetchNextData()
                pageNumber += 1
            }
        }
    }

}
