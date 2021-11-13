//
//  YSProxy.h
//  TEST
//
//  Created by Wilson on 2021/8/13.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 代理中间类，继承自 NSProxy 可直接调用到消息转发
NS_ASSUME_NONNULL_BEGIN

@interface YSProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
