//
//  YZScannerReader.h
//  YZScannerReader
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface YZScannerReader : NSObject

#pragma mark - Creating and Inializing QRCode Readers
// TODO: 考虑是否写成单例 加速启动速度
+ (instancetype)reader;

// TODO: 配置
@property (strong, nonatomic) NSString *sessionPreset;
#pragma mark - Checking the Metadata Items Types
// 支持的码，默认全部支持
@property (strong, nonatomic, readonly) NSArray *metadataObjectTypes;

#pragma mark - Viewing the Camera
// 预览界面 layer
@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

#pragma mark - status
// capture session status
@property(nonatomic, readonly, getter=isRunning) BOOL running;

#pragma mark - Controlling the Reader
// Starts scanning the codes
- (void)startScanning;

// Stops scanning the codes
- (void)stopScanning;

#pragma mark - Getting Inputs and Outputs

// 输入设备
@property (readonly) AVCaptureDeviceInput *defaultDeviceInput;

// 输出设备
@property (readonly) AVCaptureMetadataOutput *metadataOutput;

#pragma mark - Managing the Orientation

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#pragma mark - Managing the Block

- (void)didCaptureScannerResult:(void (^) (NSString *resultAsString))completionBlock;

@end
