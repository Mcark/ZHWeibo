//
//  ZHTestController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHTestController: ZHBaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func showNext() {
        navigationController?.pushViewController(ZHTestController(), animated: true)
    }
}

extension ZHTestController {
    @objc override func setUI() {
        super.setUI()
        navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", style: .plain, target: self, action: #selector(showNext))
    }
}
