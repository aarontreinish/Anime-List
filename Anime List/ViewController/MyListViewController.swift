//
//  MyListViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 2/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let persistenceManager = PersistanceManager()
    var savedAnime = [SavedAnime]()
    var savedManga = [SavedManga]()
    
    var selection = 0
    
    private enum Order {
        case notOrdered
        case orderedByName
    }
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        getSavedAnime()
        getSavedManga()
        
        tableView.reloadData()
    }
    
    @objc func refreshData() {
        if segmentedController.selectedSegmentIndex == 0 {
            getSavedAnime()
        } else if segmentedController.selectedSegmentIndex == 1 {
            getSavedManga()
        }
        
        refresher.endRefreshing()
        
        tableView.reloadData()
    }
    
    func getSavedAnime() {
        let anime = persistenceManager.fetch(SavedAnime.self)
        savedAnime = anime
        
    }
    
    func getSavedManga() {
        let manga = persistenceManager.fetch(SavedManga.self)
        
        savedManga = manga
    }
    
    func sortByNameAscending() {
        if segmentedController.selectedSegmentIndex == 0 {
            let anime = persistenceManager.fetchSortedDataByName(SavedAnime.self)
            savedAnime = anime
        } else if segmentedController.selectedSegmentIndex == 1 {
            let manga = persistenceManager.fetchSortedDataByName(SavedManga.self)
            savedManga = manga
        }
        
        tableView.reloadData()
    }
    
    func deleteAll() {
        if segmentedController.selectedSegmentIndex == 0 {
            persistenceManager.deleteAllRecords(SavedAnime.self)
            
            savedAnime.removeAll()
        } else if segmentedController.selectedSegmentIndex == 1 {
            persistenceManager.deleteAllRecords(SavedManga.self)
            
            savedManga.removeAll()
        }
        
        tableView.reloadData()
    }
    
    @IBAction func segmentedControllerAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func ellipseButtonAction(_ sender: Any) {

        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
            
        let deleteAllAction = UIAlertAction(title: "Delete All", style: .default) { (action) in
            self.deleteAll()
        }
        
        let orderByNameAction = UIAlertAction(title: "Order by name", style: .default) { (action) in
            self.sortByNameAscending()
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
        optionMenu.addAction(deleteAllAction)
        optionMenu.addAction(orderByNameAction)
        optionMenu.addAction(cancelAction)
            
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedController.selectedSegmentIndex == 0 {
            return savedAnime.count
        } else if segmentedController.selectedSegmentIndex == 1 {
            return savedManga.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myListCell") as? MyListTableViewCell else { return UITableViewCell() }
        
        if segmentedController.selectedSegmentIndex == 0 {
            let anime = savedAnime[indexPath.row]
            cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
            cell.titleLabel.text = anime.name
        } else if segmentedController.selectedSegmentIndex == 1 {
            let manga = savedManga[indexPath.row]
            cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: manga.image_url ?? "")
            cell.titleLabel.text = manga.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let anime = savedAnime[indexPath.row]
            persistenceManager.context.delete(anime)
            savedAnime.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            persistenceManager.save()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentedController.selectedSegmentIndex == 0 {
            let anime = savedAnime[indexPath.row]
            selection = Int(anime.mal_id)
            self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
        } else if segmentedController.selectedSegmentIndex == 1 {
            let manga = savedManga[indexPath.row]
            selection = Int(manga.mal_id)
            self.performSegue(withIdentifier: "myListMangaDetailsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myListDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        } else if segue.identifier == "myListMangaDetailsSegue" {
            let mangaDetailsViewController = segue.destination as? MangaDetailsViewController
            
            mangaDetailsViewController?.selection = selection
        }
    }
    
}
