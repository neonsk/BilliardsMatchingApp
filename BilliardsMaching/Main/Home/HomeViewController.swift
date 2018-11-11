//
//  HomeViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/14.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

extension HomeViewController : PopupViewControllerDelegate {
    func popupViewControllerDidSelect(resutl: PopupViewControllerResult, postDataId: String) {
        if resutl == .delete {
            
            //自分の投稿の場合
            let postDataRef = Database.database().reference().child(Const.PostPath).child(postDataId)
            postDataRef.removeValue()
            
            let userRef = Database.database().reference().child(Const.User)
            let uid = Auth.auth().currentUser?.uid
            
            userRef.child(uid!).child("nowPostFlag").setValue("0")
        }
        else {
        }
        self.tableView.reloadData()
    }
}

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var postArray: [PostData] = []
    var observing = false // DatabaseのobserveEventの登録状態を表す
    var refreshControl:UIRefreshControl!
    var popupIndex: Int = 0
    var command = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: Viewdidload")
        tableViewSet()
    }
    
    func fetchPosts() {
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。snapshot = \(snapshot)")
            
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                self.postArray.insert(postData, at: 0)
                
                // TableViewを再表示する
                self.tableView.reloadData()
            }
        })
        postsRef.observe(.childChanged, with: { snapshot in
            print("DEBUG_PRINT: .childChangedイベントが発生しました。")
            
            if let uid = Auth.auth().currentUser?.uid {
                // PostDataクラスを生成して受け取ったデータを設定する
                let postData = PostData(snapshot: snapshot, myId: uid)
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                for post in self.postArray {
                    if post.id == postData.id {
                        index = self.postArray.index(of: post)!
                        break
                    }
                }
                // 差し替えるため一度削除する
                self.postArray.remove(at: index)
                // 削除したところに更新済みのデータを追加する
                self.postArray.insert(postData, at: index)
                // TableViewを再表示する
                self.tableView.reloadData()
            }
        })
        postsRef.observe(.childRemoved, with: { snapshot in
            print("ChildRemoved")
            if let uid = Auth.auth().currentUser?.uid {
                // PostDataクラスを生成して受け取ったデータを設定する
                let postData = PostData(snapshot: snapshot, myId: uid)
                var index :Int? = nil
                for (idx, post) in self.postArray.enumerated() {
                    if let idd = post.id {
                            if idd == postData.id! {
                            index = idx
                        }
                    }
                }
                if let idx = index {
                    self.postArray.remove(at: idx)
                }
                self.tableView.reloadData()
            }
        })
        // DatabaseのobserveEventが上記コードにより登録されたため
        // trueとする
        observing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                self.fetchPosts()
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.machingButton.addTarget(self, action:#selector(machingButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    //申し込みのボタンをタップ
    @IBAction func machingButton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = postArray[indexPath!.row]
        self.popupIndex = indexPath!.row
        print("indexPath! = \(indexPath!)")
        print("indexPath!.row = \(indexPath!.row)")
        
        //popupViewに値を渡す
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupView: PopupViewController = storyBoard.instantiateViewController(withIdentifier: "popupView") as! PopupViewController
        popupView.postDataId = postData.id
        popupView.postDataUserId = postData.userId
        popupView.delegate = self
        
        let uid = Auth.auth().currentUser?.uid
        if postData.userId == uid! {
            popupView.myPostFlag = 1
        }
        
        //popupViewに遷移
        popupView.modalPresentationStyle = .overFullScreen
        popupView.modalTransitionStyle = .crossDissolve
        self.present(popupView, animated: false, completion: nil)
    }
    
    //createViewCotrollerへ遷移
    enum createButton {
        case push
        case noPush
    }
    @IBAction func checkInButton(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child(Const.User)
        var flag = ""
        var createButtonFlag = createButton.push
        userRef.child(uid!).observe(.value, with: { snapshot in
            switch createButtonFlag {
            case .push:
                let userData = UserData(snapshot: snapshot, myId: uid!)
                flag = userData.nowPostFlag!
                if flag == "1" {
                    SVProgressHUD.showError(withStatus: "既に投稿中です")
                    createButtonFlag = createButton.noPush
                    return
                }else{
                    createButtonFlag = createButton.noPush
                    let createViewController = self.storyboard?.instantiateViewController(withIdentifier: "Create")
                    self.present(createViewController!, animated: true, completion: nil)
                }
            case .noPush:
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    @objc func refresh(){
        print("refresh実行")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
//    func myPostDelete(){
//        //popupViewにて自分の投稿を削除した時
//        print("tableview = \(tableView)")
//        print("command " + self.command)
////        if command == "delete"{
////            let postsRef = Database.database().reference().child(Const.PostPath)
////            postsRef.observe(.value, with: { snapshot in
//                print("DEBUG_PRINT: .ChildがDeleteされました。")
//                if let uid = Auth.auth().currentUser?.uid {
//                    let postData = PostData(snapshot: snapshot, myId: uid)
//                    self.postArray.insert(postData, at: 0)
//                }
//                print("削除後：postArray = \(self.postArray)")
//                //self.tableView.reloadData()
//
//                self.command = ""
////                self.tableView.beginUpdates()
////                self.tableView.reloadData()
////                self.tableView.endUpdates()
////                DispatchQueue.main.async {
////                }
//            })
//        }
//    }
    
    func tableViewSet(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
        
        
        //下に引っ張って更新
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action:#selector(refresh), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
