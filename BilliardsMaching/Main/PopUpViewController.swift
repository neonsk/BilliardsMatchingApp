//
//  PopUpViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/19.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class PopupViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTapMaching(_ sender: Any) {
        
        SVProgressHUD.showSuccess(withStatus: "申し込みしました！")
        self.dismiss(animated: false, completion: nil)
    }
    // 閉じるボタンがタップされた時
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    /*// ポップアップの外側をタップした時にポップアップを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var tapLocation: CGPoint = CGPoint()
        // タッチイベントを取得する
        let touch = touches.first
        // タップした座標を取得する
        tapLocation = touch!.location(in: self.view)
        
        let popUpView: UIView = self.view.viewWithTag(100)! as UIView
        
        if !popUpView.frame.contains(tapLocation) {
            self.dismiss(animated: false, completion: nil)
        }
    }*/
    
}
