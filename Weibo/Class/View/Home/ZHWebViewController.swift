//
//  ZHWebViewController.swift
//  Weibo
//
//  Created by SanRong on 2019/3/21.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHWebViewController: ZHBaseController {

    private lazy var webView = UIWebView(frame: UIScreen.main.bounds)
    
    var urlString: String? {
        didSet {
            guard let urlString = urlString,
                let url = URL(string: urlString) else {
                return
            }
            webView.loadRequest(URLRequest(url: url))
        }
    }
}

extension ZHWebViewController {
    override func setUI() {
        
        view.addSubview(navigationBar)
        navigationBar.items = [navItem]
        
        navigationBar.tintColor = UIColor.red
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        navItem.title = "网页"
        
        view.insertSubview(webView, belowSubview: navigationBar)
        webView.backgroundColor = UIColor.white
        
        //设置 contenInset
        webView.scrollView.contentInset.top = navigationBar.bounds.height
    }
}
