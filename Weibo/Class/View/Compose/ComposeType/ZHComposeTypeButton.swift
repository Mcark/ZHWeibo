//
//  ZHComposeTypeButton.swift
//  AddressBook
//
//  Created by SanRong on 2019/3/18.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // 点击按钮要展现控制器的类型
    var clsName: String?
    
    // 使用图像名称 / 标题创建按钮, 按钮布局从 XIB 加载
    class func composeTypeButton(imageName: String, title: String) -> ZHComposeTypeButton {
        let nib = UINib(nibName: "ZHComposeTypeButton", bundle: nil)
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! ZHComposeTypeButton
        btn.imageView.image = UIImage(named: imageName)
        btn.titleLabel.text = title
        return btn
    }
}
