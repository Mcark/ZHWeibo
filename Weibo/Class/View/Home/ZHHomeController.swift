//
//  ZHHomeController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

// 原创微博可重用 Cell id
private let originalCellID = "originalCellID"
// 被转发微博的可重用 Cell id
private let retweetedCellID = "retweetedCellID"

class ZHHomeController: ZHBaseController {

    private lazy var listViewModel = ZHStatusListViewModel()
    
    override func loadData() {
        
        // 初始进入首页会刷新 - 新加
        refresh.beginRefreshing()
        
        listViewModel.loadStatus(pullup: self.isPullup) { (isSuccess, hasMorePullup) in
            self.refresh.endRefreshing()
//            self.isPullup = false
            
            if hasMorePullup {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(browserPhoto), name: NSNotification.Name(rawValue: ZHStatusCellBrowserPhotoNotification), object: nil)
    }
    
    @objc private func browserPhoto(n: Notification) {
        //1.从通知的 userInfo 提取参数
        guard let selectedIndex = n.userInfo?[ZHStatusCellBrowserPhotoSelectedIndexKey] as? Int,
            let urls = n.userInfo?[ZHStatusCellBrowserPhotoURLsKey] as? [String],
            let imageViewList = n.userInfo?[ZHStatusCellBrowserPhotoParentImageViewsKey] as? [UIImageView] else {
            return
        }
        //2.展现照片浏览器控制器
        let vc = HMPhotoBrowserController.photoBrowser(withSelectedIndex: selectedIndex, urls: urls, parentImageViews: imageViewList)
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func friendAction() {
//        let testVC = ZHTestController()
//        navigationController?.pushViewController(testVC, animated: true)
        
//        // 发送需要登录的通知,  测试
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ZHUserShouldLoginNotification), object: nil)
        
        // FIXME: 测试发布微博
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
extension ZHHomeController {
    @objc override func setUI() {
        super.setUI()

        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", style: .plain, target: self, action: #selector(friendAction))
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: "ZHStatusNormalCell", bundle: nil), forCellReuseIdentifier: originalCellID)
        tableView.register(UINib(nibName: "ZHStatusRetweetedCell", bundle: nil), forCellReuseIdentifier: retweetedCellID)
        
        //设置行高
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 300
        //取消分割线
        tableView.separatorStyle = .none
        
        setupNavTitle()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let viewModel = listViewModel.statusList[indexPath.row]
        
        let cellId = (viewModel.status.retweeted_status != nil) ? retweetedCellID : originalCellID
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ZHStatusCell
        
        cell.viewModel = viewModel
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 1. 根据 indexPath 获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        return vm.rowHeight
    }
    
    private func setupNavTitle() {
        
        let title = ZHNetworkManager.shared.userAccount.screen_name
        
        let btn = ZHTitleButton(title: title)
        
        btn.addTarget(self, action: #selector(clickTitle), for: .touchUpInside)
        
        navItem.titleView = btn
    }
    
    @objc private func clickTitle(btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
}

// MARK: - ZHStatusCellDelegate
extension ZHHomeController: ZHStatusCellDelegate {
    func statusCellDidSelectedURLString(cell: ZHStatusCell, urlString: String) {
        let vc = ZHWebViewController()
        vc.urlString = urlString
        navigationController?.pushViewController(vc, animated: true)
    }
}
