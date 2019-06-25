//
//  ZHNetworkManager+Extension.swift
//  Weibo
//
//  Created by SanRong on 2019/2/22.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation
import UIKit

extension ZHNetworkManager {
    func statusList(since_id: Int64 = 0, max_id:Int64 = 0, completion: @escaping (_ list: [[String: Any]]?, _ isSuccess: Bool)->()) {
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        let params = ["since_id": since_id,
                      "max_id": max_id > 0 ? max_id - 1 : 0]
        
        
        tokenRequest(URLString: urlString, parameters: params) { (json, isSuccess) in
            
//            print(json ?? "error")
            
            let res = json as? [String: Any]
            let result = res?["statuses"] as? [[String:AnyObject]]
            completion(result, isSuccess)
        }
    }
    
    /// 返回微博的未读数量
    func unreadCount(completion: @escaping (_ count: Int) -> ()) {
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        let params = ["uid": uid]
        
        tokenRequest(URLString: urlString, parameters: params) { (json, isSuccess) in
            let dict = json as? [String: Any]
            let count = dict?["status"] as? Int
            
            completion(count ?? 0)
        }
    }
}

// MARK: - 发布微博
extension ZHNetworkManager {
    /// 发布微博
    ///
    /// - Parameters:
    ///   - text: 要发布的文本
    ///   - image: 要上传的图像, 为 nil 时, 发布纯文本微博
    ///   - completion: 完成回调
    func postStatus(text: String, image: UIImage?, completion: @escaping ([String: Any]?, Bool)->()) -> () {
        
        let urlString: String
        if image == nil {
            urlString = "https://api.weibo.com/2/statuses/update.json"
        } else {
            urlString = "https://upload.api.weibo.com/2/statuses/update.json"
        }
        
        let params = ["status": text]
        
        // 如果图像不为空, 需要设置 name 和 data
        var name: String?
        var data: Data?
        if image != nil {
            name = "pic"
            data = image!.pngData()
        }
        tokenRequest(method: .POST, URLString: urlString, parameters: params, name: name, data: data) { (json, isSuccess) in
            completion(json as? [String: Any], isSuccess)
        }
    }
}

// MARK: - 用户信息/Users/sanrong/Desktop/Weibo/Weibo/Class/Tools/Extension
extension ZHNetworkManager {
    // 加载用户信息 - 用户登录后立即执行
    func loadUserInfo(completion: @escaping (_ dict: [String: Any])->()) {
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid": uid]
        tokenRequest(URLString: urlString, parameters: params) { (json, isSuccess) in
            completion((json as? [String: Any]) ?? [:])
        }
    }
}

extension ZHNetworkManager {
    func loadAccessToken(code: String, completion: @escaping (_ isSuccess: Bool)->()) {
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let params = ["client_id": ZHAppKey,
                      "client_secret": ZHAppSecret,
                      "grant_type": "authorization_code",
                      "code": code,
                      "redirect_uri": ZHRedirectURL]
        request(method: .POST, URLString: urlString, parameters: params) { (json, isSeccess) in
                        
            //直接用字典设置 uesraccount 属性
            self.userAccount.yy_modelSet(withJSON: json ?? [:])
            
            self.loadUserInfo(completion: { (dict) in
                
                // 使用用户信息字典设置用户账户信息(昵称, 头像)
                self.userAccount.yy_modelSet(with: dict)
                
                self.userAccount.saveAccount()
                
                // 用户信息加载完成, 再完成回调
                completion(isSeccess)
            })
        }
    }
}
