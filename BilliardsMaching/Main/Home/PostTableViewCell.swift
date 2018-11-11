//
//  PostTableViewCell.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/18.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var machingButton: UIButton!
    
    let now = NSDate()
    let formatter = DateFormatter()
    var type = postType.me
    let ButtonClass = buttonClass()
    
    @IBAction func machingButton(_ sender: Any) {
        
    }
    enum postType{
        case me
        case other
    }
    func setPostData(_ postData: PostData) {
        
        guard let name = postData.name else {
            print("からっぽ")
            return
        }
        
        self.postImageView.image = postData.image
        postImageView.layer.cornerRadius = postImageView.frame.width/2
        postImageView.clipsToBounds = true
        self.nameLabel.text = "\(postData.name!)"
        if self.nameLabel.text == Auth.auth().currentUser?.displayName {
            type = postType.me
            machingButton.setTitle("投稿の削除", for: .normal)
            ButtonClass.postOther(machingButton)
        }else{
            type = postType.other
            machingButton.setTitle("申し込み", for: .normal)
            ButtonClass.setUp()
        }
        if postData.level == nil {
            self.levelLabel.text = "SL：-"
        }else{
            self.levelLabel.text = "SL：\(postData.level!)"
        }
        
        self.formatter.dateFormat = "yyyy/MM/dd"
        let today = self.formatter.string(from: now as Date)
        if today == postData.date!{
            self.timeLabel.text = "日時：本日（\(postData.startTime!) 〜 \(postData.endTime!)）"
        }else{
            self.timeLabel.text = "日時：\(postData.date!)（\(postData.startTime!) 〜 \(postData.endTime!)）"
        }
        
        self.locationLabel.text = "場所：\(postData.location!)"
        
        //Profile写真を取得
        let uid = postData.userId!
        let userRef = Database.database().reference().child(Const.User).child(uid)
        print("--------------------setPostData")
        print("postData.id = \(postData.id!)")
        print("postData.uid = \(postData.userId!)")
        userRef.observe(.value, with: { snapshot in
            let userData = UserData(snapshot: snapshot, myId: uid)
            let islandRef = Storage.storage().reference().child(userData.profileURL!)
            islandRef.getData(maxSize: 300 * 1024 * 1024) { data, error in
                if let error = error {
                    print("--- error start")
                    print("error = \(error)")
                    print("--- error end")
                    self.postImageView.image = UIImage(named:"noImage.jpg")!
                } else {
                    let image = UIImage(data: data!)
                    self.postImageView.image = image!
                }
            }
        })
        
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
