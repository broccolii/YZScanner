//
//  YZScannerPreviewView.m
//  YZScanner
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 YZScanner. All rights reserved.
//

#import "YZScannerMaskView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

@interface YZScannerBackgroundView : UIView

- (instancetype)initWithFrame:(CGRect)frame
           scannerWindowFrame:(CGRect)scannerWindowFrame
              fillColor:(UIColor *)fillColor NS_DESIGNATED_INITIALIZER;

@property (assign, nonatomic) CGRect scannerWindowFrame;
@property (strong, nonatomic) UIColor *fillColor;

@end

@implementation YZScannerBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
           scannerWindowFrame:(CGRect)scannerWindowFrame
              fillColor:(UIColor *)fillColor {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    self.fillColor = fillColor;
    self.scannerWindowFrame = scannerWindowFrame;
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat red,green,blue,alpha;
    BOOL result = [self.fillColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if (!result) {
        return;
    }
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    //上面
    CGRect fillRect = CGRectMake(0,
                                 0,
                                 self.frame.size.width,
                                 self.scannerWindowFrame.origin.y);
    CGContextFillRect(context, fillRect);
    //左边
    fillRect = CGRectMake(0,
                          self.scannerWindowFrame.origin.y,
                          self.scannerWindowFrame.origin.x,
                          self.scannerWindowFrame.size.height);
    CGContextFillRect(context, fillRect);
    //右边
    fillRect = CGRectMake(self.scannerWindowFrame.origin.x+self.scannerWindowFrame.size.width,
                          self.scannerWindowFrame.origin.y,
                          self.frame.size.width-self.scannerWindowFrame.origin.x-self.scannerWindowFrame.size.width,
                          self.scannerWindowFrame.size.height);
    CGContextFillRect(context, fillRect);
    //下面
    fillRect = CGRectMake(0,
                          self.scannerWindowFrame.origin.y+self.scannerWindowFrame.size.height,
                          self.frame.size.width,
                          self.frame.size.height-(self.scannerWindowFrame.origin.y+self.scannerWindowFrame.size.height));
    CGContextFillRect(context, fillRect);
    
    CGContextStrokePath(context);
}

@end

@interface YZScannerWindowView : UIView

- (instancetype)initWithScannerWindowFrame:(CGRect)scannerWindowFrame
                           borderLineColor:(UIColor *)borderLineColor NS_DESIGNATED_INITIALIZER;

@property (assign, nonatomic) CGRect scannerWindowFrame;
@property (strong, nonatomic) UIColor *borderLineColor;
@property (nonatomic, strong) UIView *referenceLine;

@end

@implementation YZScannerWindowView

- (instancetype)initWithScannerWindowFrame:(CGRect)scannerWindowFrame
                           borderLineColor:(UIColor *)borderLineColor {
    self = [super initWithFrame:scannerWindowFrame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    
    self.borderLineColor = borderLineColor;
    self.scannerWindowFrame = scannerWindowFrame;
    
    self.clipsToBounds = YES;
    [self addSubview:self.referenceLine];
    
    [self addNotification];
    return self;
}

- (void)dealloc {
    [self removeNotification];
}

#pragma mark - Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)p_applicationWillEnterForeground:(NSNotification*)note {
    _referenceLine.frame = CGRectMake(0, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [self startScanning];
}

- (void)p_applicationDidEnterBackground:(NSNotification*)note {
    _referenceLine.frame = CGRectMake(0, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [self stopScanning];
}

- (UIView *)referenceLine {
    if (!_referenceLine) {
        _referenceLine = [[UIView alloc] initWithFrame:self.scannerWindowFrame];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, self.scannerWindowFrame.size.width, self.scannerWindowFrame.size.height);
        gradientLayer.colors = @[(id)[UIColor clearColor].CGColor,
                                 (id)[UIColor colorWithRed:0.443 green:0.722 blue:0.569 alpha:1.000].CGColor];
        gradientLayer.locations = @[@(0.5f)];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        [_referenceLine.layer addSublayer:gradientLayer];
        
        _referenceLine.frame = CGRectMake(0, - _referenceLine.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    return _referenceLine;
}

- (void)startScanning {
    [UIView animateWithDuration:2.5
                          delay:0
                        options:UIViewAnimationOptionRepeat
                     animations:^{
                         self.referenceLine.hidden = NO;
                         _referenceLine.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:nil];
}

- (void)stopScanning {
    [self.referenceLine.layer removeAllAnimations];
    self.referenceLine.hidden = YES;
    _referenceLine.frame = CGRectMake(0, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

static NSInteger kLineWidth = 6;
static NSInteger kCornerLength = 18;
static NSInteger kOriginOffset = 0.7;

- (void)drawRect:(CGRect)rect {
    /// 主题色
    CGFloat red,green,blue,alpha;
    BOOL result = [self.borderLineColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if (!result) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextStrokeRect(context, rect);
    CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
    CGContextSetLineWidth(context, 1);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    /// 设置 线宽
    CGContextSetLineWidth(context, kLineWidth);
   
    CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
    
    /// 左上角
    CGPoint pointsTopLeftX[] = {
        CGPointMake(CGRectGetMinX(rect) + kCornerLength,
                    CGRectGetMinY(rect) + kOriginOffset),
        CGPointMake(CGRectGetMinX(rect),
                    CGRectGetMinY(rect) + kOriginOffset)
    };
    CGPoint pointsTopLeftY[] = {
        CGPointMake(rect.origin.x + kOriginOffset,
                    rect.origin.y + kCornerLength),
        CGPointMake(rect.origin.x + kOriginOffset,
                    rect.origin.y)
    };
    
    CGContextAddLines(context, pointsTopLeftX, 2);
    CGContextAddLines(context, pointsTopLeftY, 2);
    

    /// 左下角
    CGPoint pointsLeftBottomX[] = {
        CGPointMake(CGRectGetMinX(rect),
                    CGRectGetMaxY(rect) - kOriginOffset),
        CGPointMake(CGRectGetMinX(rect) + kCornerLength + kOriginOffset,
                    CGRectGetMaxY(rect) - kOriginOffset)
    };
    CGPoint pointsLeftBottomY[] = {
        CGPointMake(CGRectGetMinX(rect) + kOriginOffset,
                                               CGRectGetMaxY(rect)),
        CGPointMake(CGRectGetMinX(rect) + kOriginOffset,
                    CGRectGetMaxY(rect) - kCornerLength)
    };
    
    CGContextAddLines(context, pointsLeftBottomX, 2);
    CGContextAddLines(context, pointsLeftBottomY, 2);

    /// 右上角
    CGPoint pointsRightTopX[] = {
        CGPointMake(CGRectGetMaxX(rect) - kCornerLength,
                    CGRectGetMinY(rect) + kOriginOffset),
        CGPointMake(CGRectGetMaxX(rect),
                    CGRectGetMinY(rect) + kOriginOffset)
    };
    CGPoint pointsRightTopY[] = {
        CGPointMake(CGRectGetMaxX(rect) - kOriginOffset,
                                             CGRectGetMinY(rect)),
        CGPointMake(CGRectGetMaxX(rect) - kOriginOffset,
                    CGRectGetMinY(rect) + kCornerLength + kOriginOffset)
    };
    
    CGContextAddLines(context, pointsRightTopX, 2);
    CGContextAddLines(context, pointsRightTopY, 2);

    // 右下角
    CGPoint pointsRightBottomX[] = {
        CGPointMake(CGRectGetMaxX(rect) - kCornerLength,
                    CGRectGetMaxY(rect) - kOriginOffset),
        CGPointMake(CGRectGetMaxX(rect),
                    CGRectGetMaxY(rect) - kOriginOffset)
    };
    CGPoint pointsRightBottomY[] = {
        CGPointMake(CGRectGetMaxX(rect) - kOriginOffset,
                    CGRectGetMaxY(rect) - kCornerLength),
        CGPointMake(CGRectGetMaxX(rect) - kOriginOffset,
                    CGRectGetMaxY(rect))
    };
    
    CGContextAddLines(context, pointsRightBottomX, 2);
    CGContextAddLines(context, pointsRightBottomY, 2);
    
    CGContextStrokePath(context);
}

@end

@interface YZScannerMaskView ()

@property (nonatomic, assign) CGRect scannerWindowFrame;
@property (nonatomic, strong) YZScannerBackgroundView *backgroundView;
@property (nonatomic, strong) YZScannerWindowView *windowView;
@end

@implementation YZScannerMaskView

#pragma mark - Initializing
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    [self setupSubviews];
    return self;
}

#pragma mark - setup subviews
- (void)setupSubviews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.windowView];
    [self startScanning];
}

#pragma mark - getter
- (YZScannerBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[YZScannerBackgroundView alloc] initWithFrame:self.frame
                                                      scannerWindowFrame:self.scannerWindowFrame
                                                               fillColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    }
    return _backgroundView;
}

- (YZScannerWindowView *)windowView {
    if (!_windowView) {
        _windowView = [[YZScannerWindowView alloc] initWithScannerWindowFrame:self.scannerWindowFrame
                                                              borderLineColor:[UIColor colorWithRed:0.443 green:0.722 blue:0.569 alpha:1.0]];
    }
    return _windowView;
}

- (CGRect)scannerWindowFrame {
    if (CGRectEqualToRect(_scannerWindowFrame, CGRectZero)) {
        CGFloat y = 175;
        CGFloat x = 25;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * x;
        CGFloat height = 220;
        _scannerWindowFrame = CGRectMake(x, y, width, height);
    }
    return _scannerWindowFrame;
}

#pragma mark - publick method
- (void)startScanning {
    [self.windowView startScanning];
}

- (void)stopScanning {
    [self.windowView stopScanning];
}

const NSInteger kActivityBackgroundViewTag = 1001;
const NSInteger kActivityViewTag = 1002;

- (void)startLoadingAnimation {
    self.windowView.hidden = YES;
    self.backgroundView.hidden = YES;
    
    UIView *activityBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    activityBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.6];
    activityBackgroundView.tag = kActivityBackgroundViewTag;
    [self addSubview:activityBackgroundView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = self.center;
    activityView.tag = kActivityViewTag;
    [self addSubview:activityView];
    [activityView startAnimating];
}

- (void)stopLoadingAnimation {
    self.windowView.hidden = NO;
    self.backgroundView.hidden = NO;
    
    UIView *activityBackgroundView = [self viewWithTag:kActivityBackgroundViewTag];
    [activityBackgroundView removeFromSuperview];
    UIView *activityView = [self viewWithTag:kActivityViewTag];
    [activityView removeFromSuperview];
}

@end

#pragma clang diagnostic pop
