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
    var name: String?
    var location: String?
    var startTime: String?
    var endTime: String?
    var level: String?
    var image: UIImage?
    var imageString: String?
    var maching: [String] = []
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: Any]
        
        //imageString = valueDictionary["image"] as? String
        //image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
        self.name = valueDictionary["name"] as? String
        self.location = valueDictionary["location"] as? String
        self.startTime = valueDictionary["startTime"] as? String
        self.endTime = valueDictionary["endTime"] as? String
        self.level = valueDictionary["level"] as? String
        if let maching = valueDictionary["maching"] as? [String] {
            self.maching = maching
        }

    }
}
