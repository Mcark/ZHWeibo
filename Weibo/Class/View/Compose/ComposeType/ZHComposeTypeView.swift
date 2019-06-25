//
//  ZHComposeTypeView.swift
//  Weibo
//
//  Created by SanRong on 2019/3/18.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import pop

/// 撰写微博类型视图
class ZHComposeTypeView: UIView {

    @IBOutlet weak var scrolView: UIScrollView!
    
    /// 返回上一页按钮约束
    @IBOutlet weak var returnBtnCenterXCons: NSLayoutConstraint!
    @IBOutlet weak var closeBtnCenterXCons: NSLayoutConstraint!
    @IBOutlet weak var returnBtn: UIButton!
    
    private let buttonInfo = [["imageName": "refresh", "title": "文字", "clsName": "ZHComposeViewController"],
                              ["imageName": "refresh", "title": "视频"],
                              ["imageName": "refresh", "title": "音频"],
                              ["imageName": "refresh", "title": "照片"],
                              ["imageName": "refresh", "title": "签到"],
                              ["imageName": "refresh", "title": "更多", "actionName": "clickMore"],
                              ["imageName": "refresh", "title": "点评"],
                              ["imageName": "refresh", "title": "音乐"],
                              ["imageName": "refresh", "title": "相机"],
                              ["imageName": "refresh", "title": "朋友圈"]]
    
    private var completionBlock: ((_ clsName: String?)->())?
    
    /// MARK: - 实例化方法
    class func composeTypeView() -> ZHComposeTypeView {
        let nib = UINib(nibName: "ZHComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! ZHComposeTypeView
        v.frame = UIScreen.main.bounds
        
        v.setupUI()
        
        return v
    }
    
    // OC中block 如果当前方法不能执行, 通常使用属性记录, 在需要的时候执行
    func show(completion: @escaping (_ clsName: String?)->()) {
        
        // 记录闭包
        completionBlock = completion
        
        // 将当前的视图添加到
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        // 添加视图
        vc.view.addSubview(self)
        
        // 3> 开始动画
        showCurrentView()
        
    }
    @objc private func clickButton(selectedButton: ZHComposeTypeButton) {
        print(selectedButton.clsName ?? "这个按钮不会创建控制器, 需要在字典中创建")
        
        // 1.判断当前显示的视图
        let page = Int(scrolView.contentOffset.x / scrolView.bounds.width)
        let v = scrolView.subviews[page]
        
        // 2.遍历当前视图, 选中按钮变大, 未选中按钮变小
        for (i, btn) in v.subviews.enumerated() {
            
            // 1.缩放动画
            let scaleAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed:kPOPViewScaleXY)
            // x, y 在系统中使用 CGPoint 表示, 如果要转换成 id, 需要使用 'NSValue' 包装
            let scale = (selectedButton == btn) ? 2 : 0.2
            scaleAnim.toValue = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            scaleAnim.duration = 0.5
            btn.pop_add(scaleAnim, forKey: nil)
            
            // 2.渐变动画 - 动画组
            let alphaAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnim.toValue = 0.2
            alphaAnim.duration = 0.5
            btn.pop_add(alphaAnim, forKey: nil)
            
            // 3.监听
            if i == 0 {
                alphaAnim.completionBlock = { _, _ in
                    self.completionBlock?(selectedButton.clsName)
                }
            }
        }
    }
    
    /// 点击更多按钮
    @objc private func clickMore() {
        // 将 scrollView 滚动到第二页
        scrolView.setContentOffset(CGPoint(x: scrolView.bounds.width, y: 0), animated: true)
        
        returnBtn.isHidden = false
        let margin = scrolView.bounds.width / 6
        closeBtnCenterXCons.constant += margin
        returnBtnCenterXCons.constant -= margin
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    /// 点击返回第一页按钮
    @IBAction func clickReturn(_ sender: Any) {
        // 将 scrollView 滚动到第1页
        scrolView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        returnBtnCenterXCons.constant = 0
        closeBtnCenterXCons.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.returnBtn.alpha = 0
        }) { (_) in
            self.returnBtn.isHidden = true
            self.returnBtn.alpha = 1
        }
    }
    @IBAction func close(_ sender: Any) {
        removeFromSuperview()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
}

