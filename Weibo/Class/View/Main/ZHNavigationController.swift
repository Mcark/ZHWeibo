//
//  ZHNavigationController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationBar.isHidden = true
        
    }
}

extension ZHNavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            
            if let vc = viewController as? ZHBaseController {
                
                var title = "<返回"
                if children.count == 1 {
                    title = "<" + (children.first?.title ?? "返回")
                }
                
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(popToparent))
            }
        }
        
        super.pushViewController(viewController, animated: true)
    }
    
    @objc private func popToparent() {
        popViewController(animated: true)
    }
}
