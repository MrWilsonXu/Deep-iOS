//
//  Student.m
//  TEST
//
//  Created by Wilson on 2021/8/11.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "Student.h"

@implementation Student

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"[self class]当前类为：%@", NSStringFromClass([self class]));
        NSLog(@"[super class]当前类为：%@", NSStringFromClass([super class]));
    }
    return self;
}

+ (void)initialize {
    NSLog(@"Student -> initialize");
}

@end
