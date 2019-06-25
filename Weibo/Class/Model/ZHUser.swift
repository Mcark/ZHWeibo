//
//  ZHUser.swift
//  Weibo
//
//  Created by SanRong on 2019/3/12.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

/// 微博用户模型
class ZHUser: NSObject {
    
    //基本数据类型 & private 不能使用 KVC 设置
    @objc var id: Int64 = 0
    @objc var screen_name: String?
    /// 头像 50*50
    @objc var profile_image_url: String?
    /// 认证: -1:没有认证, 0:认证, 2,3,5,:企业认证, 220:达人
    @objc var verified_type: Int = 0
    /// 会员等级 0-6
    @objc var mbrank: Int = 0
    
    override var description: String {
        return yy_modelDescription()
    }
}
