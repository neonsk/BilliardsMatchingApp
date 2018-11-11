//
//  ChatOneTalkViewController.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/10/29.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseAuth


class ChatOneTalkViewController: MessagesViewController {
    var myUid = "KhxLzMsSqUfjODLSXfmk4Oa5gXH3"
    var opponentUid = "4Ttth9vaVqTvuH2LtpKRk3IZ7qg1"
    var opponentDisplayName = ""
    
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
        print("ChatOneTalkViewController---------------------------------")
        print("myUid = \(myUid), opponentUid = \(opponentUid)")
        
        let myRef = Database.database().reference().child("chats").child(myUid).child(opponentUid)
        myRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: Chat画面に移動しました。")
            print("snapshot = \(snapshot)")
            // PostDataクラスを生成して受け取ったデータを設定する
            let chatData = ChatData(snapshot: snapshot, myId: self.myUid)
            self.text = chatData.talks!
            self.commentArray.append(chatData.talks!)
            print("commentArray[\(self.commentCount)] = \(self.commentArray[self.commentCount])")
            
            self.messageList.append(self.getMessages(self.commentCount))
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
    func getMessages(_ count:Int) -> MockMessage /*[MockMessage]*/ {
        
        return createMessage(text: self.commentArray[count])
        /*
         return [
         createMessage(text: self.text),
         createMessage(text: "あ"),
         createMessage(text: "い")
         ]*/
    }
    
    func createMessage(text: String) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                           .foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatOneTalkViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: "123", displayName: "自分")
    }
    
    func otherSender() -> Sender {
        return Sender(id: "456", displayName: "知らない人")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // メッセージの上に文字を表示
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string:opponentUid, //MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedStringKey.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatOneTalkViewController: MessagesDisplayDelegate {
    
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
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
extension ChatOneTalkViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatOneTalkViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatOneTalkViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),.foregroundColor: UIColor.white])
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
