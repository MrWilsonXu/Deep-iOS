//
//  Person.h
//  TEST
//
//  Created by Wilson on 2020/3/18.
//  Copyright © 2020 Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject{
    @public
    int height;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *gender;

+ (void)clsMethod;

@end

NS_ASSUME_NONNULL_END
