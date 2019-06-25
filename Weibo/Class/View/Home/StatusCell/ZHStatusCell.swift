//
//  ZHStatusCell.swift
//  Weibo
//
//  Created by SanRong on 2019/3/12.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

// 微博 Cell 的协议
// 如果需要设置可选协议方法: 1.遵守NSObjectProtocol  2.协议需要是 @objc, 方法需要 @objc optional

@objc protocol ZHStatusCellDelegate: NSObjectProtocol {
    @objc optional func statusCellDidSelectedURLString(cell: ZHStatusCell, urlString:String)
}

class ZHStatusCell: UITableViewCell {

    //代理属性
    weak var delegate: ZHStatusCellDelegate?
    
    var viewModel: ZHStatusViewModel? {
        didSet {
            statusLabel.text = viewModel?.status.text
            nameLabel.text = viewModel?.status.user?.screen_name
            
//            // 设置会员图标
//            memberIconView.image = viewModel?.memberIcon
//            vipIconView.image = viewModel?.vipIcon
            
            //用户头像
            iconView.zh_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avater"), isAvatar: true)
            toolBar.viewModel = viewModel
            
            // 配图视图模型
            pictureView.viewModel = viewModel
            
            //设置配图视图的 URL 数据 (被转发 和 原创)
            pictureView.urls = viewModel?.picURLs
//            // FIXME: - 测试 4 张图像
//            if viewModel?.status.pic_urls?.count ?? 0 > 4 {
//                // 修改数组 -> 将末尾的数据全部删除
//                var picURLs = viewModel!.status.pic_urls!
//                picURLs.removeSubrange((picURLs.startIndex + 4)..<picURLs.endIndex)
//                pictureView.urls = picURLs
//            } else {
//                pictureView.urls = viewModel?.status.pic_urls
//            }
            
            // 设置被转发微博的文字
            retweetedLabel?.text = viewModel?.retweetedText
            
            sourceLabel.text = viewModel?.status.source
            timeLabel.text = viewModel?.status.createdDate?.zh_dateDescription
        }
    }
    
    /// 头像
    @IBOutlet weak var iconView: UIImageView!
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    /// 会员
    @IBOutlet weak var memberIconView: UIImageView!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// vip头像
    @IBOutlet weak var vipIconView: UIImageView!
    /// 正文
    @IBOutlet weak var statusLabel: FFLabel!
    /// 底部工具栏
    @IBOutlet weak var toolBar: ZHStatusToolBar!
    /// 配图视图
    @IBOutlet weak var pictureView: ZHStatusPictureView!
    /// 被转发微博的标签 - 原创微博没有此控件, 一定要用 ?
    @IBOutlet weak var retweetedLabel: FFLabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //新加知识点: 离屏渲染 - 异步绘制
        //离屏渲染: 在进入屏幕之前就绘制好表格 cell, 进入之后, 直接显示, 坏处 CPU 消耗大
        //如果检测到 cell 的性能已经很好, 就不需要离屏渲染
        //离屏渲染需要在 GPU/CPU 之间快速切换, 耗电
        self.layer.drawsAsynchronously = true
        //栅格化 - 异步绘制之后, 会生成一张独立的图像, cell在屏幕上滚动的时候, 本质上滚动的是这张图片
        //停止滚动之后, 可以接受监听
        self.layer.shouldRasterize = true
        
        //使用 '栅格化' 必须注意指定分辨率
        self.layer.rasterizationScale = UIScreen.main.scale
        
        // 设置微博文本代理
        statusLabel.delegate = self
        retweetedLabel?.delegate = self
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension ZHStatusCell: FFLabelDelegate {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        // 判断是否是URL
        if !text.hasPrefix("http://") {
            return
        }
        
        // 插入 ? 表示如果代理没有实现协议方法, 就什么都不坐
        // 如果使用 ! , 代理没有实现协议方法, 仍然强制执行, 会崩溃!
        delegate?.statusCellDidSelectedURLString?(cell: self, urlString: text)
    }
}
