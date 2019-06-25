//
//  ZHDiscoverController.swift
//  Weibo
//
//  Created by SanRong on 2019/2/15.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHDiscoverController: ZHBaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 测试修改token
        ZHNetworkManager.shared.userAccount.access_token = nil
        print("修改了 token ")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
