//
//  UIImageView+WebImage.swift
//  Weibo
//
//  Created by SanRong on 2019/3/12.
//  Copyright © 2019 SanRong. All rights reserved.
//

import SDWebImage

extension UIImageView {
    
    /// 隔离 SDWebImage 设置图像函数
    ///
    /// - Parameters:
    ///   - urlString: urlString
    ///   - placeholderImage: 占位图像
    ///   - isAvatar: 是否是头像
    func zh_setImage(urlString: String?, placeholderImage: UIImage?, isAvatar: Bool = false) {
        
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
            //设置占位图像
            image = placeholderImage
            return
        }
        
        // 可选项只是用在 Swift, OC 有的时候用 ! 同样可以传入 nil
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) { [weak self] (image, _, _, _) in
            //完成回调 - 判断是否是头像
            if isAvatar {
                
                self?.image = image?.zh_avatarImage(size: self?.bounds.size)
            }
        }
    }
}
