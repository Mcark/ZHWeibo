//
//  ZHTabbarController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHTabbarController: UITabBarController {

    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setChildControllers()
        setuptimer()
        
        setupNewFeatureViews()
        
        delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin), name: NSNotification.Name(rawValue: ZHUserShouldLoginNotification), object: nil)
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知方法, 用户登录
    @objc private func userLogin(n: Notification) {
        print("用户登录通知")
        
        let nav = UINavigationController(rootViewController: ZHOAuthController())
        present(nav, animated: true, completion: nil)
    }
}

extension ZHTabbarController {
    private func setChildControllers() {
        
        // 获取沙盒 json 路径, 如果有, 就是从网络获取的, 就不需要加载本地的 json 了
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as String).appending("/main.json")
        var data = NSData(contentsOfFile: jsonPath)
        //判断 data 是否有内容, 如果没有, 说明本地沙盒没有文件
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
        }
        
        // data 中一定有一个内容, 反序列化
        
        
        guard let controllerArray = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String: AnyObject]]
            else {
                return
        }
        
//        let controllerArray = [
//            ["clsName": "ZHHomeController", "title": "首页", "imageName": "index",
//             "vistorInfo": ["imageName": "", "message": "关注一些人, 回这里看看有什么惊喜"]
//            ],
//            ["clsName": "ZHDiscoverController", "title": "发现", "imageName": "find",
//             "vistorInfo": ["imageName": "", "message": "关注一些人, 回这里看看有什么惊喜"]
//            ],
//            ["clsName": "ZHMessageController", "title": "消息", "imageName": "exercise",
//             "vistorInfo": ["imageName": "", "message": "关注一些人, 回这里看看有什么惊喜"]
//            ],
//            ["clsName": "ZHMeController", "title": "我", "imageName": "me",
//             "vistorInfo": ["imageName": "", "message": "关注一些人, 回这里看看有什么惊喜"]
//            ]
//        ]
//
//        // 数组 -> json 序列化
////        let data = try! JSONSerialization.data(withJSONObject: controllerArray, options: [.prettyPrinted])
////        (data as NSData).write(toFile: "/Users/sanrong/Desktop/demo.json", atomically: true)
        
        var arrayM = [UIViewController]()
        for dict in controllerArray! {
            arrayM.append(setViewControllers(dict: dict as [String : AnyObject]))
        }
        viewControllers = arrayM
    }
    
    /// 使用字典创建控制器
    ///
    /// - Parameter dict: 字典
    /// - Returns: controller
    private func setViewControllers(dict: [String: AnyObject]) -> UIViewController {
        
        let classN = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        
        guard let className = dict["clsName"] as? String,
              let imageNmae = dict["imageName"] as? String,
              let title     = dict["title"] as? String,
              let cls = NSClassFromString(classN + "." + className) as? UIViewController.Type
        else {
            return UIViewController()
        }
        let vc = cls.init()
        vc.title = title
        
        vc.tabBarItem.image = UIImage(named: imageNmae)
        vc.tabBarItem.selectedImage = UIImage(named: imageNmae + "_selected")?.withRenderingMode(.alwaysOriginal)
        
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .highlighted)
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .normal)
        
        let naVC = ZHNavigationController.init(rootViewController: vc)
        return naVC
    }
}

// MARK: - 时钟相关方法
extension ZHTabbarController {
    private func setuptimer() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    /// 时钟触发方法
    @objc private func updateTimer() {
        ZHNetworkManager.shared.unreadCount { (count) in
            //设置 首页 tabbarItem 的 badgeNumber
            self.tabBar.items?[0].badgeValue = count > 0 ? "\(count)" : nil
            
            //设置 App 的 badgeNumber
            UIApplication.shared.applicationIconBadgeNumber = count > 0 ? count : 0
        }
    }
}

// MARK: - 新特性视图处理
extension ZHTabbarController {
    private func setupNewFeatureViews() {
        //0.判断是否登录
        //1.检查版本是否更新
        //2.如果更新,显示新特性,否则显示欢迎
        let v = isNewVersion ? ZHNewFeature.newFeatureView() : ZHWelcomeView.welcomeView()
        //3.添加视图
        view.addSubview(v)
    }
    
    
    /// extension 中可以有计算型属性, 不会占用存储空间
    /// 构造函数: 给属性分配空间
    private var isNewVersion: Bool {
        //当前版本
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as String).appending("version")
        //沙盒版本
        let sandboxVersion = (try? String(contentsOfFile: jsonPath)) ?? ""
        
        try? currentVersion.write(toFile: jsonPath, atomically: true, encoding: .utf8)
        
        // FIXME: - 测试新特性页面
        return currentVersion != sandboxVersion
//        return currentVersion == sandboxVersion
    }
}

// MARK: - 代理 UITabBarControllerDelegate
extension ZHTabbarController: UITabBarControllerDelegate {
    
    /// 将要选择 TabBarItem
    ///
    /// - Parameters:
    ///   - tabBarController: tabBarController
    ///   - viewController: 目标控制器
    /// - Returns: 是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        print("将要切换到 \(viewController)")
        
        let idx = (children as NSArray).index(of: viewController)
        if selectedIndex == 0 && selectedIndex == idx {
            
            let nav = children[0] as! ZHNavigationController
            let vc = nav.children[0] as! ZHHomeController
            vc.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                vc.loadData()
            }
            self.tabBar.items?[0].badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
            //FIXME: - 测试发布微博
        else if selectedIndex == 3 && selectedIndex == idx {
            composeStatus()
        }
        
        // 判断目标控制器是否是 UIViewController
        return !viewController.isMember(of: UIViewController.self)
    }
}


// MARK: - 撰写微博类型. 点击tabbar中间的加号按钮, 没有实现
extension ZHTabbarController {
    @objc private func composeStatus() {
        
        let v = ZHComposeTypeView.composeTypeView()
        //注意闭包的循环引用
        v.show { [weak v] (clsName) in
            //展现撰写微博控制器
            let classN = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
            
            guard let clsName = clsName,
                let cls = NSClassFromString(classN + "." + clsName) as? UIViewController.Type else {
                    v?.removeFromSuperview()
                    return
            }
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true) {
                v?.removeFromSuperview()
            }
        }
    }
}
