//
//  WeiBoCommon.swift
//  Weibo
//
//  Created by SanRong on 2019/2/28.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 应用程序信息
let ZHAppKey = "829840129"
let ZHAppSecret = "3f87eb891f9257f9c4f3131b4dd25d79"
let ZHRedirectURL = "https://www.baidu.com"

// MARK: - 全局通知定义
/// 用户需要登录通知
let ZHUserShouldLoginNotification = "ZHUserShouldLoginNotification"
/// 用户登录成功通知
let ZHUserLoginSuccessNotification = "ZHUserLoginSuccessNotification"

// MARK: - 照片浏览器通知定义
/// @param selectedIndex    选中照片索引
/// @param urls             浏览照片 URL 字符串数组
/// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
/// 微博 Cell 浏览照片通知
let ZHStatusCellBrowserPhotoNotification = "ZHStatusCellBrowserPhotoNotification"
/// 选中索引 Key
let ZHStatusCellBrowserPhotoSelectedIndexKey = "ZHStatusCellBrowserPhotoSelectedIndexKey"
/// 浏览照片 URL 字符串 Key
let ZHStatusCellBrowserPhotoURLsKey = "ZHStatusCellBrowserPhotoURLsKey"
/// 父视图的图像视图数组 Key
let ZHStatusCellBrowserPhotoParentImageViewsKey = "ZHStatusCellBrowserPhotoParentImageViewsKey"

// MARK: - 微博配图视图常量
//配图视图外侧的间距
let ZHStatusPictureViewOutterMargin = CGFloat(12)
//配图视图内部图像视图的间距
let ZHStatusPictureViewInnerMargin = CGFloat(3)
//视图的宽度的宽度
let ZHStatusPictureViewWidth = UIScreen.main.bounds.width - 2 * ZHStatusPictureViewOutterMargin
//每个 Item 默认的宽度
let ZHStatusPictureItemWidth = (ZHStatusPictureViewWidth - 2 * ZHStatusPictureViewInnerMargin) / 3
