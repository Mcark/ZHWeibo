//
//  ZHMeituanRefreshView.swift
//  AddressBook
//
//  Created by SanRong on 2019/3/18.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHMeituanRefreshView: ZHRefreshView {

    @IBOutlet weak var buildingIconView: UIImageView!
    @IBOutlet weak var earthIconView: UIImageView!
    @IBOutlet weak var kangarooIconView: UIImageView!
    
    //父视图高度
    override var parentViewHeight: CGFloat {
        didSet {
            if parentViewHeight < 53 {
                return
            }
            
            var scale: CGFloat
            if parentViewHeight > 120 {
                scale = 1
            } else {
                scale = 1 - ((120 - parentViewHeight) / (120 - 53))
            }
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    
    
    override func awakeFromNib() {
        // 1.房子
        let bImage1 = UIImage(named: "AudioDown")
        let bImage2 = UIImage(named: "AudioDown")
        buildingIconView.image = UIImage.animatedImage(with: [bImage1!, bImage2!], duration: 0.5)
        
        // 2.地球
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -2.0 * CGFloat.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 5
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
        
        // 3.袋鼠
        // 1>设置锚点
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        // 2>设置frame
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 53
        kangarooIconView.center = CGPoint(x: x, y: y)
        
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
    }
}
