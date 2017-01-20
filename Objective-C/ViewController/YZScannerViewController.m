//
//  YZScannerViewController.m
//  YZCashier
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 Cashier. All rights reserved.
//

#import "YZScannerViewController.h"
#import "YZScannerMaskView.h"
#import "YZScannerHandler.h"
#import "YZScannerReader.h"

@interface YZScannerViewController ()

@property (nonatomic, strong) YZScannerReader *scannerReader;
@property (nonatomic, strong) YZScannerMaskView *previewView;

@end

@implementation YZScannerViewController

#pragma mark - view life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.title = YZLSTR(@"全局扫一扫");
     [self setupScannerReader];
}

#pragma mark - scannerReader
- (void)setupScannerReader {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
          self.scannerReader = [YZScannerReader reader];
        }
        @catch (NSException *exception) {
            // TODO: show error pop to view controller
            NSLog(@"启动失败了~~~");
            return;
        }
        
        YZWeak(self)
        [self.scannerReader didCaptureScannerResult:^(NSString *resultAsString) {
            YZStrong(self)
            // TODO: 看看是不是主线程
            [self handleScannerResult:resultAsString];
        }];
   
        [self.scannerReader startScanning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scannerReader.previewLayer.frame = self.view.frame;
            [self.view.layer insertSublayer:self.scannerReader.previewLayer atIndex:0];
            
            [self setupScannerMaskView];
        });
    });
    
    
}

#pragma mark - subview
// 输入框
// right navigation bar button item
// scanner preview view
- (void)setupScannerMaskView {
    self.previewView = [[YZScannerMaskView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.previewView ];
}

#pragma mark - animation
// TODO: 手势 缩放 custom dismiss

#pragma mark - loading
// 全局 mask loading view

#pragma mark - handler
- (void)handleScannerResult:(NSString *)scannerResult {
    [self.previewView stopScanning];
    // begin loading
    [YZScannerHandler handlerScannerResult:scannerResult completion:^(NSError *error, NSString *item) {
        
    }];
}

@end
