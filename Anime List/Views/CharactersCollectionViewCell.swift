//
//  CharactersCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/12/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class CharactersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: CustomImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10.0
        
    }
}
