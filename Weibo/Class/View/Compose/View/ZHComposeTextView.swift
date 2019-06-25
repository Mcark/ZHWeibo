//
//  ZHComposeTextView.swift
//  Weibo
//
//  Created by SanRong on 2019/3/22.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

// 撰写微博的文本视图
class ZHComposeTextView: UITextView {

    /// 占位标签
    private lazy var placeholderLabel = UILabel()
    
    override func awakeFromNib() {
        setupUI()
    }
    
    // MARK: - 监听方法
    @objc private func textChanged(n: Notification) {
        placeholderLabel.isHidden = self.hasText
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
private extension ZHComposeTextView {
    func setupUI() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: self)
        
        placeholderLabel.text = "分享新鲜事..."
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
    }
}
