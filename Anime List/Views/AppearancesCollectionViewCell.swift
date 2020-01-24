//
//  AppearancesCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/24/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class AppearancesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var animeImageView: CustomImageView!
    @IBOutlet weak var characterImageView: CustomImageView!
    
    @IBOutlet weak var animeTitleLabel: UILabel!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterRoleLabel: UILabel!
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        animeImageView.layer.cornerRadius = 10.0
        characterImageView.layer.cornerRadius = 10.0
        
    }
}
