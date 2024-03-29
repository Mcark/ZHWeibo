//
//  Date+Extension.swift
//  Weibo
//
//  Created by SanRong on 2019/3/26.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation

/// 日期格式化器 - 不要频繁创建和释放, 影响性能
private let dateFormatter = DateFormatter()

/// 当前日历对象
private let calendar = Calendar.current

extension Date {
    /// 计算与当前系统时间偏差 delta 秒数的日期字符串
    /// 在 Swift 中, 如果要定义结构体的 '类' 函数, 使用 static 修饰 -> 静态函数
    static func zh_dateString(delta: TimeInterval) -> String {
        let date = Date(timeIntervalSinceNow: delta)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    /// 将新浪格式的字符串转换成日期
    ///
    /// - Parameter string: Tue Sep 15 12:12:00 +0800 2015
    /// - Returns: 日期
    static func zh_sinaDate(string: String) -> Date? {
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        return dateFormatter.date(from: string)
    }
    
    
    var zh_dateDescription: String {
        //1. 判断日期是否是今天
        if calendar.isDateInToday(self) {
            let delta = -Int(self.timeIntervalSinceNow)
            
            if delta < 60 {
                return "刚刚"
            }
            
            if delta < 3600 {
                return "\(delta / 60) 分钟前"
            }
            
            return "\(delta / 3600) 小时前"
        }
        
        //2.其他天
        var fmt = " HH:mm"
        if calendar.isDateInYesterday(self) {
            fmt = "昨天" + fmt
        } else {
            fmt = "MM-dd" + fmt
            let year = calendar.component(.year, from: self)
            let thisYear = calendar.component(.year, from: Date())
            if year != thisYear {
                fmt = "yyyy-" + fmt
            }
        }
        
        //设置日期格式字符串
        dateFormatter.dateFormat = fmt
        
        return dateFormatter.string(from: self)
    }
}
