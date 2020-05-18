//
//  SeeAllTableViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 5/18/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import UIKit

class SeeAllTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var mainImageView: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainImageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
