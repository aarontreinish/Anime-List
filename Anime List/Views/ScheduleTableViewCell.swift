//
//  ScheduleTableViewCell.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/23/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scheduleImageView: CustomImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
