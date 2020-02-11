//
//  VoiceActorsDetailsViewController.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/24/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class VoiceActorsDetailsViewController: UIViewController {
    
    @IBOutlet weak var appearancesCollectionView: UICollectionView!
    
    var networkManager = NetworkManager()
    
    let activityIndicator = UIActivityIndicatorView()
    
    var selection = 0
    
    var selectedImage = 0
    
    var voiceActorsObject: VoiceActors?
    var voiceActingRolesArray: [Voice_acting_roles] = []
    
    var screenWillShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appearancesCollectionView.dataSource = self
        appearancesCollectionView.delegate = self
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupActivityIndicator()
        
        if screenWillShow == false {
            activityIndicator.startAnimating()
            appearancesCollectionView.isHidden = true
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
    
    func getData() {
        networkManager.getVoiceActorsDetials(id: selection) { [weak self] (voiceActors, error) in
            if let error = error {
                print(error)
            }
            
            if let voiceActors = voiceActors {
                self?.voiceActorsObject = voiceActors
            }
            
            self?.screenWillShow = true
            
            DispatchQueue.main.async {
                self?.setUpLabels()
                self?.appearancesCollectionView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.appearancesCollectionView.isHidden = false
            }
        }
    }
    
    func setUpLabels() {
        
        for roles in voiceActorsObject?.voice_acting_roles ?? [] {
            voiceActingRolesArray.append(roles)
        }
        self.navigationItem.title = voiceActorsObject?.name
        
    }
    
}

extension VoiceActorsDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 398.0, height: 110.0)
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
          let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerView",
            for: indexPath) as? VoiceActorsDetailsHeaderView
          else {
            fatalError("Invalid view type")
        }
        
        headerView.imageView.loadImageUsingCacheWithUrlString(urlString: voiceActorsObject?.image_url ?? "")
        headerView.japaneseNameLabel.text = voiceActorsObject?.family_name
        headerView.descriptionLabel.text = voiceActorsObject?.about
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        // Get the view for the first header
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        // Use this view to calculate the optimal size based on the collection view's width
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required, // Width is fixed
                                                  verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voiceActingRolesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let voiceActorsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceActorsCell", for: indexPath) as! AppearancesCollectionViewCell
        
        let voiceActingRoles: Voice_acting_roles
        
        voiceActingRoles = voiceActingRolesArray[indexPath.row]
        
        voiceActorsCell.animeImageView.loadImageUsingCacheWithUrlString(urlString: voiceActingRoles.anime?.image_url ?? "")
        voiceActorsCell.animeTitleLabel.text = voiceActingRoles.anime?.name
        
        voiceActorsCell.characterImageView.loadImageUsingCacheWithUrlString(urlString: voiceActingRoles.character?.image_url ?? "")
        voiceActorsCell.characterNameLabel.text = voiceActingRoles.character?.name
        voiceActorsCell.characterRoleLabel.text = voiceActingRoles.role
        
        let animeImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animeImageTapped))
        let characterImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(characterImageTapped))
        
        voiceActorsCell.animeImageView.isUserInteractionEnabled = true
        voiceActorsCell.animeImageView.tag = indexPath.row
        voiceActorsCell.animeImageView.addGestureRecognizer(animeImageTapGestureRecognizer)
        
        voiceActorsCell.characterImageView.isUserInteractionEnabled = true
        voiceActorsCell.characterImageView.tag = indexPath.row
        voiceActorsCell.characterImageView.addGestureRecognizer(characterImageTapGestureRecognizer)
        
        return voiceActorsCell
    }
    
    @objc func animeImageTapped(gesture: UITapGestureRecognizer) {
        
        if (gesture.view as? UIImageView) != nil {
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            
            self.selectedImage = gesture.view?.tag ?? 0
            
            let voiceActorRole: Voice_acting_roles
            
            voiceActorRole = voiceActingRolesArray[selectedImage]
            viewController.selection = voiceActorRole.anime?.mal_id ?? 0
            
            self.show(viewController, sender: self)
        }
    }
    
    @objc func characterImageTapped(gesture: UITapGestureRecognizer) {
        
        if (gesture.view as? UIImageView) != nil {
            
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CharacterDetailsViewController") as! CharacterDetailsViewController
            
            self.selectedImage = gesture.view?.tag ?? 0
            
            let voiceActorRole: Voice_acting_roles
            
            voiceActorRole = voiceActingRolesArray[selectedImage]
            viewController.selection = voiceActorRole.character?.mal_id ?? 0
            
            self.show(viewController, sender: self)
        }
    }
}

class VoiceActorsDetailsHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet weak var japaneseNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10
    }
    
}
