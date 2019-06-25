//
//  ZHBaseController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHBaseController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var navigationBar = ZHNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
    lazy var navItem = UINavigationItem()
    lazy var tableView: UITableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 49))
    var refresh:ZHRefreshControl = ZHRefreshControl()
    
    var isPullup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(rawValue: ZHUserLoginSuccessNotification), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var title: String? {
        didSet {
            navItem.title = title
        }
    }
    func loadData() {
        refresh.endRefreshing()
    }
}

extension ZHBaseController {
    
    @objc func setUI() {
        
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        view.backgroundColor = color
        
        view.addSubview(navigationBar)
        navigationBar.items = [navItem]
        
        navigationBar.tintColor = UIColor.red
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //修改 tableview 指示器的缩进(滚动条)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        refresh .addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        tableView.addSubview(refresh)
        
        view.addSubview(tableView)
    }
    
    @objc func refreshAction() {
        loadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    @objc private func loginSuccess() {
        
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        
        // 在访问 view 的 getter 时, 如果 view == nil 会调用 loadView -> viewDidLoad
        view = nil
        
        NotificationCenter.default.removeObserver(self)
    }
}
