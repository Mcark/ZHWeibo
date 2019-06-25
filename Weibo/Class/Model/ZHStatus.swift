//
//  ZHStatus.swift
//  Weibo
//
//  Created by SanRong on 2019/2/26.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit
import YYModel

class ZHStatus: NSObject {

    /// Int 类型, 在 64 位机器是 64 位, 在 32 位机器是 32 位
    /// 如果不写 Int64 在 iPad 2/iPhone 5/5c/4s/4 都无法正常运行
    @objc var id: Int64 = 0
    /// 微博正文
    @objc var text:String?
    
    /// 微博创建时间
    @objc var created_at: String? {
        didSet {
            createdDate = Date.zh_sinaDate(string: created_at ?? "")
        }
    }
    
    /// 微博创建时间字符串
    @objc var createdDate: Date?
    
    /// 微博来源
    @objc var source : String? {
        didSet {
            //重新计算来源并保存  在didset中, 给source 再次设置值, 不会调用 didSet
            source = "来自于 " + (source?.zh_href()?.text ?? "")
        }
    }
    
    /// 转发数
    @objc var reposts_count: Int = 0
    /// 评论数
    @objc var comments_count: Int = 0
    /// 点赞数
    @objc var attitudes_count: Int = 0
    
    @objc var user: ZHUser?
    
    //被转发的原创微博
    @objc var retweeted_status: ZHStatus?
    
    @objc var pic_urls: [ZHStatusPicture]?
    
    override var description: String {
        return yy_modelDescription()
    }
    
    /// 类函数 -> 告诉第三方框架 YY_Model 如果遇到数组类型的属性, 数组中存放的对象是某个类
    @objc class func modelContainerPropertyGenericClass() -> [String: AnyClass] {
        return ["pic_urls": ZHStatusPicture.self]
    }
}
