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
        NSLog(@"当前类为：%@", NSStringFromClass([self class]));
        // 从 objc_super结构体指向的superClass的方法列表开始找 setName的 selector，找到后，实际上是由 objc_super->receiver去调用这个selector，即 self 来调用 class 方法
        NSLog(@"当前类为：%@", NSStringFromClass([super class]));
    }
    return self;
}

@end
