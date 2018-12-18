//
//  ChatData.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/22.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatData: NSObject {
    var userId: String?
    var talks: String?
    var postUserID: String?
    var postUserDisplayName: String?
    var postTime: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        self.userId = snapshot.key
        let valueDictionary = snapshot.value as! [String: Any]
        self.talks = valueDictionary["talks"] as? String
        self.postUserID = valueDictionary["postUserID"] as? String
        self.postUserDisplayName = valueDictionary["postUserDisplayName"] as? String
        self.postTime = valueDictionary["postTime"] as? String
    }
}
