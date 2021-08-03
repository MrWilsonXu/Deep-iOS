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

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    if ([key isEqualToString:@"name"]) {
//        return NO;
//    }
    return [super automaticallyNotifiesObserversForKey:key];
}

@end
