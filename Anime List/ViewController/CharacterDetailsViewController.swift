//
//  CharacterDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/21/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class CharacterDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let networkManager = NetworkManager()
    
    var selection = 0
    
    var characterDetailsArray: CharacterDetails?
    var voiceActorsArray: [Voice_actors] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        getCharacterDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationItem.largeTitleDisplayMode = .always
        
        setupActivityIndicator()
        
        tableView.isHidden = true
        activityIndicator.startAnimating()
        
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
    
    func getCharacterDetails() {
        networkManager.getCharacterDetails(id: selection) { [weak self] (characterDetails, error) in
            if let error = error {
                print(error)
            }
            
            if let characterDetails = characterDetails {
                self?.characterDetailsArray = characterDetails
            }
            
            self?.setUpData()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }
    }
    
    func setUpData() {
        for voiceActors in characterDetailsArray?.voice_actors ?? [] {
            voiceActorsArray.append(voiceActors)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "characterDetailsCell") as? CharacterDetailsTableViewCell else { return UITableViewCell() }
        
        cell.characterImageView.loadImageUsingCacheWithUrlString(urlString: characterDetailsArray?.image_url ?? "")
        cell.descriptionLabel.text = characterDetailsArray?.about
        cell.japaneseNameLabel.text = characterDetailsArray?.name_kanji
        cell.nameLabel.text = characterDetailsArray?.name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let characterDetailsTableViewCell = cell as? CharacterDetailsTableViewCell else { return }
        
        characterDetailsTableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
    }
}


extension CharacterDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 132.0, height: collectionView.bounds.height)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voiceActorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let voiceActorsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceActorsCell", for: indexPath) as! CharacterDetailsCollectionViewCell
        
        let voiceActors: Voice_actors
        
        voiceActors = voiceActorsArray[indexPath.row]
        voiceActorsCell.voiceActorImageView.loadImageUsingCacheWithUrlString(urlString: voiceActors.image_url ?? "")
        voiceActorsCell.nameLabel.text = voiceActors.name
        
        return voiceActorsCell
        
    }
}
