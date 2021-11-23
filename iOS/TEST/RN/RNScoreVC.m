//
//  RNScoreVC.m
//  TEST
//
//  Created by Wilson on 2021/11/14.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "RNScoreVC.h"
//#import <React/RCTRootView.h>

@interface RNScoreVC ()

@end

@implementation RNScoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showRNView];
}

- (void)showRNView {
    NSLog(@"RN High Score View is Load");
//    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.bundle?platform=ios"];

//    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL: jsCodeLocation
//                                                        moduleName: @"RNHighScores"
//                                                 initialProperties: @{
//                                                                       @"scores" : @[
//                                                                         @{
//                                                                             @"name" : @"Alex",
//                                                                             @"value": @"42"
//                                                                          },
//                                                                         @{
//                                                                             @"name" : @"Joel",
//                                                                             @"value": @"10"
//                                                                         },
//                                                                         @{
//                                                                             @"name" : @"Wilson",
//                                                                             @"value" : @"98"
//                                                                         }
//                                                                       ]
//                                                                     }
//                                                    launchOptions: nil];
//    self.view = rootView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
