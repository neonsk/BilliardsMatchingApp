//
//  ChatTableViewCell.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/22.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var talkLabel: UILabel!
    @IBOutlet weak var jumpChatButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func jumpChatButton(_ sender: Any) {
    }
    func setChatData(_ chatData: ChatData) {
        let userId = chatData.userId!
        //Profile写真を取得
        let myUid = (Auth.auth().currentUser?.uid)!
        let userRef = Database.database().reference().child(Const.User).child(userId)
        userRef.observe(.value, with: { snapshot in
            let userData = UserData(snapshot: snapshot, myId: userId)
            let islandRef = Storage.storage().reference().child(userData.profileURL!)
            islandRef.getData(maxSize: 300 * 1024 * 1024) { data, error in
                if let error = error {
                    print("--- error start")
                    print("error = \(error)")
                    print("--- error end")
                    self.profileImageView.image = UIImage(named:"noImage.jpg")!
                } else {
                    let image = UIImage(data: data!)
                    self.profileImageView.image = image!
                }
            }
            self.userLabel.text = userData.name!
        })
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width * 0.1
    }
    
}
