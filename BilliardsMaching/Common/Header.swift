//
//  Header.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/16.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

class  header : UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpColor()
    }
    func setUpColor(){
        self.backgroundColor = UIColor.hex(string: "42C24F", alpha: 1)
        self.textColor = UIColor.white
        self.font = UIFont.boldSystemFont(ofSize: 17)
    }
}
