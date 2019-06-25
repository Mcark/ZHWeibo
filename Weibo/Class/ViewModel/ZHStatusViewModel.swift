//
//  ZHStatusViewModel.swift
//  Weibo
//
//  Created by SanRong on 2019/3/12.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation
import UIKit

/// 单条微博的视图模型
/**
 如果没有任何父类, 希望在开发调试, 输出调试信息, 需要:
 1.遵守 CustomStringConvertible
 2.实现 description 计算型属性
 
 关于表格的性能优化
 - 尽量少计算, 所有需要的素材提前计算好!
 - 控件上不要设置圆角半径, 所有图像渲染的属性, 都要注意
 - 不要动态创建控件, 所有需要的控件, 都要提前创建好, 在显示的时候根据数据显示隐藏
 - Cell中控件层次越少越好
 */

class ZHStatusViewModel: CustomStringConvertible {
    /// 微博模型
    var status: ZHStatus
    
    /// 会员图标 - 存储型属性 (用内存换CPU)
    var memberIcon: UIImage?
    
    /// 认证: -1:没有认证, 0:认证, 2,3,5,:企业认证, 220:达人
    var vipIcon: UIImage?
    
    /// 转发文字
    var retweetedStr: String?
    /// 评论文字
    var commentStr: String?
    /// 赞文字
    var likeStr: String?
    
    /// 配图视图的大小
    var pictureViewSize = CGSize()
    
    /// 如果是被转发的微博, 原创微博一定没有图
    var picURLs: [ZHStatusPicture]? {
        //如果有被转发的微博, 返回被转发微博的配图
        //如果没有被转发的微博, 返回原创微博的配图
        //如果都没有, 返回 nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    /// 被转发微博的文字
    var retweetedText: String?
    
    /// 缓存行高
    var rowHeight: CGFloat = 0
    
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    /// - returns: 微博的视图模型
    init(model: ZHStatus) {
        self.status = model
        
//        // 直接计算出 会员等级 0-6
//        let mbrank = model.user?.mbrank ?? -1
//        if mbrank > 0 && mbrank < 7 {
//            let imageName = "common_icon_membership_level\(model.user?.mbrank ?? 1)"
//            memberIcon = UIImage(named: imageName)
//        }
        
//        // 认证图标
//        switch model.user?.verified_type {
//        case 0:
//            vipIcon = UIImage(named: "vip")
//        case 2,3,5:
//            vipIcon = UIImage(named: "vip")
//        case 220:
//            vipIcon = UIImage(named: "vip")
//        default:
//            break
//        }
        
        //设置底部计数字符串
        retweetedStr = countString(count: model.reposts_count, defaultStr: "转发")
        commentStr = countString(count: model.comments_count, defaultStr: "评论")
        likeStr = countString(count: model.attitudes_count, defaultStr: "赞")
        
        /// 计算配图视图大小 (有原创的计算原创的, 有转发计算转发)
        pictureViewSize = calcPictureViewSize(count: picURLs?.count)
        
        // 设置被转发微博的文字
        retweetedText = "@" + (status.retweeted_status?.user?.screen_name ?? "")
        retweetedText = (retweetedText ?? "") + ":" + (status.retweeted_status?.text ?? "")
        
        updateRowHeight()
    }
    
    /// 根据当前的视图模型内容计算行高
    func updateRowHeight() {
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolbarHeight: CGFloat = 35
        
        var height: CGFloat = 0
        
        let viewSize = CGSize(width: UIScreen.main.bounds.size.width - 2 * margin, height: CGFloat(MAXFLOAT))
        let originalFont = UIFont.systemFont(ofSize: 15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        
        // 1.计算顶部行高
        height = 2 * margin + iconHeight + margin
        
        // 2.计算正文高度
        /**
         1.预期尺寸:宽度固定, 高度最大   2.换行文本, 统一使用 usesLineFragmentOrigin  3.字典
         */
        if let text = status.text {
            height += (text as NSString).boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font:originalFont], context: nil).height
        }
        
        // 3.判断是否是转发微博
        if status.retweeted_status != nil {
            height += 2 * margin
            if let text = retweetedText {
                height += (text as NSString).boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font:retweetedFont], context: nil).height
            }
        }
        
        // 4.配图视图
        height += pictureViewSize.height
        height += margin
        height += toolbarHeight
        rowHeight = height
    }
    
    /// 使用单个图像, 更新配图视图的大小
    ///
    /// 新浪针对单张图片, 都是缩略图, 但是偶尔会有一张特别大的图  7000 * 9000
    ///
    /// - Parameter image: 网络缓存的单张图像
    func updateSingleImageSize(image: UIImage) {
        var size = image.size
        
        //针对过宽图像处理
        let maxWidth: CGFloat = 300
        if size.width > maxWidth {
            // 设置最大宽度
            size.width = 200
            //等比例调整高度
            size.height = size.width * image.size.height / image.size.width
        }
        
        // 针对t过窄图像处理
        let minWidth: CGFloat = 40
        if size.width < minWidth {
            size.width = minWidth
            
            // 要特殊处理高度, 否则高度太大, 会影响用户体验
            size.height = size.width * image.size.height / image.size.width / 4
        }
        
        // 过高图片处理, 图片填充模式就是 scaleToFill, 高度减小. 会自动裁切
        if size.height > 200 {
            size.height = 200
        }
        
        //注意, 尺寸需要增加顶部的 12 个点
        size.height += ZHStatusPictureViewOutterMargin
        pictureViewSize = size
        
        //更新行高
        updateRowHeight()
    }
    
    /// 计算指定数量的图片对应的配图视图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    private func calcPictureViewSize(count: Int?) -> CGSize {
        
        if count == 0 || count == nil {
            return CGSize()
        }
        
        let row = (count! - 1) / 3 + 1
        
        var height = ZHStatusPictureViewOutterMargin
        height += CGFloat(row) * ZHStatusPictureItemWidth
        height += CGFloat(row - 1) * ZHStatusPictureViewInnerMargin
        
        return CGSize(width: ZHStatusPictureViewWidth, height: height)
    }
    
    /// 给定一个数字, 返回对应的描述结果
    ///
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认字符串, 转发/评论/赞
    /// - Returns: 描述结果
    
    /** 如果==0 默认显示标题, 如果>1万显示X.万, 如果<1万显示实际数字*/
    private func countString(count: Int, defaultStr: String) -> String {
        if count == 0 {
            return defaultStr
        }
        if count < 10000 {
            return count.description
        }
        return String(format: "%.02f 万", Double(count) / 10000.0)
    }
    
    var description: String {
        return status.description
    }
}
