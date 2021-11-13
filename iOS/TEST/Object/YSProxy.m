//
//  YSProxy.m
//  TEST
//
//  Created by Wilson on 2021/8/13.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "YSProxy.h"

@implementation YSProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

/// 直接进行消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

/// 下一步调用
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

@end
