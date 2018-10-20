//
//  PostTableViewCell.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/18.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var machingButton: UIButton!

    @IBAction func machingButton(_ sender: Any) {
        
    }
    func setPostData(_ postData: PostData) {
        self.postImageView.image = postData.image
        
        self.nameLabel.text = "\(postData.name!)"
        if postData.level == nil {
            self.levelLabel.text = "SL：\(postData.level)"
        }else{
            self.levelLabel.text = "\(postData.level!)"
        }
        self.timeLabel.text = "時間：\(postData.startTime!) 〜 \(postData.endTime!)"
        self.locationLabel.text = "場所：\(postData.location!)"
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
