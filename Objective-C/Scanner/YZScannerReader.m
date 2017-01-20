//
//  YZScannerReader.m
//  YZScannerReader
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 broccoliii. All rights reserved.
//

#import "YZScannerReader.h"

@interface YZScannerReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;

@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation YZScannerReader

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setupAVComponents];
    return self;
}

+ (instancetype)reader {
    return [[self alloc] init];
}

#pragma mark - Initializing the AV Components
- (void)setupAVComponents {
    // device
    // TODO: 可能会为 nil
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // input
    NSError *error;
    self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:&error];
    
    if (error) {
        NSException *e = [NSException
                          exceptionWithName: @"com.youzan.scannerReader.setupAVComponentsError"
                          reason: @"Initializing AVCaptureDeviceInput failed"
                          userInfo: nil];
        @throw e;
    }
 
    // output
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.metadataOutput.metadataObjectTypes = self.metadataObjectTypes;
    
    // session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:self.sessionPreset];

    if ([self.session canAddInput:self.defaultDeviceInput] && self.defaultDevice) {
        [self.session addInput:self.defaultDeviceInput];
    }
    
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
    }
    
    if (!self.metadataObjectTypes) {
        self.metadataOutput.metadataObjectTypes = [self.metadataOutput availableMetadataObjectTypes];
    } else {
        NSMutableArray *metadataObjectTypes = [NSMutableArray array];
        for (NSString *availableMetadataObject in self.metadataOutput.availableMetadataObjectTypes) {
            if([self.metadataObjectTypes containsObject:availableMetadataObject]) {
                [metadataObjectTypes addObject:availableMetadataObject];
            }
        }
        self.metadataOutput.metadataObjectTypes =[metadataObjectTypes copy];
    }
    
    // preview
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

#pragma mark - Controlling Reader
- (void)startScanning {
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)stopScanning {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}

- (BOOL)isRunning {
    return self.session.isRunning;
}

#pragma mark - Managing the Orientation

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

#pragma mark - Managing the Block
- (void)didCaptureScannerResult:(void (^) (NSString *resultAsString))completionBlock {
    self.completionBlock = completionBlock;
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        @try {
            AVMetadataObject *obj = metadataObjects[0];
            if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {//
                [self stopScanning];
                
                NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *)obj stringValue];
                
                if (_completionBlock) {
                    _completionBlock(scannedResult);
                }
            }
        }
        @catch (NSException *exception) {
            [self startScanning];
        }
    } 
}

#pragma mark -
- (NSString *)sessionPreset {
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPresetInputPriority;
    }
    return _sessionPreset;
}

@end
