//
//  YZScannerReader.h
//  YZScanner
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 YZScanner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface YZScannerReader : NSObject

#pragma mark - Creating and Inializing QRCode Readers

+ (instancetype)reader;

@property (strong, nonatomic) NSString *sessionPreset;

#pragma mark - Checking the Metadata Items Types

/**
 Supported code types
 */
@property (strong, nonatomic, readonly) NSArray *metadataObjectTypes;

#pragma mark - Viewing the Camera

/**
 preview layer
 */
@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

#pragma mark - status

/**
 capture session status
 */
@property(nonatomic, readonly, getter=isRunning) BOOL running;

#pragma mark - Controlling the Reader

/**
 Starts scanning the codes
 */
- (void)startScanning;

/**
 Stops scanning the codes
 */
- (void)stopScanning;

#pragma mark - Getting Inputs and Outputs

/**
 input device
 */
@property (readonly) AVCaptureDeviceInput *defaultDeviceInput;

/**
 output device
 */
@property (readonly) AVCaptureMetadataOutput *metadataOutput;

#pragma mark - Managing the Orientation

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#pragma mark - Managing the Block

- (void)didCaptureScannerResult:(void (^) (NSString *resultAsString))completionBlock;

@end
