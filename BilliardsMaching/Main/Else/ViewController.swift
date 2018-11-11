//
//  ViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/14.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ESTabBarController

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTab() {
        // 画像のファイル名を指定してESTabBarControllerを作成する
        let tabBarController: ESTabBarController! = ESTabBarController(tabIconNames: ["home","camera","setting"])
        
        // 背景色、選択時の色を設定する
        tabBarController.selectedColor = UIColor.hex(string: "42C24F", alpha: 1)
        tabBarController.buttonsBackgroundColor = UIColor.hex(string: "62D34F", alpha: 0.3)
        
        tabBarController.selectionIndicatorHeight = 3
        
        // 作成したESTabBarControllerを親のViewController（＝self）に追加する
        addChildViewController(tabBarController)
        let tabBarView = tabBarController.view!
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tabBarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            ])
        tabBarController.didMove(toParentViewController: self)
        
        // タブをタップした時に表示するViewControllerを設定する
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: "Home")
        let mypageViewController = storyboard?.instantiateViewController(withIdentifier: "Mypage")
        let chatAllViewController = storyboard?.instantiateViewController(withIdentifier: "ChatAll")
        
        
        tabBarController.setView(homeViewController, at: 0)
        //tabBarController.setView(chatViewController, at: 1)
        tabBarController.setView(chatAllViewController, at: 1)
        //tabBarController.setView(chatOneViewController, at: 1)
        tabBarController.setView(mypageViewController, at: 2)
        
        // 真ん中のタブはボタンとして扱う
        /*tabBarController.highlightButton(at: 1)
        tabBarController.setAction({
            // ボタンが押されたらImageViewControllerをモーダルで表示する
            let createViewController = self.storyboard?.instantiateViewController(withIdentifier: "Create")
            self.present(createViewController!, animated: true, completion: nil)
        }, at: 1)*/
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
}
