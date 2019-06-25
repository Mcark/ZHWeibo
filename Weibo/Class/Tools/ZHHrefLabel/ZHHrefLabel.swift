//
//  ZHHrefLabel.swift
//  Weibo
//
//  Created by SanRong on 2019/3/21.
//  Copyright © 2019 SanRong. All rights reserved.
//

import UIKit

// 创建超链接
class ZHHrefLabel: UILabel {

    // MARK: - 重写属性 - 内容变化, 需要 textStorage 响应变化!
    override var text: String? {
        didSet {
            // 重新准备文本内容
            prepareTextContent()
        }
    }
    
    /// MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareTextSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTextSystem()
    }
    
    /// MARK: - 交互
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. 获取用户点击的位置
        guard let location = touches.first?.location(in: self) else {
            return
        }
        // 2. 获取当前点中字符的索引
        let idx = layoutManager.glyphIndex(for: location, in: textContainer)
        // 3. 判断 idx 是否在 urls 的 ranges 范围内, 如果在, 就高亮
        for r in urlRanges ?? [] {
            if NSLocationInRange(idx, r) {
                print("需要高亮")
                
                // 修改文本的字体属性
                textStorage.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: r)
                // 如果需要重绘, 需要调用 setNeedsDisplay() 函数, 但是不是 drawRect
                setNeedsDisplay()
            } else {
                print("没戳着")
            }
        }
    }
    
    /// 绘制
    /// - 在 iOS 中绘制工作类似于"油画",后绘制的内容, 会把之前绘制的内容覆盖!
    /// - 尽量避免使用带透明度的颜色, 会严重影响性能!
    /// - Parameter rect: 重写系统方法
    override func drawText(in rect: CGRect) {
        
        let range = NSRange(location: 0, length: textStorage.length)
        // 绘制背景
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        // Glyphs: 字形 - 绘制字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
    }
    
    /// MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainer.size = bounds.size
    }
    
    // MARK: - TextKit 的核心对象
    /// 属性文本属性
    private lazy var textStorage = NSTextStorage()
    /// 负责文本 '字形' 布局
    private lazy var layoutManager = NSLayoutManager()
    /// 设定文本绘制的范围
    private lazy var textContainer = NSTextContainer()

}

// MARK: - 设置 TextKit 核心对象
extension ZHHrefLabel {
    /// 准备文本系统
    func prepareTextSystem() {
        
        // 0.开启用户交互
        isUserInteractionEnabled = true
        
        // 1.准备文本内容
        prepareTextContent()
        
        // 2.设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    /// 准备文本内容 - 使用 textStorage 接管 label 的内容
    func prepareTextContent() {
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        } else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        } else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
        
        //遍历范围数组, 设置 URL 文字的属性
        for r in urlRanges ?? [] {
            textStorage.addAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                    NSAttributedString.Key.backgroundColor: UIColor.init(white: 0.9, alpha: 1)
                ],
                range: r)
        }
    }
}

private extension ZHHrefLabel {
    var urlRanges: [NSRange]? {
        /// url正则
        let pattern = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        var ranges = [NSRange]()
        
        for m in matches {
            ranges.append(m.range(at: 0))
        }
        
        return []
    }
}
