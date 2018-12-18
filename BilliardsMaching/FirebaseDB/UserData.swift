
//
//  UserData.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/19.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserData: NSObject {
    var uid: String?
    var name: String?
    var sex: String?
    var prefecture: String?
    var hometown: String?
    var skillLevel: String?
    var introduce: String?
    var profileURL: String?
    var nowPostFlag: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        self.uid = snapshot.key
        let valueDictionary = snapshot.value as! [String: Any]
        self.name = valueDictionary["name"] as? String 
        self.sex = valueDictionary["sex"] as? String
        self.prefecture = valueDictionary["prefecture"] as? String
        self.hometown = valueDictionary["hometown"] as? String
        self.skillLevel = valueDictionary["skillLevel"] as? String
        self.introduce = valueDictionary["introduce"] as? String
        self.profileURL = valueDictionary["profileURL"] as? String
        self.nowPostFlag = valueDictionary["nowPostFlag"] as? String
    }
}
