//
//  CreateViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/14.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateViewController: UIViewController {
    
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func checkInButton(_ sender: Any) {
        if let location = locationTextField.text, let startTime = startTextField.text, let endTime = endTextField.text {
            if location.isEmpty || startTime.isEmpty || endTime.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
        
            let name = Auth.auth().currentUser?.displayName
            let postRef = Database.database().reference().child(Const.PostPath)
            let postDic = ["name": name, "location": location, "startTime":startTime, "endTime":endTime]
            postRef.childByAutoId().setValue(postDic)
            SVProgressHUD.showSuccess(withStatus: "チェックインしました！")
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
