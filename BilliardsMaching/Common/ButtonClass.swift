//
//  ButtonClass.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/08.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

class  buttonClass : UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    func setUp(){
        self.backgroundColor = UIColor.hex(string: "62D34F", alpha: 1)
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 10.0
    }
    func postOther(_ button : UIButton){
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10.0
    }
}
