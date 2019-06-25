//
//  ZHRefreshView.swift
//  AddressBook
//
//  Created by SanRong on 2019/3/16.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHRefreshView: UIView {

    /// 刷新状态
    /**
     UIView 动画中, 默认顺时针旋转
     - 就近原则
     - 要想实现同方向旋转, 需要调整一个 非常小的数字 (就近原则)
     - 如果想实现 360 旋转, 需要核心动画 CABaseAnimation
     */
    var refreshState: ZHRefreshState = .Normal {
        didSet {
            switch refreshState {
            case .Normal:
                tipLabel?.text = "继续使劲拉..."
                
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                
                UIView.animate(withDuration: 0.25) {
                    self.tipIcon?.transform = CGAffineTransform.identity
                }
                
            case .Pulling:
                tipLabel?.text = "放手就刷新..."
                
                UIView.animate(withDuration: 0.25) {
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: (CGFloat.pi - 0.001))
                }
                
            case .WillRefresh:
                tipLabel?.text = "正在刷新中..."
                
                tipIcon?.isHidden = true
                indicator?.startAnimating() 
            }
        }
    }
    
    //父视图高度 - 为了刷新控件不需要关心当前具体的刷新视图是谁!
    var parentViewHeight: CGFloat = 0
    
    /// 提示图标
    @IBOutlet weak var tipIcon: UIImageView?
    /// 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    /// 指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    class func refreshView() -> ZHRefreshView {
        let nib = UINib(nibName: "ZHRefreshView", bundle: nil)
//        let nib = UINib(nibName: "ZHMeituanRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! ZHRefreshView
    }
}
