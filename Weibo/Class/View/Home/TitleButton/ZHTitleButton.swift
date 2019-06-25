//
//  ZHTitleButton.swift
//  Weibo
//
//  Created by SanRong on 2019/3/7.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHTitleButton: UIButton {

    init(title: String?) {
        super.init(frame: CGRect())
        
        if title == nil {
            setTitle("首页", for: .normal)
        } else {
            setTitle(title! + " ", for: .normal)

            setImage(UIImage(named: "exercise_selected"), for: .normal)
            setImage(UIImage(named: "exercise"), for: .selected)
        }

        setTitleColor(UIColor.orange, for: .normal)
        setTitleColor(UIColor.black, for: .highlighted)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel,
            let imageView = imageView else {
            return
        }
        
        //OC中不允许修改结构体内部的值, swift中可以
        titleLabel.frame.origin.x = 0
        imageView.frame.origin.x = titleLabel.bounds.width
//        if imageView.frame.minX <= titleLabel.frame.minX {
//            //将 label 的 x 向左移动 imageView 的宽度
//            titleLabel.frame = titleLabel.frame.offsetBy(dx: -imageView.bounds.width, dy: 0)
//
//            //将 imageView 的 x 向右移动 label 的宽度
//            imageView.frame = imageView.frame.offsetBy(dx: titleLabel.bounds.width, dy: 0)
//        }
    }
}
