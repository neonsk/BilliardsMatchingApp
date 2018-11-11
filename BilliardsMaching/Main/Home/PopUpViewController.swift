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

enum PopupViewControllerResult {
    case delete
    case cancel
}

protocol PopupViewControllerDelegate {
    func popupViewControllerDidSelect(resutl : PopupViewControllerResult, postDataId: String)
}

class PopupViewController: UIViewController {
    
    var delegate : PopupViewControllerDelegate?
    
    var myDisplayName=""
    var postDataId: String?
    var postDataUserId: String?
    @IBOutlet weak var machingButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    var machingFlag : Int = 0
    var myPostFlag = 0
    let now = NSDate()
    let formatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        if machingFlag == 1 {
            machingButton.setTitle("申し込み済み", for: .normal)
        }
        if self.myPostFlag == 1 {
            topLabel.text = "投稿を削除しますか？"
            cancelButton.setTitle("する", for: .normal)
            machingButton.setTitle("しない", for: .normal)
        }
    }
    @IBAction func onTapMaching(_ sender: Any) {
        //自分以外の投稿者の場合
        if myPostFlag == 0{
            print("popupView.machingFlag = \(machingFlag)")
            if machingFlag == 1 {
                print("申請済み")
                machingButton.isEnabled = false
            }else{
                let postTime = formatter.string(from: now as Date)
                machingButton.isEnabled = true
                // Firebaseに保存するデータの準備
                if let uid = Auth.auth().currentUser?.uid {
                    let postRef = Database.database().reference().child(Const.PostPath).child(postDataId!)
                    print("postRef = \(postRef)")
                    postRef.child("maching").updateChildValues(["\(uid)": "flag"])
                    
                    myDisplayName = (Auth.auth().currentUser?.displayName!)!
                    let chatRefMyId = Database.database().reference().child("chats").child(uid)
                    let chatDic  = ["talks":"申し込みを行いました！","postUserID":"\(uid)","postUserDisplayName":myDisplayName,"postTime":postTime]
                    chatRefMyId.child("\(postDataUserId!)").childByAutoId().setValue(chatDic)
                    
                    let chatRefPostUserId = Database.database().reference().child("chats").child(postDataUserId!)
                    chatRefPostUserId.child("\(uid)").childByAutoId().setValue(chatDic)
                }
                SVProgressHUD.showSuccess(withStatus: "申し込みしました！")
                self.dismiss(animated: false, completion: nil)
            }
        }else{
            //自分の投稿の場合
            myPostFlag = 0
            self.dismiss(animated: false, completion: nil)
        }
    }
    // 閉じるボタンがタップされた時
    @IBAction func onTapCancel(_ sender: UIButton) {
        //自分以外の投稿の場合
        if myPostFlag == 0{
            self.dismiss(animated: false, completion: nil)
        }else{
            self.dismiss(animated: true, completion: {
                self.delegate?.popupViewControllerDidSelect(resutl: .delete, postDataId: self.postDataId!)                
            })
        }
    }
}
