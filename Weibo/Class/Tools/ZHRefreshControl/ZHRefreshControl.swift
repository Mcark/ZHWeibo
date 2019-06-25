//
//  ZHRefreshControl.swift
//  Weibo
//
//  Created by SanRong on 2019/3/16.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

/// 刷新状态切换的临界点
private let ZHRefreshOffset: CGFloat = 60

/// 刷新状态
///
/// - Normal: 普通状态: 什么都不坐
/// - Pulling: 超过临界点: 如果放手, 开始刷新
/// - WillRefresh: 用户超过临近点, 并且放手
enum ZHRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

// 刷新控件
class ZHRefreshControl: UIControl {

    //MARK: - 属性
    private weak var scrollView: UIScrollView?
    
    private lazy var refreshView: ZHRefreshView = ZHRefreshView.refreshView()
    
    // MARK: - 构造函数
    init() {
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    /**
     当添加到父视图, newSuperview 是父视图
     当父视图被移除, newSuperview 是 nil
     */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        
        scrollView = sv
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    // 通知不是发, 会内存泄露, 多次注册, 但是不会崩溃
    // KVO: 不释放, 会崩溃
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let sv = scrollView else {
            return
        }
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0 {
            return
        }
        
        // 根据高度设置刷新g控件的frame
        self.frame = CGRect(x: 0, y: 0, width: sv.bounds.size.width, height: -height)
        
        //解决下拉小袋鼠到临界点, 松手之后刷新时, 再往下拉, 小袋鼠变小
        if refreshView.refreshState != .WillRefresh {
            refreshView.parentViewHeight = height
        }
        
        refreshView.parentViewHeight = height
        
        // 判断临界点 - 只需要判断一次
        if sv.isDragging {
            if height > ZHRefreshOffset && (refreshView.refreshState == .Normal) {
                print("放手刷新")
                refreshView.refreshState = .Pulling
            } else if height <= ZHRefreshOffset && (refreshView.refreshState == .Pulling) {
                print("在使劲...")
                refreshView.refreshState = .Normal
            }
        } else {
            // 放手
            if refreshView.refreshState == .Pulling {
                print("准备开始刷新")
                // 刷新结束之后, 将 状态修改为 .Normal 才能继续响应刷新
                refreshView.refreshState = .WillRefresh
                
                var inset = sv.contentInset
                inset.top += ZHRefreshOffset
                sv.contentInset = inset
                
                // 发送刷新数据事件
                sendActions(for: .valueChanged)
            }
        }
    }
    
    override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    /// 开始刷新
    func beginRefreshing() {
        print("开始刷新")
        
        guard let sv = scrollView else {
            return
        }
        // 判断是否正在刷新, 如果正在刷新, 直接返回
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        refreshView.refreshState = .WillRefresh
        
        var inset = sv.contentInset
        inset.top += ZHRefreshOffset
        sv.contentInset = inset
        
        // 设置刷新视图的父视图高度
        refreshView.parentViewHeight = ZHRefreshOffset
    }
    
    /// 结束刷新
    func endRefreshing() {
        print("结束刷新")
        
        guard let sv = scrollView else {
            return
        }
        // 判断是否正在刷新, 如果正在刷新, 直接返回
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        refreshView.refreshState = .Normal
        
        var inset = sv.contentInset
        inset.top -= ZHRefreshOffset
        sv.contentInset = inset
    }
}

extension ZHRefreshControl {
    private func setupUI() {
        backgroundColor = superview?.backgroundColor
//        clipsToBounds = true
        addSubview(refreshView)
        
        //自动布局
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.height))
    }
}
