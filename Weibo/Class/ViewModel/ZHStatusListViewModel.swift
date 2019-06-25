//
//  ZHStatusListViewModel.swift
//  Weibo
//
//  Created by SanRong on 2019/2/26.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

/// 上拉刷新最大尝试次数
private let maxPullupTryTimes = 3

class ZHStatusListViewModel {
    lazy var statusList = [ZHStatusViewModel]()
    
    private var pullupErrorTimes = 0
    
    /// 加载微博列表
    ///
    /// - Parameter completion: 完成回调[网络请求是否成功, 是否有更多的上拉刷新]
    func loadStatus(pullup: Bool = false, completion: @escaping (_ isSuccess: Bool, _ hasMorePullup: Bool) -> ()) {
        
        if pullup && pullupErrorTimes > maxPullupTryTimes {
            completion(false, false)
            return
        }
        
        /// 取出数组中第一条id
        let since_id = pullup ? 0 : (statusList.first?.status.id ?? 0)
        
        /// 上拉加载更多取出
        let max_id = !pullup ? 0 : (statusList.last?.status.id ?? 0)
        
        // 新加: 数据缓存
        //让数据访问层加载数据
        ZHStatusListDAL.loadStatus(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
//        }
//
//        //发起网络请求, 加载微博数据[字典的数组]
//        ZHNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //----------------------------------------
            // 多加了一层viewmodel 之后, 需要遍历转换模型.
            
            //0. 判断网络请求是否成功
            if !isSuccess {
                // 如果请求失败,直接返回
                completion(false, false)
                return
            }
            // 遍历字典数组, 字典转 模型 => 试图模型, 将试图模型添加到数组
            //1>定义结果可变数组
            var array = [ZHStatusViewModel]()
            //2>遍历服务器返回的字典数组, 字典转模型
            for dict in list ?? [] {
                //创建微博模型 - 如果创建模型失败, 继续后续的遍历
                guard let model = ZHStatus.yy_model(with: dict) else {
                    continue
                }
                // 将视图模型 添加到数组
                array.append(ZHStatusViewModel(model: model))
                
//                //分开写
//                //1.创建微博模型
//                let status = ZHStatus()
//                //2.使用字典设置模型数值
//                status.yy_modelSet(with: dict)
//                //3.使用 '微博' 模型创建 '微博视图' 模型
//                let viewModel = ZHStatusViewModel(model: status)
//                //4.添加到数组
//                array.append(viewModel)
            }
//
//            guard let array = NSArray.yy_modelArray(with: ZHStatus.self, json: list ?? []) as? [ZHStatus] else {
//                completion(false, false)
//                return
//            }
            
            print("刷新了 \(array.count) 条数据")
            
            if pullup {
                self.statusList += array
            } else {
                self.statusList = array + self.statusList
            }
            
            //判断上拉刷新的数据量
            if pullup && array.count == 0 {
                self.pullupErrorTimes += 1
                completion(isSuccess, false)
            } else {
                self.cacheSingleImage(list: array, finished: completion)
//                completion(isSuccess, true)
            }
        }
    }
    
    /// 缓存本次下载微博数据数组中的单张图像
    /// (应该缓存完成单张图像, 并且修改过配图大小, 再回调, 才能保证m表格等比例显示单张图像)
    /// - Parameter list: 本次下载的视图模型数组
    private func cacheSingleImage(list: [ZHStatusViewModel], finished: @escaping (_ isSuccess: Bool, _ hasMorePullup: Bool) -> ()) {
        
        // 调度组
        let group = DispatchGroup()
        //记录数据长度
        var length = 0
        
        
        // 遍历数组, 查找微博数据中有单张图像的, 进行缓存
        for vm in list {
            // 1.判断图像数量
            if vm.picURLs?.count != 1 {
                continue
            }
            
            // 2.数组中有且只有一张图片
            guard let pic = vm.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else{
                continue
            }
            
            // 3.下载图像
            // 下载完成后,自动保存在沙盒, 文件路径是url的md5
            // 如果沙盒中已经存在, 后续 SD 通过URL加载图像, 会加载本地h沙盒的图像
            // 不会发起网络请求, 同时, 回调方法, 同样回调
            group.enter() // 入组
            SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: nil) { (image, _, _, _) in
                
                if let image = image,
                    let data = image.pngData() {
                    length += data.count
                    
                    // 图像缓存成功, 更新配图视图的大小
                    vm.updateSingleImageSize(image: image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("图像缓存完成 \(length / 1024) K")
            finished(true, true)
        }
    }
}
