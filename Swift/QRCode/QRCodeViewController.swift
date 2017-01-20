//
//  QRCodeViewController.swift
//  iDoc
//
//  Created by Broccoli on 15/10/30.
//  Copyright © 2015年 iue. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

class QRCodeViewController: UIViewController {
    /// 完成后的回调
    var completionBlock: ((String) -> Void)!
    // 因为会回调很多次 加一个 属性 判断一下
    var isOutputCallBack = false
    
    // Mark: - 懒加载 属性
    
    /// 最上层的遮罩
    var shadeView: QRCodeView!
    
    /// 会话
    private let session = AVCaptureSession()
    
    /// 输入窗
    private lazy var input: AVCaptureDeviceInput? =  {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch let error as NSError {
            NSLog("获取 Device Input 异常 错误信息: \(error)")
            return nil
        }
    }()
    
    /// 输出
    private let output = AVCaptureMetadataOutput()
    
    /// 预视窗
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = AVLayerVideoGravityResize
        preview.frame = UIScreen.mainScreen().bounds
        preview.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        return preview
    }()
    
    init(scanSize: CGSize = CGSize(width: 200, height: 200), completion: (String) -> Void) {
        super.init(nibName: nil, bundle: nil)
        
        completionBlock = completion
        configQRCode(scanSize)
        shadeView = QRCodeView(scanSize: scanSize)
        shadeView.transparentArea = scanSize
        shadeView.dismissBlock = {
             self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.view.addSubview(shadeView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: 写成一个 QRCode manager
    func configQRCode(scanSize: CGSize) {
        session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        
        guard session.canAddInput(input) else {
            return
        }
        guard session.canAddOutput(output) else {
            return
        }
        
        session.addInput(input)
        session.addOutput(output)
        // 要先添加 output 和 input 再 赋值 metadataObjectTypes
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        // 预览窗
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        // 修正 扫描区域 注意 这里需要一个错位
        let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        // 为了好看 窗口下移  30 PX
        let scanX = (screenHeight - scanSize.height - 60) / 2.0 / screenHeight
        let scanY = (screenWidth - scanSize.width) / 2.0 / screenWidth
        let scanHeight = scanSize.height / screenHeight
        let scanWidth = scanSize.width / screenWidth
        
        output.rectOfInterest = CGRect(x: scanX, y: scanY, width: scanHeight, height: scanWidth)
        session.startRunning()
    }
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        guard metadataObjects.count > 0 else {
            debugPrint("扫描完成 无效的二维码")
            return
        }
        if isOutputCallBack {
            return
        }
        isOutputCallBack = true
        completionBlock((metadataObjects.first as! AVMetadataMachineReadableCodeObject).stringValue)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class QRCodeView: UIView {
    
    // 透明的扫描区域
    var transparentArea: CGSize!
    var dismissBlock: (Void -> Void)?
    var titleBarColor = UIColor(red: 60 / 255.0, green: 60 / 255.0, blue: 60 / 255.0, alpha: 0.7)
    var cancelBtnColor = UIColor.lightGrayColor()
    
    private var scanLine: UIImageView!
    private var scanLineY: CGFloat!
    
    init(scanSize: CGSize) {
        super.init(frame: UIScreen.mainScreen().bounds)
       transparentArea = scanSize
        configUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: Selector("scrollLineView"), userInfo: nil, repeats: true)
        timer.fire()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        /// 设置背景色
         self.backgroundColor = UIColor.clearColor()
        
        /// titleBar
        let titleBar = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 64))
        titleBar.backgroundColor = titleBarColor
        self.addSubview(titleBar)
        
        /// cancelBtn
        let button = UIButton.init(type: UIButtonType.Custom)
        button.frame = CGRect(x: CGRectGetWidth(UIScreen.mainScreen().bounds) - 60, y: 31, width: 50, height: 22)
        button.setTitle("关闭", forState: UIControlState.Normal)
        button.setTitleColor(cancelBtnColor, forState: UIControlState.Normal)
        button.addTarget(self, action: Selector("dismiss"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        /// 扫描线
        scanLine = UIImageView(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width - transparentArea.width) / 2.0, y: (UIScreen.mainScreen().bounds.size.height - transparentArea.height - 60) / 2.0, width: transparentArea.width, height: 2))
        scanLine.image = UIImage(named: "QR_line")
        scanLine.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(scanLine)
        scanLineY = scanLine.frame.origin.y
    }
    
    func scrollLineView() {
        UIView.animateWithDuration(0.02, animations: { () -> Void in
            var rect = self.scanLine.frame
            rect.origin.y = self.scanLineY
            self.scanLine.frame = rect
            }) { (finished) -> Void in
                let maxBorder = (UIScreen.mainScreen().bounds.size.height - self.transparentArea.height - 60) / 2.0 + self.transparentArea.height
                if self.scanLineY > maxBorder {
                    self.scanLineY = (UIScreen.mainScreen().bounds.size.height - self.transparentArea.height - 60) / 2.0
                }
                self.scanLineY = self.scanLineY + 1.0
        }
    }
    private func dismiss() {
        if let dismissBlock = dismissBlock {
            dismissBlock()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        //整个二维码扫描界面的大小
        let screenDrawRect = UIScreen.mainScreen().bounds
        
        //中间清空的矩形框
        let clearDrawRect = CGRect(x: (screenDrawRect.size.width - transparentArea.width) / 2.0, y: (screenDrawRect.size.height - transparentArea.height - 60) / 2.0, width: transparentArea.width, height: transparentArea.height)

        let ctx = UIGraphicsGetCurrentContext()!
        addScreenFillRect(ctx, rect: screenDrawRect)
        addCenterClearRect(ctx, rect: clearDrawRect)
        addWhiteRect(ctx, rect: clearDrawRect)
        addCornerLine(ctx, rect: clearDrawRect)
    }
    
    /**
     设置背景色
     
     - parameter ctx:  图层上下文
     - parameter rect: 屏幕大小
     */
    func addScreenFillRect(ctx: CGContextRef, rect: CGRect) {
        CGContextSetRGBFillColor(ctx, 40 / 255.0, 40 / 255.0, 40 / 255.0, 0.5)
        CGContextFillRect(ctx, rect)
    }
    
    /**
     设置 中间扫描框
     
     - parameter ctx:  图层上下文
     - parameter rect: 扫描框大小
     */
    func addCenterClearRect(ctx: CGContextRef, rect: CGRect) {
        CGContextClearRect(ctx, rect)
    }
    
    /**
     绘制 扫描框 的白边
     
     - parameter ctx:  图层上下文
     - parameter rect: 扫描框大小
     */
    func addWhiteRect(ctx: CGContextRef, rect: CGRect) {
        CGContextStrokeRect(ctx, rect)
        CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        CGContextSetLineWidth(ctx, 0.8)
        CGContextAddRect(ctx, rect)
        CGContextStrokePath(ctx)
    }
    
    /**
     设置边框 拐角
     
     - parameter ctx:  图层上下文
     - parameter rect: 扫描框大小
     */
    func addCornerLine(ctx: CGContextRef, rect: CGRect) {
        /// 设置 线宽
        CGContextSetLineWidth(ctx, 2)
        /// 线的颜色 ( 浅绿色
        CGContextSetRGBStrokeColor(ctx, 83 / 255.0, 239 / 255.0, 111 / 255.0, 1)
        
        /// 左上角
        let pointsTopLeftX = [CGPointMake(CGRectGetMinX(rect) + 15, CGRectGetMinY(rect) + 0.7), CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + 0.7)]
        let pointsTopLeftY = [CGPoint(x: rect.origin.x + 0.7, y: rect.origin.y + 15), CGPoint(x: rect.origin.x + 0.7, y: rect.origin.y)]
        CGContextAddLines(ctx, pointsTopLeftX, 2)
        CGContextAddLines(ctx, pointsTopLeftY, 2)
        
        /// 左下角
        let pointsLeftBottomX = [CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect) - 0.7), CGPoint(x: CGRectGetMinX(rect) + 15.7, y: CGRectGetMaxY(rect) - 0.7)]
        CGContextAddLines(ctx, pointsLeftBottomX, 2)
        let pointsLeftBottomY = [CGPoint(x: CGRectGetMinX(rect) + 0.7, y: CGRectGetMaxY(rect)), CGPoint(x: CGRectGetMinX(rect) + 0.7, y: CGRectGetMaxY(rect) - 15)]
        CGContextAddLines(ctx, pointsLeftBottomY, 2)
        
        /// 右上角
        let pointsRightTopX = [CGPoint(x: CGRectGetMaxX(rect) - 15, y: CGRectGetMinY(rect) + 0.7), CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMinY(rect) + 0.7)]
        CGContextAddLines(ctx, pointsRightTopX, 2)
        let pointsRightTopY = [CGPoint(x: CGRectGetMaxX(rect) - 0.7, y: CGRectGetMinY(rect)), CGPoint(x: CGRectGetMaxX(rect) - 0.7, y: CGRectGetMinY(rect) + 15.7)]
        CGContextAddLines(ctx, pointsRightTopY, 2)
        
        // 右下角
        let pointsRightBottomX = [CGPoint(x: CGRectGetMaxX(rect) - 15, y: CGRectGetMaxY(rect) - 0.7), CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect) - 0.7)]
        CGContextAddLines(ctx, pointsRightBottomX, 2)
        let pointsRightBottomY = [CGPoint(x: CGRectGetMaxX(rect) - 0.7, y: CGRectGetMaxY(rect) - 15), CGPoint(x: CGRectGetMaxX(rect) - 0.7, y: CGRectGetMaxY(rect))]
        CGContextAddLines(ctx, pointsRightBottomY, 2)
        
        CGContextStrokePath(ctx)
    }
}









































