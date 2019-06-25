//
//  ZHComposeViewController.swift
//  Weibo
//
//  Created by SanRong on 2019/3/22.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 撰写微博控制器
/**
 加载视图控制器的时候, 如果 XIB 和控制器同名, 默认的构造函数, 会优先加载 XIB
 
 */

class ZHComposeViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var toolbarBottomCons: NSLayoutConstraint!
    
    //可以针对每一行选中并且设置属性, 调整行间距, 增加一个空行, 调整空行的字体, lineHeight
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //监听键盘通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder() // 激活键盘
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder() // 关闭键盘
    }
    
    @objc private func keyboardChanged(n: Notification) {
//        print(n.userInfo)
        
        //1.目标 rect
        guard let rect = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        
        //2.设置底部约束高度
        let offset = view.bounds.height - rect.origin.y
        
        //3.更新底部约束
        toolbarBottomCons.constant = offset
        
        //4.动画更新约束
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 左上角关闭按钮
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var sendButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("发布", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.gray, for: .disabled)
        btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.orange), for: .normal)
        btn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.white), for: .disabled)
        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 35)
        
        btn.addTarget(self, action: #selector(sendStatus), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - 发布微博
    @objc private func sendStatus() {
        guard let text = textView.text else {
            return
        }
        
        let image: UIImage? = nil // UIImage(named: "avater")
        
        ZHNetworkManager.shared.postStatus(text: text, image: image) { (result, isSuccess) in
            
            SVProgressHUD.setDefaultStyle(.dark)
            let message = isSuccess ? "发布成功" : "网络不给力"
            SVProgressHUD.showInfo(withStatus: message)
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    SVProgressHUD.setDefaultStyle(.light)
                    self.close()
                })
            }
        }
    }
    
    /// 切换表情键盘
    @objc private func emoticonKeyboard() {
        // textView.inputView 就是文本框的输入视图
        // 如果使用系统默认的键盘, 输入视图为 nil
        
        // 1>测试键盘视图
        let keyboardView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        keyboardView.backgroundColor = UIColor.blue
        
        // 2>设置键盘视图
        textView.inputView = (textView.inputView == nil) ? keyboardView : nil
        
        // 2.5> 设置输入助理视图 - 键盘消失, 助理视图随之消失
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        textView.inputAccessoryView = toolbar
        
        // 3>刷新键盘视图
        textView.reloadInputViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ZHComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
}

private extension ZHComposeViewController {
    func setupUI() {
        
        view.backgroundColor = UIColor.white
        setupNavigationBar()
        setupToolBar()
    }
    
    func setupToolBar() {
        let itemSettings = [["imageName": "", "title": " 图片 "],
                            ["imageName": "", "title": "  @  "],
                            ["imageName": "", "title": " 表情 ", "actionName": "emoticonKeyboard"],
                            ["imageName": "", "title": " 话题 "],
                            ["imageName": "", "title": " 添加 "]]
        
        var items = [UIBarButtonItem]()
        for s in itemSettings {
            guard let text = s["title"] //let imageName = s["imageName"]
                 else {
                continue
            }
            let btn = UIButton()
            btn.setTitle(text, for: .normal)
            btn.setTitleColor(UIColor.blue, for: .normal)
            btn.setTitleColor(UIColor.orange, for: .highlighted)
            btn.sizeToFit()
            
            if let actionName = s["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            items.append(UIBarButtonItem(customView: btn))
            //追加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolBar.items = items
    }
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        navigationItem.titleView = titleLabel
        sendButton.isEnabled = false
    }
}
