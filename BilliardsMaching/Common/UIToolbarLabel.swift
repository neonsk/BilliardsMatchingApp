//
//  UIToolbarLabel.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/04.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase

enum AppType {
    case A
    case B
}

enum ColorConfig {
    static let text : UIColor = UIColor.black
}

class UIToolbarLabel : UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.toolBalSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.toolBalSet()
    }
    
    private func toolBalSet(){
        
        self.textColor = ColorConfig.text
        //Caseみたいな感じで分けたい時
        var type = AppType.A
        
        if type == .A {
            
        }
        else {
            
        }
        
        //コメント欄のDoneとCancel表示
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:0, width: 0, height: 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.inputAccessoryView = toolbar
    }
    
    @objc func cancel() {
        self.text = ""
        self.endEditing(true)
    }
    
    @objc func done() {
        self.endEditing(true)
    }

}
