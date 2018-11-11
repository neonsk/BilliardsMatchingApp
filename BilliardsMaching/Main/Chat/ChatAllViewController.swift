//
//  ChatAllViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/22.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

extension ChatAllViewController : UITableViewDelegate {
    
}

extension ChatAllViewController : UITableViewDataSource {
    
}

class ChatAllViewController: UIViewController{
    
    @IBOutlet weak var noMachingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var chatArray: [ChatData] = []
    var observing = false // DatabaseのobserveEventの登録状態を表す
    var currentUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: Viewdidload")
        let uid = Auth.auth().currentUser?.uid
        currentUid = uid
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatCell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: ChatAllViewWillAppear---------------")
        self.noMachingLabel.isHidden = true
        let uid = Auth.auth().currentUser?.uid
        print("currentUid = \(currentUid!)")
        print("uid = \(uid!)")
        if self.currentUid! != uid! {
            print("-------------：ユーザーが変更されました")
            chatArray = [] // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
            tableView.reloadData()
            Database.database().reference().removeAllObservers() // オブザーバーを削除する
            observing = false
        }
        self.currentUid = uid
        print("currentUid = \(currentUid!)")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableVriewを再表示する
                let chatsRef = Database.database().reference().child(Const.Chat).child((Auth.auth().currentUser?.uid)!)
                chatsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        
                        let chatData = ChatData(snapshot: snapshot, myId: uid)
                        self.chatArray.insert(chatData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                chatsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let chatData = ChatData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for chat in self.chatArray {
                            if chat.userId == chatData.userId {
                                index = self.chatArray.index(of: chat)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.chatArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.chatArray.insert(chatData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                chatArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
        if chatArray.count == 0 {
            self.noMachingLabel.isHidden = false
            self.view.bringSubview(toFront: noMachingLabel)
            self.noMachingLabel.backgroundColor = UIColor.white
            self.noMachingLabel.text = "マッチング相手を探しましょう！"
            print("マッチングしている人はいません")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        cell.setChatData(chatArray[indexPath.row])
        
        cell.jumpChatButton.addTarget(self, action:#selector(chatbutton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    @IBAction func chatbutton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let chatData = chatArray[indexPath!.row]
        
        //popupViewに値を渡す
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let chatOneViewController: ChatOneViewController = storyBoard.instantiateViewController(withIdentifier: "ChatOne") as! ChatOneViewController
        let uid = Auth.auth().currentUser?.uid
        chatOneViewController.myUid = uid!
        chatOneViewController.opponentUid = chatData.userId!
        self.present(chatOneViewController, animated: true, completion: nil)
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt 実行")
        let chatData = chatArray[indexPath.row]
        print("indexPath = \(indexPath)")
        
        //popupViewに値を渡す
        let chatOneViewController: ChatOneViewController = self.storyboard!.instantiateViewController(withIdentifier: "ChatOne") as! ChatOneViewController
        let uid = Auth.auth().currentUser?.uid
        chatOneViewController.myUid = uid!
        chatOneViewController.opponentUid = chatData.userId!
        self.present(chatOneViewController, animated: false, completion: nil)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
