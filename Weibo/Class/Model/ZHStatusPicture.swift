//
//  ZHStatusPicture.swift
//  Weibo
//
//  Created by SanRong on 2019/3/13.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

/// 微博配图模型
class ZHStatusPicture: NSObject {

    // 缩略图地址 - 缩略图太长 分辨率太低
    @objc var thumbnail_pic: String? {
        didSet {
            
            //设置大尺寸图片
            largePic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    /// 中等尺寸图片
    @objc var largePic: String?
    
    override var description: String {
        return yy_modelDescription()
    }
}
