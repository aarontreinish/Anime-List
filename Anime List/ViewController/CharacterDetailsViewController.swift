//
//  CharacterDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/21/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class CharacterDetailsViewController: UIViewController {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var japaneseNameLabel: UILabel!
    @IBOutlet weak var mainImageView: CustomImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var animeAppearancesCollectionView: UICollectionView!

    
    let activityIndicator = UIActivityIndicatorView()
    
    let networkManager = NetworkManager()
    
    var selection = 0
    
    var screenWillShow = false
    
    var characterDetailsArray: CharacterDetails?
    var voiceActorsArray: [Voice_actors] = []
    var animeAppearancesArray: [Animeography] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        charactersCollectionView.dataSource = self
        charactersCollectionView.delegate = self
        
        animeAppearancesCollectionView.dataSource = self
        animeAppearancesCollectionView.delegate = self
        // Do any additional setup after loading the view.
        
        getCharacterDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationItem.largeTitleDisplayMode = .always
        
        setupActivityIndicator()
        
        
        if screenWillShow == false {
            mainView.isHidden = true
            activityIndicator.startAnimating()
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
    
    func getCharacterDetails() {
        networkManager.getCharacterDetails(id: selection) { [weak self] (characterDetails, error) in
            if let error = error {
                print(error)
            }
            
            if let characterDetails = characterDetails {
                self?.characterDetailsArray = characterDetails
            }
            
            self?.screenWillShow = true
            
            self?.setUpData()
            
            DispatchQueue.main.async {
                self?.setLabels()
                self?.animeAppearancesCollectionView.reloadData()
                self?.charactersCollectionView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.mainView.isHidden = false
            }
        }
    }
    
    func setLabels() {
        self.navigationItem.title = characterDetailsArray?.name
        japaneseNameLabel.text = characterDetailsArray?.name_kanji
        mainImageView.layer.cornerRadius = 10
        mainImageView.loadImageUsingCacheWithUrlString(urlString: characterDetailsArray?.image_url ?? "")
        descriptionLabel.text = characterDetailsArray?.about
    }
    
    func setUpData() {
        for voiceActors in characterDetailsArray?.voice_actors ?? [] {
            voiceActorsArray.append(voiceActors)
        }
        
        for animeAppearances in characterDetailsArray?.animeography ?? [] {
            animeAppearancesArray.append(animeAppearances)
        }
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
        if collectionView == animeAppearancesCollectionView {
            return animeAppearancesArray.count
        } else if collectionView == charactersCollectionView {
            return voiceActorsArray.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == animeAppearancesCollectionView {
            let animeAppearancesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "animeAppearancesCell", for: indexPath) as! CharacterDetailsCollectionViewCell
            
            let animeAppearances: Animeography
            
            animeAppearances = animeAppearancesArray[indexPath.row]
            animeAppearancesCell.voiceActorImageView.loadImageUsingCacheWithUrlString(urlString: animeAppearances.image_url ?? "")
            animeAppearancesCell.nameLabel.text = animeAppearances.name
            
            return animeAppearancesCell
        }
        
        let voiceActorsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceActorsCell", for: indexPath) as! CharacterDetailsCollectionViewCell
        
        let voiceActors: Voice_actors
        
        voiceActors = voiceActorsArray[indexPath.row]
        voiceActorsCell.voiceActorImageView.loadImageUsingCacheWithUrlString(urlString: voiceActors.image_url ?? "")
        voiceActorsCell.nameLabel.text = voiceActors.name
        
        return voiceActorsCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == animeAppearancesCollectionView {
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            
            let animeAppearances: Animeography
            animeAppearances = animeAppearancesArray[indexPath.row]
            
            viewController.selection = animeAppearances.mal_id ?? 0
            self.show(viewController, sender: self)
            
        } else if collectionView == charactersCollectionView {
            let voiceActors: Voice_actors
            voiceActors = voiceActorsArray[indexPath.row]
            selection = voiceActors.mal_id ?? 0
            
            self.performSegue(withIdentifier: "voiceActorsDetailsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceActorsDetailsSegue" {
            let voiceActorsDetailsViewController = segue.destination as? VoiceActorsDetailsViewController
            
            voiceActorsDetailsViewController?.selection = selection
        }
    }
}
