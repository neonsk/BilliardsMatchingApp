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

class CreateViewController: UIViewController{
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    var datePicker: UIDatePicker = UIDatePicker()
    
    let now = Date()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let timePlusFormatter = DateFormatter()
    var createDate = ""
    var createFlag = "0"
    
    @IBAction func checkInButton(_ sender: Any) {
        if let location = locationTextField.text, let startTime = startTextField.text, let endTime = endTextField.text, let date = dateTextField.text {
            let uid = Auth.auth().currentUser?.uid
            let name = Auth.auth().currentUser?.displayName
            let userRef = Database.database().reference().child(Const.User)
            if location.isEmpty || startTime.isEmpty || endTime.isEmpty || date.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            //投稿データ用
            userRef.child(uid!).observe(.value, with: { snapshot in
                if self.createFlag == "0" {
                    let userData = UserData(snapshot: snapshot, myId: uid!)
                    let imageString = userData.profileURL
                    let postRef = Database.database().reference().child(Const.PostPath)
                    let postDic = ["name": name, "location": location, "startTime":startTime, "endTime":endTime, "imageString": imageString!, "userId": uid!, "level": userData.skillLevel!, "date":date]
                    postRef.childByAutoId().setValue(postDic)
                    self.createFlag = "1"
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            SVProgressHUD.showSuccess(withStatus: "チェックインしました！")
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.dateFormatter.dateFormat = "yyyy/MM/dd"
        self.createDate = self.dateFormatter.string(from: now as Date)
        dateTextField.text = createDate
        self.timeFormatter.dateFormat = "HH:mm"
        self.createDate = self.timeFormatter.string(from: now as Date)
        startTextField.text = createDate
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ページを去りました。createFlag = \(self.createFlag)")
        let userRef = Database.database().reference().child(Const.User)
        let uid = Auth.auth().currentUser?.uid
        userRef.child(uid!).child("nowPostFlag").setValue("\(self.createFlag)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func thiryMinButton(_ sender: Any) {
        let nowPlus = Date(timeInterval: 60*30, since: now)
        endTextFieldSetting(nowPlus)
    }
    
    @IBAction func sixtyMinButton(_ sender: Any) {
        let nowPlus = Date(timeInterval: 60*60, since: now)
        endTextFieldSetting(nowPlus)
    }
    
    @IBAction func ninetyMinButton(_ sender: Any) {
        let nowPlus = Date(timeInterval: 60*90, since: now)
        endTextFieldSetting(nowPlus)
    }
    @IBAction func twoHoursButton(_ sender: Any) {
        let nowPlus = Date(timeInterval: 60*120, since: now)
        endTextFieldSetting(nowPlus)
    }
    @IBAction func noLimitButton(_ sender: Any) {
        self.endTextField.text  = "未定"
    }
    func endTextFieldSetting (_ nowPlus : Date){
        self.timePlusFormatter.dateFormat = "HH:mm"
        self.createDate = self.timePlusFormatter.string(from: nowPlus as Date)
        self.endTextField.text  = self.createDate
    }
    
    
    /*
    //開始時間と終了時間にdatePickerを適用
    func setPickerView(){
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(CreateViewController.doneStartTextField))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(CreateViewController.cancelStartTextField))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.startTextField.inputView = self.datePicker
        self.startTextField.inputAccessoryView = toolbar
        
        datePicker.frame = CGRect(x:0, y:self.view.frame.height / 2 - 150, width:self.view.frame.width, height:300)
        //タイムゾーンの設定
        datePicker.timeZone = NSTimeZone.local
        //datePickerをViewに追加
        self.view.addSubview(datePicker)
    }
    @objc func cancelStartTextField() {
        self.startTextField.text = ""
        self.startTextField.endEditing(true)
    }
    
    @objc func doneStartTextField() {
        self.startTextField.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
     */
    
}
