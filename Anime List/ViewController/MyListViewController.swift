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
    
    var selection = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        getSavedAnime()
    }
    
    func getSavedAnime() {
        let anime = persistenceManager.fetch(SavedAnime.self)
        self.savedAnime = anime
        
        // savedAnime.forEach({ print($0.name) })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAnime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myListCell") as? MyListTableViewCell else { return UITableViewCell() }
        
        let anime = savedAnime[indexPath.row]
        
        cell.mainImageView.loadImageUsingCacheWithUrlString(urlString: anime.image_url ?? "")
        cell.titleLabel.text = anime.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let anime = savedAnime[indexPath.row]
        selection = Int(anime.mal_id)
        self.performSegue(withIdentifier: "myListDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myListDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        }
    }
    
}
