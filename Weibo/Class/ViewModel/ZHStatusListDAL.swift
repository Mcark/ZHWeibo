//
//  ZHStatusListDAL.swift
//  Weibo
//
//  Created by SanRong on 2019/3/26.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation

/// DAL: - Data Access Layer 数据访问层
/// 使命: 负责处理数据库和网络数据, 给 ListViewModel 返回微博的[字典数组]

/**
    1. ListViewModel -> ListDAL -> SQLiteManager :
        检查本地是否有缓存数据, 如果有, 直接返回
 
    2. ListViewModel -> ListDAL -> NetworkManager -> SQLiteManager -> ListViewModel :
        如果没有缓存, 加载网络数据, 再将网络数据写入数据库, 最后返回 ListViewModel
 */

class ZHStatusListDAL {
    /// 从本地数据库或网络加载数据
    ///
    /// - Parameters:
    ///   - since_id: 下拉刷新 id
    ///   - max_id: 上拉刷新 id
    ///   - completion: 完成回调 (微博字典数组, 是否成功)
    class func loadStatus(since_id: Int64 = 0, max_id:Int64 = 0, completion: @escaping (_ list: [[String: Any]]?, _ isSuccess: Bool)->()) {
        //0.获取用户代号
        guard let userId = ZHNetworkManager.shared.userAccount.uid else {
            return
        }
        
        //1.检查本地数据, 如果有, 直接返回
        let array = ZHSQLiteManager.shard.loadStatus(userId: userId, since_id: since_id, max_id: max_id)
        // 判断数组数量, 没有数据返回的是没有数据的空数组 []
        if array.count > 0 {
            completion(array, true)
            return
        }
        
        //2.如果本地没有缓存, 加载网络数据
        ZHNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            //判断网络请求是否成功
            if !isSuccess {
                completion(nil, false)
                return
            }
            //3.加载完成, 将网络数据[字典数组], 写入数据库
            guard let list = list else {
                completion(nil, false)
                return
            }
            ZHSQLiteManager.shard.updateStatus(userId: userId, array: list as [[String : AnyObject]])
            //4.返回网络数据
            completion(list, isSuccess)
        }
    }
}
