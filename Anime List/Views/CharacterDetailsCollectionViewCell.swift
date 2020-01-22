//
//  CharacterDetailsCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/21/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class CharacterDetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var voiceActorImageView: CustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        voiceActorImageView.layer.cornerRadius = 10.0
        
    }
}
