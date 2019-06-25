//
//  ZHUserAccount.swift
//  Weibo
//
//  Created by SanRong on 2019/2/28.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

// 用户账户信息
class ZHUserAccount: NSObject {

    //访问令牌
    @objc var access_token: String?
    //用户代号
    @objc var uid: String?
    //过期日期, 单位秒.  开发者5年每次登陆之后,重新计算5年, 使用者3天会从第一次登陆之后递减
    @objc var expires_in: TimeInterval = 0 {
        didSet {
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    
    @objc var expiresDate: Date?
    //用户昵称
    @objc var screen_name: String?
    //用户头像
    @objc var avatar_large: String?
    
    override init() {
        super.init()
        
        //从磁盘加载保存的文件 -> 字典
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        let documentPatch = documentPaths.first ?? ""
        let fileName = documentPatch + "/useraccount.json"
        
        guard let data = NSData(contentsOfFile: fileName),
        let dict = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any] else {
            return
        }
        
        //使用字典设置属性值
        yy_modelSet(with: dict ?? [:])
        
        //判断 token 是否过期   desc降序   asce升序
        if expiresDate?.compare(Date()) != .orderedDescending {
            print("账户过期")
            access_token = nil
            uid = nil
            try? FileManager.default.removeItem(atPath: fileName)
        }
        print("账户正常 \(self)")
    }
    
    func saveAccount() {
        // 1.模型转字典
        var dict = (self.yy_modelToJSONObject() as? [String: Any]) ?? [:]
        
        // 删除 expires_in 值
        dict.removeValue(forKey: "expires_in")
        
        // 2.字典序列化 data
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return
        }
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        let documentPatch = documentPaths.first ?? ""
        
        let fileName = documentPatch + "/useraccount.json"
        
        // 3.写入磁盘
        (data as NSData).write(toFile: fileName, atomically: true)
        print("用户账户保存成功 \(fileName)")
    }
    
    override var description: String {
        return yy_modelDescription()
    }
    
}
