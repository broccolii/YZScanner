//
//  YZScannerPreviewView.m
//  YZCashier
//
//  Created by Broccoli on 2017/1/19.
//  Copyright © 2017年 Cashier. All rights reserved.
//

#import "YZScannerMaskView.h"

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
                           backgroundColor:(UIColor *)backgroundColor NS_DESIGNATED_INITIALIZER;

@property (assign, nonatomic) CGRect scannerWindowFrame;
@property (strong, nonatomic) UIColor *borderLineColor;

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
    return self;
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
@property (nonatomic, strong) UIView *referenceLine;

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
    YZScannerBackgroundView *backgroundView = [[YZScannerBackgroundView alloc] initWithFrame:self.frame
                                                                          scannerWindowFrame:self.scannerWindowFrame
                                                                                   fillColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [self addSubview:backgroundView];
    
    YZScannerWindowView *windowView = [[YZScannerWindowView alloc] initWithScannerWindowFrame:self.scannerWindowFrame
                                                                                  borderLineColor:[YZColorManager colorWithRGBValue:0xF49922]];
    [self addSubview:windowView];
    
    [self addSubview:self.referenceLine];
    [self startScanning];
}

#pragma mark - getter
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

- (UIView *)referenceLine {
    if (!_referenceLine) {
        _referenceLine = [[UIView alloc] initWithFrame:self.scannerWindowFrame];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, self.scannerWindowFrame.size.width, self.scannerWindowFrame.size.height);
        gradientLayer.colors = @[(id)[UIColor clearColor].CGColor,
                                 (id)[[YZColorManager colorWithType:ThemeFillColor] colorWithAlphaComponent:0.4].CGColor];
        gradientLayer.locations = @[@(0.5f)];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        [_referenceLine.layer addSublayer:gradientLayer];
        _referenceLine.top = 0;
        _referenceLine.left = self.scannerWindowFrame.origin.x;
        _referenceLine.width = self.scannerWindowFrame.size.width;
        _referenceLine.height = self.scannerWindowFrame.size.height;
    }
    return _referenceLine;
}

#pragma mark - publick method
- (void)startScanning {
    [UIView animateWithDuration:2.5
                          delay:0
                        options:UIViewAnimationOptionRepeat
                     animations:^{
        self.referenceLine.hidden = NO;
        self.referenceLine.top = self.scannerWindowFrame.origin.y;
    } completion:nil];
}

- (void)stopScanning {
    [self.referenceLine.layer removeAllAnimations];
    self.referenceLine.hidden = YES;
    self.referenceLine.top = self.scannerWindowFrame.size.height;
}

@end
