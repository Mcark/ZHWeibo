//
//  RegularExpression.swift
//  Weibo
//
//  Created by SanRong on 2019/3/19.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation

/***
正则表达式: '匹配'字符串, 进行模糊查找
1> .(点): 匹配任意字符, 回车除外
2> *    : 匹配任意多次
3> ?    : 尽量少的匹配
 */

/**
拖入素材
1.黄色文件夹, 打包的时候, 不会创建目录, 主要保存程序文件
    - 素材不允许重名
2.蓝色文件夹, 会创建目录, 可以分目录保存素材文件
    - 素材可以重名, 主要用于 游戏的场景(不同的场景名字相同,文件夹不同), 手机应用皮肤
    - 不能把程序文件放在蓝色文件夹中
3.Bundle
    - 通常用在第三方框架素材, 可以按照黄色文件夹方式拖拽, 同时保留目录结构, 避免文件重名
*/

extension NSRegularExpression {
    func regularExpression() {
        
//        let string = "<a href=\"http://app.weibo.com/t/feed/6vtZb0\" rel=\"nofollow\">微博 weibo.com</a>"
//        let result = string.zh_href()
        
        
//        // 1. <a href=\"http://app.weibo.com/t/feed/6vtZb0\" rel=\"nofollow\">微博 weibo.com</a>
//        // 目标: 取出 href 中的链接, 以及 文本描述
//        let string = "<a href=\"http://app.weibo.com/t/feed/6vtZb0\" rel=\"nofollow\">微博 weibo.com</a>"
//        // 2. 创建正则表达式
//        // 0> pattern - 匹配方案
//        // 0: 和匹配方案完全一致的字符串
//        // 1: 第一个 () 中的内容
//        // 2: 第二个 () 中的内容
//        // ... 索引从左向右顺序递增
//        // 对于模糊匹配, 如果关心的内容, 就用 (.*?) , 然后通过索引获取结果
//        // 如果不关心的内容, 就用 '.*?' , 可以匹配任意内容
////        let pattern = "<a href=\"(.*?)\" rel=\"nofollow\">(.*?)</a>"
//
//        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
//
//        // 1> 创建正则表达式, 如果 pattern 失败, 抛出异常
//        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
//            return
//        }
//        guard let result = regx.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) else {
//            print("没有找到匹配项")
//            return
//        }
//
//        print("找到的数量 \(result.numberOfRanges)")
//        for idx in 0..<result.numberOfRanges {
//            let r = result.range(at: idx)
//            let subStr = (string as NSString).substring(with: r)
//
//            print(subStr)
//        }
    }
}
