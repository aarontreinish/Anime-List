//
//  MangaDetailsTableViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 1/17/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit
import WebKit

class MangaDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailsImageView: CustomImageView!
    
    @IBOutlet weak var labelView: UIView!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var volumesLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        detailsImageView.layer.cornerRadius = 10.0
        
        genreLabel.preferredMaxLayoutWidth = labelView.bounds.size.width
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setCharactersCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
}
