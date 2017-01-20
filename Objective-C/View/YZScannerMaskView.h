//
//  YZScannerPreviewView.h
//  YZCashier
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 Cashier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZScannerMaskView : UIView

#pragma mark - Initializing
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)startScanning;
- (void)stopScanning;

@end
