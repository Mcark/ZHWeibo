//
//  ZHOAuthController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/28.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import SVProgressHUD

class ZHOAuthController: UIViewController {

    lazy private var webView = UIWebView()
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        
        title = "登录新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(loginBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: .plain, target: self, action: #selector(autoFill))
        
        webView.delegate = self
        
        webView.scrollView.isScrollEnabled = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载授权页面
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(ZHAppKey)&redirect_uri=\(ZHRedirectURL)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
        
    }
    
    @objc private func loginBack() {
        
        SVProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    @objc private func autoFill() {
        // 准备js
        let js = "document.getElementById('userId').value = '1015443981@qq.com'; " + "document.getElementById('passwd').value = '15890657925li';"
        
        // 让 webview 执行 js
        webView.stringByEvaluatingJavaScript(from: js)
    }
}

extension ZHOAuthController: UIWebViewDelegate {
    
    /// webView 将要加载请求
    ///
    /// - Parameters:
    ///   - webView: webview
    ///   - request: 要加载的请求
    ///   - navigationType: 导航类型
    /// - Returns: 是否加载请求
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        print("加载请求: --------- \(String(describing: request.url?.absoluteString))")
        // query: 就是 url 中 '?' 后边的所有部分
        print("加载请求: --------- \(String(describing: request.url?.query))")
        
        //如果请求地址包含 "https://www.baidu.com" 不加载页面 / 否则加载页面
        if request.url?.absoluteString.hasPrefix(ZHRedirectURL) == false {
            return true
        }
        // 从上边的地址中, 如果有code 授权成功, 反之失败
        if request.url?.query?.hasPrefix("code=") == false {
            print("取消授权")
            
            loginBack()
            
            return false
        }
        
        guard let querytString = request.url?.query else {
            return true
        }

//        //截取字符串第一中方法
//        let index = querytString.index(querytString.startIndex, offsetBy: 5)
//        print(querytString[index...])
        
        //截取字符串第二种方法
        guard let code = request.url?.query?.suffix(querytString.count - 5) else {
            return true
        }
        ZHNetworkManager.shared.loadAccessToken(code: String(code)) { (isSuccess) in
            if !isSuccess {
                SVProgressHUD.showInfo(withStatus: "网络请求失败")
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ZHUserLoginSuccessNotification), object: nil)
                self.loginBack()
            }
        }
        
        return false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
