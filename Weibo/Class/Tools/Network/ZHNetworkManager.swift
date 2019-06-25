//
//  ZHNetworkManager.swift
//  Weibo
//
//  Created by SanRong on 2019/2/21.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import AFNetworking

// 405错误: 不支持的网络请求方法.  查找网络请求方法是否正确

enum ZHHTTPMethod {
    case GET
    case POST
}

class ZHNetworkManager: AFHTTPSessionManager {
    
    // 静态区 / 常量 / 闭包 /
    // 在第一次访问是, 执行闭包, 并且将结果保存在常量中
    static let shared: ZHNetworkManager = {
        // 实例化对象
        let instance = ZHNetworkManager()
        // 设置响应反序列化支持的数据类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return instance
    }()

    lazy var userAccount = ZHUserAccount()
    
//    var accessToken: String? = "2.00c4DKmD0N1vJua4d81b3d792EFemC"
//    var uid: String? = "3460058900"
    
    
    /// 专门拼接 token 的方法
    ///
    /// - Parameters:
    ///   - method: GET / POST
    ///   - URLString: 地址
    ///   - parameters: 参数
    ///   - name: 上传文件使用的字段名
    ///   - data: 上传文件使用的二进制数据
    ///   - completion: 完成回调
    func tokenRequest(method:  ZHHTTPMethod = .GET, URLString: String, parameters:[String: Any]?, name: String? = nil, data:Data? = nil, completion: @escaping (Any?, Bool)->()) {
        
        guard let token = userAccount.access_token else {
            
//            print("没有token, 需要登录")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: ZHUserShouldLoginNotification), object: nil)
            
            completion(nil, false)
            return
        }
        
        //判断字典是否存在 如果为nil, 应该创建字典
        var parameters = parameters
        if parameters == nil {
            parameters = [String: AnyObject]();
        }
        parameters?["access_token"] = token
        
        if let name = name, let data = data {
            upload(URLString: URLString, parameters: parameters, name: name, data:data,  completion: completion)
        } else {
            request(method: method, URLString: URLString, parameters: parameters ?? [:], completion: completion)
        }
    }
    
    
    /// 封装 AFN 的 上传文件方法
    /// 上传文件必须是 POST 方法, GET 只能获取数据
    ///
    /// - Parameters:
    ///   - URLString: 地址
    ///   - name: 接受上传数据的服务器字段
    ///   - data: 要上传的二进制数据
    ///   - parameters: 参数
    ///   - completion: 完成回调
    func upload(URLString: String, parameters:[String: Any]?, name: String, data: Data, completion: @escaping (Any?, Bool)->()) {
        post(URLString, parameters: parameters, constructingBodyWith: { (formData) in
            
            /**
             1.data: 要上传的二进制数据
             2.name: 服务器接受数据的字段名
             3.fileName: 保存在服务器的文件名
             4.mimeTyoe: 告诉服务器上传文件的类型, 如果不想告诉, 可以使用 application/octet-stream
                         image/png, image/jpg, image/gif
             */
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
        }, progress: nil, success: { (_, json) in
            completion(json, true)
        }) { (task, error) in
            // 针对 403 处理用户 token 过期
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token 过期了")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: ZHUserShouldLoginNotification), object: nil)
            }
            print("网络请求错误: \(error)")
            completion(nil, false)
        }
    }
    
    
    /// 封装 AFN 的 GET/POST 请求
    ///
    /// - Parameters:
    ///   - method: GET / POST
    ///   - URLString: 地址
    ///   - parameters: 参数
    ///   - completion: 完成回调[json(字典/数组), 是否成功]
    func request(method: ZHHTTPMethod = .GET, URLString: String, parameters:[String: Any], completion: @escaping (Any?, Bool)->()){
        
        let success = {(task: URLSessionDataTask, json: Any?)->() in
            completion(json, true)
        }
        let failure = {(task: URLSessionDataTask?, error: Error)->() in
            // 针对 403 处理用户 token 过期
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token 过期了")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: ZHUserShouldLoginNotification), object: nil)
            }
            print("网络请求错误: \(error)")
            completion(nil, false)
        }
        
        if method == .GET {
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        } else {
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
