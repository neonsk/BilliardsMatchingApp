//
//  MypageViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/14.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import SVProgressHUD
import CLImageEditor
import FirebaseStorage
import FirebaseUI

class MypageViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLImageEditorDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var prefectureTextField: UITextField!
    @IBOutlet weak var hometownTextField: UITextField!
    @IBOutlet weak var skillLevelTextField: UITextField!
    @IBOutlet weak var introduceTextField: UITextField!
    
    var observing = false
    var currentUid : String = ""
    var profileUploadFlag : profileImageUploadFlag = .not
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        currentUid = uid!
        profileImageView.image = UIImage(named: "noImage.jpg")!
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.clipsToBounds = true
        let setStatusBar = SetStatusBar()
        setStatusBar.setUp(self.view)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("----------------------: Mypage")
        
        if let u = Auth.auth().currentUser?.uid{
            let uid = u as! String
            if self.currentUid != uid {
                print("-------------：ユーザーが変更されました")
                self.profileImageView.image = UIImage(named:"noImage.jpg")!
            }
            self.currentUid = uid
            
            if self.observing == false{
                let userRef = Database.database().reference().child(Const.User).child(uid)
                userRef.observe(.value, with: { snapshot in
                    if self.profileUploadFlag == .upload{
                        return
                    }
                    print("uid = \(uid)")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        let userData = UserData(snapshot: snapshot, myId: uid)
                        self.nameLabel.text = userData.name
                        self.sexTextField.text = userData.sex
                        self.prefectureTextField.text = userData.prefecture
                        self.hometownTextField.text = userData.hometown
                        self.skillLevelTextField.text = userData.skillLevel
                        self.introduceTextField.text = userData.introduce
                        
                        
                        /*
                        //Profile写真、sd_setImageから取得する方法
                        let storageRef = Storage.storage().reference()
                        let profileRef = storageRef.child(userData.profileURL!)
                        print("profileRef = \(profileRef)")
                        self.profileImageView?.sd_setImage(with: profileRef, placeholderImage: nil)
                        */
 
                         SVProgressHUD.show(withStatus: "画像を読み込み中")
                        print("currentUid = \(self.currentUid), uid=\(uid)")
                        if self.currentUid == uid {
                            let islandRef = Storage.storage().reference().child(userData.profileURL!)
                            islandRef.getData(maxSize: 300 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("error = \(error)")
                                } else {
                                    let image = UIImage(data: data!)
                                    self.profileImageView.image = image!
                                }
                            }
                        }
                        SVProgressHUD.dismiss()
                        
                    }
                })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(0, animated: false)
    }
    @IBAction func updateButton(_ sender: Any) {
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child(Const.User).child(uid!)
        let userDic = ["name": user?.displayName,"sex": sexTextField.text!, "prefecture":prefectureTextField.text!, "hometown":hometownTextField.text!, "skillLevel": skillLevelTextField.text!, "introduce": introduceTextField.text!]
        userRef.updateChildValues(userDic)
        SVProgressHUD.showSuccess(withStatus: "プロフィールを更新しました")
    }
    
    @IBAction func imageUpload(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            picker.pushViewController(editor, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    enum profileImageUploadFlag{
        case upload
        case not
    }
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        print("// CLImageEditorで加工が終わったときに呼ばれるメソッド")
        profileUploadFlag = .upload
        let uid = Auth.auth().currentUser?.uid
        let scaleSize = 0.05
        let sizeWidth = image.size.width
        let sizeHeight = image.size.height
        print("image width = \(sizeWidth),  height = \(sizeHeight)")
        let resizeImage = image.reSizeImage(reSize: CGSize(width: Double(sizeWidth) * scaleSize, height: Double(sizeHeight) * scaleSize))
        print("resizeImage width = \(resizeImage.size.width),  height = \(resizeImage.size.height)")
        self.profileImageView.image = resizeImage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        if let data = UIImagePNGRepresentation(resizeImage) {
            let reference = storageRef.child("images/" + uid! + "/" + "profile.jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                let userRef = Database.database().reference().child(Const.User).child(uid!)
                userRef.updateChildValues(["profileURL": "images/" + uid! + "/" + "profile.jpg"])
                print(metaData as Any)
                print(error as Any)
                print("アップロード完了")
                self.profileUploadFlag = .not
                
            })
            dismiss(animated: true, completion: nil)
        }
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
