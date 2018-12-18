//
//  PostData.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/18.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
    var userId: String?
    var name: String?
    var location: String?
    var date: String?
    var startTime: String?
    var endTime: String?
    var level: String?
    var image: UIImage?
    var imageString: String?
    var maching: [String] = []
    var isMaching: Bool = false
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: Any]
        self.userId = valueDictionary["userId"] as? String
        self.name = valueDictionary["name"] as? String
        self.location = valueDictionary["location"] as? String
        self.date = valueDictionary["date"] as? String
        self.startTime = valueDictionary["startTime"] as? String
        self.endTime = valueDictionary["endTime"] as? String
        self.level = valueDictionary["level"] as? String
        self.imageString = valueDictionary["imageString"] as? String
        if let maching = valueDictionary["maching"] as? [String] {
            self.maching = maching
        }
        for machingId in self.maching {
            if machingId == myId {
                self.isMaching = true
                break
            }
        }

    }
}
