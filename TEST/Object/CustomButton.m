//
//  CustomButton.m
//  TEST
//
//  Created by Wilson on 2021/8/8.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "CustomButton.h"

@interface CustomButton()<CALayerDelegate>

@property (nonatomic, strong) UIView *centerView;


@end

@implementation CustomButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.backgroundColor = UIColor.whiteColor;
    self.layer.masksToBounds = YES;
    [self addSubview:self.centerView];
    self.layer.delegate = self;
    [UIApplication sharedApplication]
}

- (void)layoutSubviews {
    self.centerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.centerView.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)clickCustomBtn {
    NSLog(@"自定义按钮，测试事件响应者链条关系");
}

#pragma mark - CALayerDelegate

- (void)displayLayer:(CALayer *)layer {
    NSLog(@"执行异步绘制");
}

#pragma mark - Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 此处由 centerView来处理事件
    NSLog(@"touchesBegan");
    [self setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isHidden || self.alpha <= 0.01 || !self.userInteractionEnabled) {
        return nil;
    }
    
    if ([self pointInside:point withEvent:event]) {
        __block UIView *hit = nil;
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 此处切记需要坐标转换
            CGPoint convertPoint = [self convertPoint:point toView:obj];
            // 调用自视图hitTest方法
            hit = [obj hitTest:convertPoint withEvent:event];
            // 找到则停止遍历
            if (hit) {
                *stop = YES;
            }
        }];
        
        // 获得第一响应者视图，若没有找到，则交由self来处理
        if (hit) {
            return hit;
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat cX = self.frame.size.width / 2;
    CGFloat cY = self.frame.size.height / 2;
    
    CGFloat dissX = fabs(point.x - cX);
    CGFloat dissY = fabs(point.y - cY);
    CGFloat diss = sqrt(dissX * dissX + dissY * dissY);
    
    if (diss <= self.frame.size.width/2) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Getter

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = UIColor.orangeColor;
    }
    return _centerView;
}

@end
