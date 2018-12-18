//
//  MypageDisplayViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/25.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

class MypageDisplayViewController : UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let setStatusBar = SetStatusBar()
        setStatusBar.setUp(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
