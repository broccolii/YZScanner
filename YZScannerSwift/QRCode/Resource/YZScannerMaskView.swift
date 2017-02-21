//
//  YZScannerMaskView.swift
//  QRCode
//
//  Created by Broccoli on 2017/2/16.
//  Copyright © 2017年 Broccoli. All rights reserved.
//

import UIKit

class YZScannerMaskView: UIView {

    var scannerWindowFrame = CGRect.zero
    var windowView: YZScannerWindowView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup subviews
    func setupSubviews() {
        self.addSubview(self.backgroundView)
        self.addSubview(self.windowView)
        self.startScanning()
    }
    
    // MARK: - getter
    let backgroundView: YZScannerBackgroundView = {
        if !self.backgroundView {
            self.backgroundView = YZScannerBackgroundView(frame: self.frame, scannerWindowFrame: self.scannerWindowFrame, fillColor: UIColor.black.withAlphaComponent(0.6))
        }
        return self.backgroundView
    }()
    
    func windowView() -> YZScannerWindowView {
        if !self.windowView {
            self.windowView = YZScannerWindowView(self.scannerWindowFrame, borderLineColor: UIColor(red: CGFloat(0.443), green: CGFloat(0.722), blue: CGFloat(0.569), alpha: CGFloat(1.0)))
        }
        return self.windowView
    }
    
    func scannerWindowFrame() -> CGRect {
        if self.scannerWindowFrame.equalTo(CGRect.zero) {
            var y: CGFloat = 175
            var x: CGFloat = 25
            var width: CGFloat = UIScreen.main.bounds.size.width - 2 * x
            var height: CGFloat = 220
            self.scannerWindowFrame = CGRect(x: x, y: y, width: width, height: height)
        }
        return self.scannerWindowFrame
    }
    // MARK: - publick method
    
    func startScanning() {
        self.windowView().startScanning()
    }
    
    func stopScanning() {
        self.windowView().stopScanning()
    }
    let kActivityBackgroundViewTag: Int = 1001
    let kActivityViewTag: Int = 1002
    
    func startLoadingAnimation() {
        self.windowView.isHidden = true
        self.backgroundView.isHidden = true
        var activityBackgroundView = UIView(frame: self.frame)
        activityBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        activityBackgroundView.tag = kActivityBackgroundViewTag
        self.addSubview(activityBackgroundView)
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.center
        activityView.tag = kActivityViewTag
        self.addSubview(activityView)
        activityView.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.windowView.isHidden = false
        self.backgroundView.isHidden = false
        var activityBackgroundView: UIView? = self.viewWithTag(kActivityBackgroundViewTag)
        activityBackgroundView?.removeFromSuperview()
        var activityView: UIView? = self.viewWithTag(kActivityViewTag)
        activityView?.removeFromSuperview()
    }
}

class YZScannerBackgroundView: UIView {
    
    var scannerWindowFrame: CGFloat
    var fillColor: UIColor
    
    override init(frame: CGRect, scannerWindowFrame: CGRect, fill fillColor: UIColor) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
        self.fillColor = fillColor
        self.scannerWindowFrame = scannerWindowFrame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        var context: CGContext? = UIGraphicsGetCurrentContext()
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
        var result: Bool = self.fillColor.getRed(red, green: green, blue: blue, alpha: alpha)
        if !result {
            return
        }
        context.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        //上面
        var fillRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.frame.size.width), height: CGFloat(self.scannerWindowFrame.origin.y))
        context.fill(fillRect)
        //左边
        fillRect = CGRect(x: CGFloat(0), y: CGFloat(self.scannerWindowFrame.origin.y), width: CGFloat(self.scannerWindowFrame.origin.x), height: CGFloat(self.scannerWindowFrame.size.height))
        context.fill(fillRect)
        //右边
        fillRect = CGRect(x: CGFloat(self.scannerWindowFrame.origin.x + self.scannerWindowFrame.size.width), y: CGFloat(self.scannerWindowFrame.origin.y), width: CGFloat(self.frame.size.width - self.scannerWindowFrame.origin.x - self.scannerWindowFrame.size.width), height: CGFloat(self.scannerWindowFrame.size.height))
        context.fill(fillRect)
        //下面
        fillRect = CGRect(x: CGFloat(0), y: CGFloat(self.scannerWindowFrame.origin.y + self.scannerWindowFrame.size.height), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height - (self.scannerWindowFrame.origin.y + self.scannerWindowFrame.size.height)))
        context.fill(fillRect)
        context.strokePath()
    }
}

class YZScannerWindowView {
    
    var scannerWindowFrame = CGRect.zero
    var borderLineColor: UIColor!
    var referenceLine: UIView!
    
    override init(scannerWindowFrame: CGRect, borderLineColor: UIColor) {
        super.init(frame: scannerWindowFrame)
        self.backgroundColor = UIColor.clear
        self.borderLineColor = borderLineColor
        self.scannerWindowFrame = scannerWindowFrame
        self.clipsToBounds = true
        self.addSubview(self.referenceLine)
        self.addNotification()
    }
    