// MARK: - 动画方法扩展
private extension ZHComposeTypeView {
    /// MARK: - 消除动画
    private func hideButtons() {
        //1.根据 contentOffset 判断当前显示的子视图
        let page = Int(scrolView.contentOffset.x / scrolView.bounds.width)
        let v = scrolView.subviews[page]
        
        //2.遍历 v 中的所有按钮 , reversed反序
        for (i, btn) in v.subviews.enumerated().reversed() {
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = btn.center.y
            anim.toValue = btn.center.y + 350
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.025
            
            btn.layer.pop_add(anim, forKey: nil)
            // 监听第 0 个按钮的动画, 是最后一个执行的
            if i == 0 {
                anim.completionBlock = { _, _ in
                    self.hideCurrentView()
                }
            }
        }
    }
    
    // 隐藏当前视图 - 开始时间
    private func hideCurrentView() {
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 0.25
        
        pop_add(anim, forKey: nil)
        anim.completionBlock = { _, _ in
            self.removeFromSuperview()
        }
    }
    
    /// MARK: - 显示部分的动画
    /// 动画显示当前视图
    private func showCurrentView() {
        // 1> 创建动画
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.5
        pop_add(anim, forKey: nil)
        showButtons()
    }
    
    /// 弹力显示所有的按钮
    private func showButtons() {
        let v = scrolView.subviews[0]
        for (i, btn) in v.subviews.enumerated() {
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = btn.center.y + 350
            anim.toValue = btn.center.y
            // 弹力, 取值范围 0-20, 默认为4
            anim.springBounciness = 8
            // 弹力速度, 取值范围 0-20, 默认12
            anim.springSpeed = 8
            
            // 设置动画启动时间
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.025
            
            btn.pop_add(anim, forKey: nil)
        }
    }
}

private extension ZHComposeTypeView {
    func setupUI() {
        
        // 0.强行更新布局
        layoutIfNeeded()
        // 1.想scrollView 添加视图
        let rect = scrolView.bounds
        
        let width = scrolView.bounds.width
        for i in 0..<2 {
            let v = UIView(frame: rect.offsetBy(dx: CGFloat(i) * width, dy: 0))
            // 2.向视图添加按钮
            addButtons(v: v, idx: i * 6)
            // 3.将视图添加到 scrollView
            scrolView.addSubview(v)
        }
        scrolView.contentSize = CGSize(width: 2 * width, height: 0)
        scrolView.showsVerticalScrollIndicator = false
        scrolView.showsHorizontalScrollIndicator = false
        scrolView.bounces = false
        scrolView.isScrollEnabled = false
    }
    
    /// 向V中添加按钮, 按钮的数组索引从 idx 开始
    func addButtons(v: UIView, idx: Int) {
        let count = 6
        
        // 从 idx 开始, 添加6个按钮
        for i in idx..<(idx + count) {
            if i >= buttonInfo.count {
                break
            }
            let dict = buttonInfo[i]
            guard let imageName = dict["imageName"],
                let title = dict["title"] else {
                    continue
            }
            
            let btn = ZHComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            v.addSubview(btn)
            
            if let actionName = dict["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            } else {
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            //设置要展现的类名
            btn.clsName = dict["clsName"]
        }
        
        // 遍历视图的子视图, 布局按钮
        // 准备常量
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width - 3 * btnSize.width) / 4
        
        for (i, btn) in v.subviews.enumerated() {
            let y: CGFloat = (i > 2) ? (v.bounds.height - btnSize.height) : 0
            let col = i % 3
            let x = CGFloat(col + 1) * margin + CGFloat(col) * btnSize.width
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.width)
        }
    }
}
