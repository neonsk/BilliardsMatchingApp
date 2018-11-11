//
//  UIView+Extension.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/04.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

extension UIView {
    
    
    func test () {
        var hoge = HOGE(aaa: 3)
        
        hoge.bbb()
        
    }
    
}



class HOGE {
    var a : Int = 1
    
    init(aaa : Int ) {
        
    }
    
}

extension HOGE {
    func bbb() {

    }
}
