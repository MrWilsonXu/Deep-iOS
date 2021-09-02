//
//  Person.m
//  TEST
//
//  Created by Wilson on 2020/3/18.
//  Copyright © 2020 Wilson. All rights reserved.
//

#import "Person.h"

@interface Person()

@end

@implementation Person

- (void)setName:(NSString *)name            {

    if ([_name isEqualToString:name]) return;
    //手动触发 关闭自动监听之后，如果不写下面三行代码是不会触发监听的，
    //要是打开自动监听的话，willChangeValueForKey didChangeValueForKey可以不用写，系统会自动加上
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {

    //对name属性关闭自动监听
    if ([key isEqualToString:@"name"]) {

        return NO;
    } else {
        //对其他属性没影响
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

@end
