//
//  ZHSQLiteManager.swift
//  AddressBook
//
//  Created by SanRong on 2019/3/25.
//  Copyright © 2019 SanRong. All rights reserved.
//

import Foundation
import FMDB

/// 最大的数据库缓存时间, 以 s 为单位

// FIXME: 测试
private let maxDBCacheTime: TimeInterval = 60 // -5 * 24 * 60 * 60

/// SQLite 管理器
/**
 1.数据库本质上是保存在沙盒中的一个文件, 首先需要创建并且打开数据库
 2.创建数据表
 3.增删改查
 */

class ZHSQLiteManager {
    
    /// 单例, 全局数据库工具访问点
    static let shard = ZHSQLiteManager()
    
    /// 数据库队列
    let queue: FMDatabaseQueue?
    
    /// 构造函数
    private init() {
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName)
        print("数据库路径: " + path)
        
        //创建数据库队列, 同时 '创建或打开' 数据库
        queue = FMDatabaseQueue(path: path) //?? FMDatabaseQueue()
        
        // 注册通知 - 监听应用程序进入后台   模仿SDWebImage
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    /// 清理数据缓存 - 针对时间 5 天 : maxDBCacheTime
    ///   - SQLite: 不断增加数据, 数据库会增加. 但是, 如果删除数据,数据库不会变小!
    ///     如果要想变小:
    ///     1.将数据库文件复制一个新的副本,status.db.old
    ///     2.新建一个空的数据库文件
    ///     3.自己编写SQL, 从 old 中将所有的数据读出, 写入新的数据库!
    @objc func clearDBCache() {

        let dateString = Date.zh_dateString(delta: maxDBCacheTime)
        
        let sql = "DELETE FROM T_Status WHERE creatTime < ?;"
        queue?.inDatabase({ (db) in
            if db.executeUpdate(sql, withArgumentsIn: [dateString]) == true {
                print("删除了 \(db.changes) 条数据")
            }
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 微博数据操作
extension ZHSQLiteManager {
    
    /// 从数据库加载微博数据数组
    ///
    /// - Parameters:
    ///   - userId: 当前登录的用户账户
    ///   - since_id: 返回ID比since_id大的微博
    ///   - max_id: 返回ID比max_id小的微博
    /// - Returns: 微博的字典的数组, 将数据库中 status 字段对应的二进制数据反序列化, 生成字典
    func loadStatus(userId: String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String: AnyObject]] {
        
        // 1.准备SQL
        var sql = "SELECT statusId, userId, status FROM T_Status; \n"
        sql += "WHERE userId = \(userId) \n"
        
        // 上拉 / 下拉, 都是针对同一个id进行判断
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        //print(sql)
        
        // 2.执行SQL
        let array = execRecordSet(sql: sql)
        // 3.遍历数组, 将数组中的 status 反序列化 -> 字典的数组
        var result = [[String: AnyObject]]()
        for dict in array {
            guard let jsonData = dict["status"] as? Data,
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject] else {
                continue
            }
            result.append(json ?? [:])
        }
        
        return result
    }
    
    
    /// 执行一个 sql, 返回字典的数组
    ///
    /// - Parameter sql: sql
    /// - Returns: 字典的数组
    func execRecordSet(sql: String) -> [[String: AnyObject]] {
        
        // 结果数组
        var result = [[String: AnyObject]]()
        
        // 执行 SQL - 查询数据, 不会修改数据, 所以不需要开启事务!
        // 事务的目的, 是为了保证数据的有效性, 一旦失败, 回滚到初始状态
        queue?.inDatabase({ (db) in
            guard let rs = db.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            // 逐行 - 遍历结果集合
            while rs.next() {
                // 1. 列数
                let colCount = rs.columnCount
                // 2. 遍历所有列
                for col in 0..<colCount {
                    // 3. 列名 -> KEY / 值 -> Value
                    guard let name = rs.columnName(for:col),
                        let value = rs.object(forColumnIndex: col) else {
                            continue
                    }
                    
                    //print("\(name) - \(value)")
                    
                    // 4. 追加结果
                    result.append([name: value as AnyObject])
                }
            }
            
        })
        return result
    }
    
    /// 新增或修改微博数据, 微博数据在刷新的时候, 可能会出现重叠
    ///
    /// - Parameters:
    ///   - userId: 当前登录用户的Id
    ///   - array: 从网络获取的字典数组
    func updateStatus(userId: String, array: [[String: AnyObject]]) {
        // 1. 准备SQL
        // --- 测试插入数据, OR REPLACE: SQLite特有, 插入主键相同, 覆盖.  插入主键不同, 新增. ---
        /**
         statusId : 要保存的微博代号
         userId : 当前登录用户的id
         status : 完整微博字典的 json 二进制数据
         */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, userId, status) VALUES (?, ?, ?);"
        queue?.inTransaction({ (db, rollback) in
            for dict in array {
                // 从字典获取微博代号 / 将字典序列化成二进制数据
                guard let statusId = dict["idstr"] as? String,
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else  {
                        continue
                }
                // 执行 sql
                if db.executeUpdate(sql, withArgumentsIn: [statusId, userId, jsonData]) {
                    // FIXME: 需要回滚
                    // Xcode 自动语法转换, 不会处理此处
                    rollback.pointee = true
                    break
                }
            }
        })
    }
}

// MARK: - 创建数据表以及其他私有方法
private extension ZHSQLiteManager {
    func creatTable() {
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
            let sql = try? String(contentsOfFile: path) else {
            return
        }
        
        print("数据库路径: --- \(path)")
        
        // FMDB 串行队列, 同步执行
        //可以保证同一时间内, 只有一个任务操作数据库, 从而保证数据库的读写安全
        queue?.inDatabase({ (db) in
            
            // 只有在创标的时候, 使用执行多条语句, 可以一次创建多个数据表
            // 在执行增删改的时候, 一定不要使用 statements 方法, 否则可能会被注入!
            if db.executeStatements(sql) == true {
                print("创建成功")
            } else {
                print("创建失败")
            }
        })
    }
}
