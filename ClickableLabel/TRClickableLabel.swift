//
//  TRClickableLabel.swift
//  TRClickableLabel
//
//  Created by caishengbo on 2023/12/19.
//

import UIKit

extension NSAttributedString.Key {
    
    public static let action: NSAttributedString.Key = NSAttributedString.Key("TRAction")
}

typealias TRClickableLabelActionCallback = ((TRClickableLabel) -> ())

class TRClickableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let index = characterIndex(at: point)
        guard let attributedText = self.attributedText, attributedText.length >= index else { return }
        guard let action = attributedText.attribute(.action, at: index, effectiveRange: nil) as? TRClickableLabelActionCallback else {
            return
        }
        action(self)
    }
    
    private func characterIndex(at point: CGPoint) -> CFIndex {
        guard let attributedText = attributedText else {
            return NSNotFound
        }
        guard bounds.contains(point) else {
            return NSNotFound
        }
        var textRect = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        if bounds.height > textRect.height {
            textRect.origin.y = textRect.origin.y + (bounds.height - textRect.height)/2
        }
        guard textRect.contains(point) else {
            return NSNotFound
        }
        var p = CGPoint(x: point.x - textRect.origin.x, y: point.y - textRect.origin.y)
        // 将点击的UI坐标系（左上角{0,0}），转换成core text坐标系（左下角{0,0}）
        p = CGPoint(x: p.x, y: textRect.size.height - p.y)
        
        let path = CGMutablePath()
        path.addRect(textRect)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
        
        let frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)
        let lines = CTFrameGetLines(frameRef)
        let numberOfLines = self.numberOfLines > 0 ? min(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines)
        guard numberOfLines > 0 else {
            return NSNotFound
        }
        var idx: CFIndex = NSNotFound
        var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: numberOfLines)
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, numberOfLines), &lineOrigins)
        
        for lineIndex in 0..<numberOfLines {
            var lineOrigin = lineOrigins[lineIndex]
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, lineIndex), to: CTLine.self)
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
            let yMin = CGFloat(floor(lineOrigin.y - descent))
            let yMax = CGFloat(ceil(lineOrigin.y + ascent))
            let flushFactor = getFlushFactor()
            let penOffset = CGFloat(CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width))
            lineOrigin.x = penOffset
            
            // 如果已经超过了line，不再继续
            if (p.y > yMax) {
                break
            }
            
            if (p.y >= yMin) {
                // 横向坐标检查
                if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                    // 将ct坐标转换成Line的相对坐标
                    let relativePoint = CGPoint(x: p.x - lineOrigin.x, y: p.y - lineOrigin.y)
                    
                    idx = CTLineGetStringIndexForPosition(line, relativePoint)
                    
                    /// CTLineGetStringIndexForPosition方法 点击字符的左半边，可以正常获取index，但是点击字符的右半边，会拿到下一个字符的index，原因不明。
                    /// 因此这里，取一下上一个的origin，看是否小于点击的位置，如果是，实际点击的就是这个点
                    let idxOffset = CTLineGetOffsetForStringIndex(line, idx, nil)
                    if idxOffset > relativePoint.x && idx > 0 {
                        let upper = idx - 1
                        for i in stride(from: upper, through: 0, by: -1) {
                            let offset = CTLineGetOffsetForStringIndex(line, i, nil)
                            if offset <= relativePoint.x {
                                idx = i
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
        return idx
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        <#code#>
    }
    
    /// flushFactor小于等于0：左对齐。大于等于1.0：右对齐。  0到1.0之间：中心对齐，0.5：完全中心对齐。
    private func getFlushFactor() -> CGFloat {
        switch textAlignment {
        case .left:
            return 0
        case .center:
            return 0.5
        case .right:
            return 1
        default:
            return 0
        }
    }
}
