//
//  ChatOneViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/24.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseAuth


class ChatOneViewController: MessagesViewController {
    @IBOutlet weak var forHideView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    var myUid = ""
    var myDisplayName = ""
    var opponentUid = ""
    var opponentDisplayName = ""
    var postUserID = ""
    var postUserDisplayName = ""
    let now = NSDate()
    let dateFormatter = DateFormatter()

    var messageList: [MockMessage] = []
    var text = ""
    var commentArray: [String] = []
    var commentCount = 0
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        print("ChatOneViewController---------------------------------")
        print("myUid = \(myUid), opponentUid = \(opponentUid)")
        myDisplayName = (Auth.auth().currentUser?.displayName)!
        
        let myRef = Database.database().reference().child("chats").child(myUid).child(opponentUid)
        myRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: Chat画面に移動しました。")
            print("snapshot = \(snapshot)")
            // PostDataクラスを生成して受け取ったデータを設定する
            let chatData = ChatData(snapshot: snapshot, myId: self.myUid)
            self.text = chatData.talks!
            self.postUserID = chatData.postUserID!
            self.postUserDisplayName = chatData.postUserDisplayName!
            if self.postUserDisplayName != self.myDisplayName {
                self.opponentDisplayName = self.postUserDisplayName
            }
            self.headerLabel.text = self.opponentDisplayName
            self.commentArray.append(chatData.talks!)
            print("commentArray[\(self.commentCount)] = \(self.commentArray[self.commentCount])")
            self.messageList.append(self.getMessages(self.commentCount,self.postUserID,self.postUserDisplayName))
            self.commentCount += 1
            
            // messagesCollectionViewをリロードして一番下までスクロールする
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            print("messageList = \(self.messageList)")
        })
        print("messageList = \(self.messageList)")
        
        // messagesCollectionViewをリロードして
        self.messagesCollectionView.reloadData()
        // 一番下までスクロールする
        self.messagesCollectionView.scrollToBottom()
        
        self.becomeFirstResponder()
        self.view.bringSubview(toFront: headerLabel)
        headerLabel.backgroundColor = UIColor.white
        self.view.bringSubview(toFront: backButton)
        self.view.bringSubview(toFront: forHideView)
        forHideView.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
        
        
        //        // メッセージ入力欄の左に画像選択ボタンを追加
        //        // 画像選択とかしたいときに
        //        let items = [
        //            makeButton(named: "clip.png").onTextViewDidChange { button, textView in
        //                button.tintColor = UIColor.lightGray
        //                button.isEnabled = textView.text.isEmpty
        //            }
        //        ]
        //        items.forEach { $0.tintColor = .lightGray }
        //        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
        //        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)
        
        
        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    //前の画面に移動
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // ボタンの作成
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor.gray
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    // サンプル用に適当なメッセージ
    func getMessages(_ count:Int, _ uid:String, _ name:String) -> MockMessage{
        return createMessage(text: self.commentArray[count],uid,name)
    }
    
    func createMessage(text: String, _ uid:String, _ name:String) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                           .foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: Sender(id: uid,displayName: name)/*otherSender()*/, messageId: UUID().uuidString, date: Date())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//初期データ
extension ChatOneViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        
        return Sender(id: myUid, displayName: myDisplayName)
    }
    
    func otherSender() -> Sender {
        return Sender(id: opponentUid, displayName: opponentDisplayName)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // Viewのトップバーに文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string:"",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedStringKey.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var name = ""
        if message.sender.id != myUid {
            name = message.sender.displayName
        }
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    /*
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }*/
}

// メッセージのdelegate
extension ChatOneViewController: MessagesDisplayDelegate {
    
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor.hex(string: "62D34F", alpha: 1):
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameとかで送信者の名前を取得できるので
        // そこからイニシャルを生成するとよい
        let avatar = Avatar(initials: "人")
        avatarView.set(avatar: avatar)
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatOneViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 50 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 5
    }
}

extension ChatOneViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatOneViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                /*let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),.foregroundColor: UIColor.white])
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])*/
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let postTime = dateFormatter.string(from: now as Date)
                let chatRefMyId = Database.database().reference().child("chats").child(myUid)
                let chatRefPostUserId = Database.database().reference().child("chats").child(opponentUid)
                let chatDic  = ["talks":text,"postUserID":myUid,"postUserDisplayName":myDisplayName,"postTime":postTime]
                chatRefMyId.child(opponentUid).childByAutoId().setValue(chatDic)
                chatRefPostUserId.child(myUid).childByAutoId().setValue(chatDic)
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
