//
//  UIImage+Extension.swift
//  BilliardsMaching
//
//  Created by 高坂将大 on 2018/11/18.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit

extension UIImage {
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
}
