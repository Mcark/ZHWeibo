//
//  UIImage+Extension.swift
//  Weibo
//
//  Created by SanRong on 2019/3/12.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

extension UIImage {
//class UIImage_Extension: UIImage {

    /// 创建头像图像
    ///
    /// - Parameters:
    ///   - size: 尺寸
    ///   - backColor: 背景颜色
    ///   - lineColor: 边框颜色
    ///   - lineWidth: 边框宽度
    /// - Returns: 裁切后的图像
    func zh_avatarImage(size: CGSize?, backColor: UIColor = UIColor.white, lineColor: UIColor = UIColor.lightGray, lineWidth: CGFloat = 2.0) -> UIImage? {
        
        var size = size
        if size == nil {
            size = self.size
        }
        
        let rect = CGRect(origin: CGPoint(), size: size!)
        
        //1.图像的上下文 - 内存中开辟一个地址, 跟屏幕无关!
        // 参数:
        // 1> size : 绘图的尺寸
        // 2> 不透明: false(透明) / true(不透明)
        // 3> scale: 屏幕分辨率, 默认生成的图像使用 1.0 分辨率, 图像质量不好. 可以指定为 0, 会选择当前设备的屏幕分辨率
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        //------------------------------------------------------------------
        //绘制圆角
        // 0>背景填充
        backColor.setFill()
        UIRectFill(rect)
        // 1> 实例化一个圆形的路径
        let path = UIBezierPath(ovalIn: rect)
        // 2> 进行路径裁切 - 后续的绘图, 都会出现在圆形路径内部, 外部的全部干掉
        path.addClip()
        
        //2. 绘图 drawInRect 就是在指定区域内拉伸屏幕
        draw(in: rect)
        
        // 3> 绘制内切的圆形
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = lineWidth
        lineColor.setStroke()
        ovalPath.stroke()
        //------------------------------------------------------------------
        
        //3. 取得结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        //4. 关闭上下文
        UIGraphicsEndImageContext()
        return result
    }
}


// MARK: - 颜色创建图片
// 使用: imgView.image = UIImage.from(color: .red)
extension UIImage {
    
    class func imageFromColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