    deinit {
        self.removeNotification()
    }
    // MARK: - Notification
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.p_applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.p_applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func p_applicationWillEnterForeground(_ note: Notification) {
        self.referenceLine.frame = CGRect(x: CGFloat(0), y: CGFloat(-self.frame.size.height), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height))
        self.startScanning()
    }
    
    @objc func p_applicationDidEnterBackground(_ note: Notification) {
        self.referenceLine.frame = CGRect(x: CGFloat(0), y: CGFloat(-self.frame.size.height), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height))
        self.stopScanning()
    }
    
    //  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
    
    func referenceLine() -> UIView? {
        if !self.referenceLine {
            self.referenceLine = UIView(frame: self.scannerWindowFrame)
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.scannerWindowFrame.size.width), height: CGFloat(self.scannerWindowFrame.size.height))
            gradientLayer.colors = [(UIColor.clear.cgColor as? Any), (UIColor(red: CGFloat(0.443), green: CGFloat(0.722), blue: CGFloat(0.569), alpha: CGFloat(1.000)).cgColor as? Any)]
            gradientLayer.locations = [(0.5)]
            gradientLayer.startPoint = CGPoint(x: CGFloat(0), y: CGFloat(0))
            gradientLayer.endPoint = CGPoint(x: CGFloat(0), y: CGFloat(1))
            self.referenceLine.layer.addSublayer(gradientLayer)
            self.referenceLine.frame = CGRect(x: CGFloat(0), y: CGFloat(-self.referenceLine.frame.size.height), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height))
        }
        return self.referenceLine
    }
    
    func startScanning() {
        UIView.animate(withDuration: 2.5, delay: 0, options: .repeat, animations: {() -> Void in
            self.referenceLine.isHidden = false
            self.referenceLine.frame = CGRect(x: CGFloat(0), y: CGFloat(self.frame.origin.y), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height))
        }, completion: { _ in })
    }
    
    func stopScanning() {
        self.referenceLine().layer.removeAllAnimations()
        self.referenceLine.isHidden = true
        self.referenceLine.frame = CGRect(x: CGFloat(0), y: CGFloat(-self.frame.size.height), width: CGFloat(self.frame.size.width), height: CGFloat(self.frame.size.height))
    }
    var kLineWidth: Int = 6
    var kCornerLength: Int = 18
    var kOriginOffset: CGFloat = 0.7
    
    //  The converted code is limited by 2 KB.
    //  Upgrade your plan to remove this limitation.
    
    //  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
    
    override func draw(_ rect: CGRect) {
        /// 主题色
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
        var result: Bool = self.borderLineColor.getRed(red, green: green, blue: blue, alpha: alpha)
        if !result {
            return
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.clear(rect)
        context.stroke(rect)
        context.setStrokeColor(red: red, green: green, blue: blue, alpha: alpha)
        context.setLineWidth(CGFloat(1))
        context.addRect(rect)
        context.strokePath()
        /// 设置 线宽
        context.setLineWidth(CGFloat(kLineWidth))
        context.setStrokeColor(red: red, green: green, blue: blue, alpha: alpha)
        /// 左上角
        var pointsTopLeftX: [CGPoint] = [CGPoint(x: CGFloat(rect.minX + kCornerLength), y: CGFloat(rect.minY + kOriginOffset)), CGPoint(x: CGFloat(rect.minX), y: CGFloat(rect.minY + kOriginOffset))]
        var pointsTopLeftY: [CGPoint] = [CGPoint(x: CGFloat(rect.origin.x + kOriginOffset), y: CGFloat(rect.origin.y + kCornerLength)), CGPoint(x: CGFloat(rect.origin.x + kOriginOffset), y: CGFloat(rect.origin.y))]
        context.addLines(between: pointsTopLeftX)
        context.addLines(between: pointsTopLeftY)
        /// 左下角
        var pointsLeftBottomX: [CGPoint] = [CGPoint(x: CGFloat(rect.minX), y: CGFloat(rect.maxY - kOriginOffset)), CGPoint(x: CGFloat(rect.minX + kCornerLength + kOriginOffset), y: CGFloat(rect.maxY - kOriginOffset))]
        var pointsLeftBottomY: [CGPoint] = [CGPoint(x: CGFloat(rect.minX + kOriginOffset), y: CGFloat(rect.maxY)), CGPoint(x: CGFloat(rect.minX + kOriginOffset), y: CGFloat(rect.maxY - kCornerLength))]
        context.addLines(between: pointsLeftBottomX)
        context.addLines(between: pointsLeftBottomY)
        /// 右上角
        var pointsRightTopX: [CGPoint] = [CGPoint(x: CGFloat(rect.maxX - kCornerLength), y: CGFloat(rect.minY + kOriginOffset)), CGPoint(x: CGFloat(rect.maxX), y: CGFloat(rect.minY + kOriginOffset))]
        var pointsRightTopY: [CGPoint] = [CGPoint(x: CGFloat(rect.maxX - kOriginOffset), y: CGFloat(rect.minY)), CGPoint(x: CGFloat(rect.maxX - kOriginOffset), y: CGFloat(rect.minY + kCornerLength + kOriginOffset))]
        context.addLines(between: pointsRightTopX)
        context.addLines(between: pointsRightTopY)
        // 右下角
        var pointsRightBottomX: [CGPoint] = [CGPoint(x: CGFloat(rect.maxX - kCornerLength), y: CGFloat(rect.maxY - kOriginOffset)), CGPoint(x: CGFloat(rect.maxX), y: CGFloat(rect.maxY - kOriginOffset))]
        var pointsRightBottomY: [CGPoint] = [CGPoint(x: CGFloat(rect.maxX - kOriginOffset), y: CGFloat(rect.maxY - kCornerLength)), CGPoint(x: CGFloat(rect.maxX - kOriginOffset), y: CGFloat(rect.maxY))]
        context.addLines(between: pointsRightBottomX)
        context.addLines(between: pointsRightBottomY)
        context.strokePath()
    }
}
