//
//  VideoTableViewCell.swift
//  Vid.me
//
//  Created by Artem Tverdokhlebov on 5/8/17.
//  Copyright © 2017 Artem Tverdokhlebov. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var videoPreviewView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoLikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let screenWidth = UIScreen.main.bounds.width

        self.videoPreviewView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        
        if let image = self.videoPreviewView.image {
            self.videoPreviewView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: ((screenWidth * image.size.height) / image.size.width))
        }
    }
}
