//
//  ChatViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/14.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var myUid: String?
    var opponentUid: String?
    
    // データベースへの参照を定義
    var ref: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    func setupFirebase() {
        ref = Database.database().reference().child("chats")
        let myRef = ref.child(myUid!)
        let opponentRef = ref.child(opponentUid!)
        
        // 最新25件のデータをデータベースから取得する
        // 最新のデータが追加されるたびに最新データを取得する
        print("myRef.child(opponentUid!) = \(myRef.child(opponentUid!))")
        myRef.child(opponentUid!).queryLimited(toLast: 25).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["text"] as! String
            let sender = snapshotValue["from"] as! String
            let name = snapshotValue["name"] as! String
            print(snapshot.value!)
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            self.messages?.append(message!)
            self.finishSendingMessage()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Chat画面------------------------")
        print("myUid = \(myUid!)")
        print("opponentUid = \(opponentUid!)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたびに下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        
        // 自分のsenderId, senderDisplayNameを設定
        let displayName = Auth.auth().currentUser?.displayName
        self.senderId = myUid!
        self.senderDisplayName = displayName!
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        // アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "noImage.jpg")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "noImage.jpg")!, diameter: 64)
        
        //メッセージデータの配列を初期化
        self.messages = []
        setupFirebase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sendボタンが押された時に呼ばれるメソッド
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        
        //firebaseにデータを送信、保存する
        let myRef = ref.child(myUid!)
        let opponentRef = ref.child(opponentUid!)
        
        let talkPost = ["from": senderId, "name": senderDisplayName, "text":text]
        let myOpponentRefPost = myRef.child(opponentUid!).childByAutoId()
        myOpponentRefPost.setValue(talkPost)
        let opponentMyRefPost = opponentRef.child(myUid!).childByAutoId()
        opponentMyRefPost.setValue(talkPost)
        
        self.finishSendingMessage(animated: true)
        
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages![indexPath.item]
    }
    
    // アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
    
}
