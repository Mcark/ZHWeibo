//
//  ZHImageOptimizationController.swift
//  Weibo
//
//  Created by SanRong on 2019/3/11.
//  Copyright © 2019 SanRong. All rights reserved.

// 外加: 图片优化

import UIKit

class ZHImageOptimizationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
        iv.center = view.center
        view.addSubview(iv)
        
        //设置图像 - PNG 图片是支持透明的
        let image = UIImage(named: "avater")
        iv.image = avatarImage(image: image!, size: CGSize(width: 160, height: 160), backColor: view.backgroundColor)
    }
    
    func avatarImage(image: UIImage, size: CGSize, backColor: UIColor?) -> UIImage? {
        let rect = CGRect(origin: CGPoint(), size: size)
        
        //1.图像的上下文 - 内存中开辟一个地址, 跟屏幕无关!
        // 参数:
        // 1> size : 绘图的尺寸
        // 2> 不透明: false(透明) / true(不透明)
        // 3> scale: 屏幕分辨率, 默认生成的图像使用 1.0 分辨率, 图像质量不好. 可以指定为 0, 会选择当前设备的屏幕分辨率
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        //------------------------------------------------------------------
        //绘制圆角
        // 0>背景填充
        backColor?.setFill()
        UIRectFill(rect)
        // 1> 实例化一个圆形的路径
        let path = UIBezierPath(ovalIn: rect)
        // 2> 进行路径裁切 - 后续的绘图, 都会出现在圆形路径内部, 外部的全部干掉
        path.addClip()
        // 3> 绘制内切的圆形
        UIColor.green.setStroke()
        path.lineWidth = 2
        path.stroke()
        //------------------------------------------------------------------
        
        //2. 绘图 drawInRect 就是在指定区域内拉伸屏幕
        image.draw(in: rect)
        //3. 取得结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        //4. 关闭上下文
        UIGraphicsEndImageContext()
        return result
    }
}
