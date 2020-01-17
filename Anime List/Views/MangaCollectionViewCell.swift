//
//  MangaCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class MangaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: CustomImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10.0
        
    }

    
}
