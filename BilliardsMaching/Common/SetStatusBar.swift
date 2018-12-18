//
//  SetStatusBar.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/11.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit


class SetStatusBar : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func setUp(_ selfView : UIView){
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: -20.0))
        statusBar.backgroundColor = UIColor.hex(string: "42C24F", alpha: 1)
        selfView.addSubview(statusBar)
    }
}
