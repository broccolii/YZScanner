//
//  YZScannerViewController.m
//  YZScanner
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 YZScanner. All rights reserved.
//

#import "YZScannerViewController.h"
#import "YZScannerMaskView.h"
#import "YZScannerReader.h"

@interface YZScannerViewController ()

@property (nonatomic, strong) YZScannerReader *scannerReader;
@property (nonatomic, strong) YZScannerMaskView *previewMaskView;

@end

@implementation YZScannerViewController

#pragma mark - view life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"QRCode Scanner";
    [self setupScannerReader];
}

#pragma mark - scannerReader
- (void)setupScannerReader {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 if (granted) {
                                     [self launchScanner];
                                 } else {
                                     [self showPermissionAlertController];
                                 }
                             }];
}

- (void)launchScanner {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.scannerReader = [YZScannerReader reader];
        __weak __typeof__(self) weakSelf = self;
        [self.scannerReader didCaptureScannerResult:^(NSString *resultAsString) {
            __strong __typeof__(self) strongSelf = weakSelf;
            [strongSelf handleScannerResult:resultAsString];
        }];
        
        [self.scannerReader startScanning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scannerReader.previewLayer.frame = self.view.frame;
            [self.view.layer insertSublayer:self.scannerReader.previewLayer atIndex:0];
            
            [self setupScannerMaskView];
        });
    });
}

- (void)showPermissionAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:@"The scanner needs to start the camera"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Goto Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *systemSettingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:systemSettingsURL]) {
            [[UIApplication sharedApplication] openURL:systemSettingsURL];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:confirm];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - subview
- (void)setupScannerMaskView {
    self.previewMaskView = [[YZScannerMaskView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.previewMaskView ];
}

#pragma mark - handler
- (void)handleScannerResult:(NSString *)scannerResult {
    [self.previewMaskView stopScanning];

}

@end
