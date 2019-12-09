//
//  HomeCollectionViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/7/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: CustomImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 20.0
        imageView.clipsToBounds = true
        
    }
}
