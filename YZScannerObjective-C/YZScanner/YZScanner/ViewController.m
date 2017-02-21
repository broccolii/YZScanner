//
//  ViewController.m
//  YZScanner
//
//  Created by Broccoli on 16/02/2017.
//  Copyright © 2017 broccoliii. All rights reserved.
//

#import "ViewController.h"
#import "YZScannerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    YZScannerViewController *scannerViewController = [[YZScannerViewController alloc] init];
    [self presentViewController:scannerViewController animated:YES completion:nil];
}

@end
