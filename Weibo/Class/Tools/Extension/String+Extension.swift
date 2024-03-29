//
//  String+Extension.swift
//  Weibo
//
//  Created by SanRong on 2019/3/21.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation

extension String {
    
    /// 从当前字符串中, 提取连接和文本
    ///
    /// - Returns: 元组,  同时返回多个值
    func zh_href() -> (link: String, text: String)? {
        //0.匹配方案
        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
        //1.创建正则表达式, 并且匹配第一项
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []),
            let result = regx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) else {
            return nil
        }
        //2.获取结果
        let link = (self as NSString).substring(with: result.range(at: 1))
        let text = (self as NSString).substring(with: result.range(at: 2))
        return (link, text)
    }
}
