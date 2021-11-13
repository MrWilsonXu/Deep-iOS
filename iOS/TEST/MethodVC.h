//
//  FVC.h
//  TEST
//
//  Created by Wilson on 2021/8/27.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FBlock) (void);

@interface MethodVC : UIViewController

@property (nonatomic, copy) FBlock block;


@end

NS_ASSUME_NONNULL_END
