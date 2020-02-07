//
//  SearchViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/26/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchPlacementLabel: UILabel!
    
    var networkManager = NetworkManager()
    
    var selection = 0
    
    let activityIndicator = UIActivityIndicatorView()
    
    var animeResultsArray: [Results] = []
    var mangaResultsArray: [Results] = []
    var characterResultsArray: [CharacterResults] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        
        networkManager.getSearchedAnime(name: searchBar.text ?? "") { (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self.animeResultsArray = results
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
        
        networkManager.getSearchedManga(name: searchBar.text ?? "") { (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self.mangaResultsArray = results
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
        
        networkManager.getSearchedCharacters(name: searchBar.text ?? "") { (results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results {
                self.characterResultsArray = results
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
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
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as? SearchTableViewCell else { return UITableViewCell() }
        
        let results: Results
        let characterResults: CharacterResults
        
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let results: Results
        let characterResults: CharacterResults
        
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
    }
}
