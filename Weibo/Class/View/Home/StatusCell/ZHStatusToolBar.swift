//
//  ZHStatusToolBar.swift
//  Weibo
//
//  Created by SanRong on 2019/3/13.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHStatusToolBar: UIView {

    var viewModel: ZHStatusViewModel? {
        didSet {
//            retweetedButton.setTitle("\(viewModel?.status.reposts_count)", for: .normal)
//            commentButton.setTitle("\(viewModel?.status.comments_count)", for: .normal)
//            likeButton.setTitle("\(viewModel?.status.attitudes_count)", for: .normal)
            
            retweetedButton.setTitle(viewModel?.retweetedStr, for: .normal)
            commentButton.setTitle(viewModel?.commentStr, for: .normal)
            likeButton.setTitle(viewModel?.likeStr, for: .normal)
        }
    }
    
    @IBOutlet weak var retweetedButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    
}
