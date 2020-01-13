//
//  DetailsTableViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/12/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit
import WebKit

class DetailsTableViewCell: UITableViewCell {


    @IBOutlet weak var detailsImageView: CustomImageView!
    
    @IBOutlet weak var labelView: UIView!
    
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var episodesLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    
    @IBOutlet weak var recommendationsCollectionView: UICollectionView!
    
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
    
    func loadYoutube(url: String) {
        guard let youtubeURL = URL(string: url) else { return }
        webView.load(URLRequest(url: youtubeURL))
    }
    
    func setCharactersCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout, forRow row: Int) {
        
        charactersCollectionView.delegate = dataSourceDelegate
        charactersCollectionView.dataSource = dataSourceDelegate
        charactersCollectionView.tag = row
        charactersCollectionView.reloadData()
    }
    
    func setRecommendationsCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout, forRow row: Int) {
        
        recommendationsCollectionView.delegate = dataSourceDelegate
        recommendationsCollectionView.dataSource = dataSourceDelegate
        recommendationsCollectionView.tag = row
        recommendationsCollectionView.reloadData()
    }


}
