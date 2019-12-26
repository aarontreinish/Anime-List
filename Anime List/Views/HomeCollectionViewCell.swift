//
//  HomeCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/7/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10.0
        imageView.clipsToBounds = true
        
    }
}
