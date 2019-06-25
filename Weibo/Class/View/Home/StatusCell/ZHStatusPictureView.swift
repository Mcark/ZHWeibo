 //
//  ZHStatusPictureView.swift
//  Weibo
//
//  Created by SanRong on 2019/3/13.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHStatusPictureView: UIView {

    @IBOutlet weak var heightCons: NSLayoutConstraint!
    
    var viewModel: ZHStatusViewModel? {
        didSet {
            calcViewSize()
        }
    }
    
    /// 根据视图模型的配图视图大小, 调整显示内容
    private func calcViewSize() {
        
        // 处理宽度
        // 1.单图, 根据配图视图大小, 修改 subviews[0] 的宽高
        if viewModel?.picURLs?.count == 1 {
            let viewSize = viewModel?.pictureViewSize ?? CGSize()
            
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: ZHStatusPictureViewOutterMargin, width: viewSize.width, height: viewSize.height - ZHStatusPictureViewOutterMargin)
        } else {
            // 2.多图, 回复 subviews[0] 的宽高, 保证九宫格的完整
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: ZHStatusPictureViewOutterMargin, width: ZHStatusPictureItemWidth, height: ZHStatusPictureItemWidth)
        }
        
        
        
        //设置配图视图的高度
        heightCons.constant = viewModel?.pictureViewSize.height ?? 0
    }
    
    var urls: [ZHStatusPicture]? {
        didSet {
            
            //1.隐藏所有的 imageView
            for v in subviews {
                v.isHidden = true
            }
            //2.遍历 urls 数组, 顺序设置图像
            var index = 0
            for url in urls ?? [ZHStatusPicture]() {
                //获得对应索引的 imageView
                let iv = subviews[index] as! UIImageView
                
                // 如果图像只有 4 张, 单独处理
                if index == 1 && urls?.count == 4 {
                    index += 1
                }
                
                //设置图像
                iv.zh_setImage(urlString: url.thumbnail_pic, placeholderImage: UIImage(named: "avater"))
                
                // 判断是否是 gif
                iv.subviews[0].isHidden = (((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif")
                
                //显示图像
                iv.isHidden = false
                
                index += 1
            }
        }
    }
    
    override func awakeFromNib() {
        setupUI()
    }
    
    /// @param selectedIndex    选中照片索引
    /// @param urls             浏览照片 URL 字符串数组
    /// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
    
    @objc private func tapImageView(tap: UITapGestureRecognizer) {
        guard let iv = tap.view,
            let picURLs = viewModel?.picURLs else {
            return
        }
        var selectedIndex = iv.tag
        
        // 针对 4 张图处理
        if picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        let urls = (picURLs as NSArray).value(forKey: "largePic") as! [String]
        //处理课件的图像视图数组
        var imageViewList = [UIImageView]()
        for iv in subviews as! [UIImageView] {
            if !iv.isHidden {
                imageViewList.append(iv)
            }
        }
        //发送通知
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: ZHStatusCellBrowserPhotoNotification),
            object: self,
            userInfo: [
                ZHStatusCellBrowserPhotoURLsKey: urls,
                ZHStatusCellBrowserPhotoSelectedIndexKey: selectedIndex,
                ZHStatusCellBrowserPhotoParentImageViewsKey: imageViewList
                ])
    }
}

 // MARK: - 设置界面
 extension ZHStatusPictureView {
    private func setupUI() {
        
        // 设置背景颜色
        backgroundColor = superview?.backgroundColor
        
        // 超出边界的内容不显示
        clipsToBounds = true
        
        let count = 3
        let rect = CGRect(x: 0,
                          y: ZHStatusPictureViewOutterMargin,
                          width: ZHStatusPictureItemWidth,
                          height: ZHStatusPictureItemWidth)
        
        
        for i in 0..<count * count {
            let iv = UIImageView()
            iv.backgroundColor = UIColor.red
            
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            
            // 行 -> Y
            let row = CGFloat(i / count)
            // 列 -> X
            let col = CGFloat(i % count)
            let xOffset = col * (ZHStatusPictureItemWidth + ZHStatusPictureViewInnerMargin)
            let yOffset = row * (ZHStatusPictureItemWidth + ZHStatusPictureViewInnerMargin)
            
            iv.frame = rect.offsetBy(dx: xOffset, dy: yOffset)
            addSubview(iv)
            
            iv.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            iv.addGestureRecognizer(tap)
            iv.tag = i
            
            addGifView(iv: iv)
        }
    }
    
    /// 向图像视图添加 gif 提示图像
    ///
    /// - Parameter iv: 图像
    private func addGifView(iv: UIImageView) {
        let gifImageView = UIImageView(image: UIImage(named: "vip"))
        iv.addSubview(gifImageView)
        
        //自动布局
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .right,
                                            multiplier: 1.0,
                                            constant: 0))
        iv.addConstraint(NSLayoutConstraint(item: gifImageView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: iv,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0))
    }
 }
