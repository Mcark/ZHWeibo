//
//  ZHNewFeature.swift
//  Weibo
//
//  Created by SanRong on 2019/3/7.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

class ZHNewFeature: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBAction func enterStatus() {
        
    }
    
    class func newFeatureView() -> ZHNewFeature {
        let nib = UINib(nibName: "ZHNewFeature", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! ZHNewFeature
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        let count = 4
        let rect = UIScreen.main.bounds
        
        for i in 0..<count {
            let imageName = "\(i + 1)"
            let iv = UIImageView(image: UIImage(named: imageName))
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
        }
        scrollView.contentSize = CGSize(width: CGFloat(count + 1) * rect.width, height: rect.height)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        startBtn.isHidden = true
    }
}

extension ZHNewFeature: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if page == scrollView.subviews.count {
            removeFromSuperview()
        }
        startBtn.isHidden = (page != scrollView.subviews.count - 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        startBtn.isHidden = true
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        pageControl.currentPage = page
        pageControl.isHidden = (page == scrollView.subviews.count)
    }
}
