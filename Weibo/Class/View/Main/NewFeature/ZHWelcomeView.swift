//
//  ZHWelcomeView.swift
//  Weibo
//
//  Created by SanRong on 2019/3/7.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import SDWebImage

class ZHWelcomeView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tip: UILabel!
    @IBOutlet weak var bottomCon: NSLayoutConstraint!
    
    class func welcomeView() -> ZHWelcomeView {
        let nib = UINib(nibName: "ZHWelcomeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! ZHWelcomeView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        guard let urlString = ZHNetworkManager.shared.userAccount.avatar_large,
        let url = URL(string: urlString) else {
            return
        }
        icon.sd_setImage(with: url, placeholderImage:UIImage(named: "avater"))
    }
    
    /// 视图被添加到 window 上, 表示视图已经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        self.layoutIfNeeded()
        
        bottomCon.constant = bounds.size.height - 200
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.layoutIfNeeded()
        }) { (_) in
            
            UIView.animate(withDuration: 1.0, animations: {
                self.tip.alpha = 1
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
    }
}
