//
//  SearchViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/26/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchPlacementLabel: UILabel!
    
    var networkManager = NetworkManager()
    
    var selection = 0
    
    var bannedSearchWords = ["Loli", "Lolita", "Lolicon", "Roricon", "Shotacon", "Shota", "Yaoi", "Ecchi", "Hentai", "loli", "lolita", "lolicon", "roricon", "shotacon", "shota", "yaoi", "ecchi", "hentai"]
    
    var nsfwAnimeArray: [Int] = []
    var nsfwMangaArray: [Int] = []
    
    let activityIndicator = UIActivityIndicatorView()
    
    var animeResultsArray: [Results] = []
    var mangaResultsArray: [Results] = []
    var characterResultsArray: [CharacterResults] = []
    var personResultsArray: [PersonResults] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        if #available(iOS 13.0, *) {
            segmentedController.selectedSegmentTintColor = .systemRed
        } else {
            segmentedController.tintColor = .systemRed
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        tableView.isHidden = true
        
        fetchFirebaseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func containsSwearWord(text: String, bannedWords: [String]) -> Bool {
        return bannedWords
            .reduce(false) { $0 || text.contains($1.self) }
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
        
        Database.database().reference().child("MangaCache").child("nsfw").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if !snapshot.exists() {
                return
                
            } else {
                let mangaNfwCache = snapshot.value
                
                self?.nsfwMangaArray = mangaNfwCache as! [Int]
            }
        }
    }
    
    func filterAnimeData() {
        for (index, malId) in animeResultsArray.enumerated().reversed() {
            if nsfwAnimeArray.contains(malId.mal_id ?? 0) {
                animeResultsArray.remove(at: index)
            }
        }
    }
    
    func filterMangaData() {
        for (index, malId) in mangaResultsArray.enumerated().reversed() {
            if nsfwMangaArray.contains(malId.mal_id ?? 0) {
                mangaResultsArray.remove(at: index)
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
    
    func getSearchedData() {
        
        networkManager.getSearchedAnime(name: searchBar.text ?? "") { [weak self] (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self?.animeResultsArray = results
                self?.filterAnimeData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
        
        networkManager.getSearchedManga(name: searchBar.text ?? "") { [weak self] (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self?.mangaResultsArray = results
                self?.filterMangaData()
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
        
        networkManager.getSearchedCharacters(name: searchBar.text ?? "") { [weak self] (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self?.characterResultsArray = results
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
        
        networkManager.getSearchedPeople(name: searchBar.text ?? "") { [weak self] (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self?.personResultsArray = results
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                }
            }
        }
    }
    
    @IBAction func segmentedControllerAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            searchPlacementLabel.isHidden = false
            tableView.isHidden = true
        }

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            tableView.isHidden = true
        } else if containsSwearWord(text: searchBar.text ?? "", bannedWords: bannedSearchWords) == true {
            
            let alert = UIAlertController(title: "You are not allowed to search for this type of content.", message: "This type of content is prohibited on the app store and will not be shown.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "I understand", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
        } else {
            searchPlacementLabel.isHidden = true
            self.activityIndicator.startAnimating()
            getSearchedData()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedController.selectedSegmentIndex == 0 {
            return animeResultsArray.count
        } else if segmentedController.selectedSegmentIndex == 1 {
            return mangaResultsArray.count
        } else if segmentedController.selectedSegmentIndex == 2 {
            return characterResultsArray.count
        } else if segmentedController.selectedSegmentIndex == 3 {
            return personResultsArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as? SearchTableViewCell else { return UITableViewCell() }
        
        let results: Results
        let characterResults: CharacterResults
        let personResults: PersonResults
        
        if segmentedController.selectedSegmentIndex == 0 {
            results = animeResultsArray[indexPath.row]
            
            cell.label.text = results.title ?? ""
            cell.searchImageView.loadImageUsingCacheWithUrlString(urlString: results.image_url ?? "")
            
        } else if segmentedController.selectedSegmentIndex == 1 {
            results = mangaResultsArray[indexPath.row]
            
            cell.label.text = results.title ?? ""
            cell.searchImageView.loadImageUsingCacheWithUrlString(urlString: results.image_url ?? "")
            
        } else if segmentedController.selectedSegmentIndex == 2 {
            characterResults = characterResultsArray[indexPath.row]
            
            cell.label.text = characterResults.name ?? ""
            cell.searchImageView.loadImageUsingCacheWithUrlString(urlString: characterResults.image_url ?? "")
        } else if segmentedController.selectedSegmentIndex == 3 {
            personResults = personResultsArray[indexPath.row]
            
            cell.label.text = personResults.name ?? ""
            cell.searchImageView.loadImageUsingCacheWithUrlString(urlString: personResults.image_url ?? "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let results: Results
        let characterResults: CharacterResults
        let personResults: PersonResults
        
        if segmentedController.selectedSegmentIndex == 0 {
            
            results = animeResultsArray[indexPath.row]
            selection = results.mal_id ?? 0
            self.performSegue(withIdentifier: "searchAnimeDetailsSegue", sender: self)
            
        } else if segmentedController.selectedSegmentIndex == 1 {
            
            results = mangaResultsArray[indexPath.row]
            selection = results.mal_id ?? 0
            self.performSegue(withIdentifier: "searchMangaDetailsSegue", sender: self)
            
        } else if segmentedController.selectedSegmentIndex == 2 {
            
            characterResults = characterResultsArray[indexPath.row]
            selection = characterResults.mal_id ?? 0
            self.performSegue(withIdentifier: "searchCharacterDetailsSegue", sender: self)
            
        } else if segmentedController.selectedSegmentIndex == 3 {
            
            personResults = personResultsArray[indexPath.row]
            selection = personResults.mal_id ?? 0
            self.performSegue(withIdentifier: "searchPersonDetailsSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchAnimeDetailsSegue" {
            let detailsViewController = segue.destination as? DetailsViewController
            
            detailsViewController?.selection = selection
        }
        
        if segue.identifier == "searchMangaDetailsSegue" {
            let mangaDetailsViewController = segue.destination as? MangaDetailsViewController
            
            mangaDetailsViewController?.selection = selection
        }
        
        if segue.identifier == "searchCharacterDetailsSegue" {
            let characterDetailsViewController = segue.destination as? CharacterDetailsViewController
            
            characterDetailsViewController?.selection = selection
        }
        
        if segue.identifier == "searchPersonDetailsSegue" {
            let voiceActorsDetailsViewController = segue.destination as? VoiceActorsDetailsViewController
            
            voiceActorsDetailsViewController?.selection = selection
        }
    }
}
