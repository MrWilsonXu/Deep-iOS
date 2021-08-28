//
//  FVC.m
//  TEST
//
//  Created by Wilson on 2021/8/27.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "FVC.h"

@interface FVC ()

@end

@implementation FVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [btn setTitle:@"点我返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.view.backgroundColor = UIColor.lightGrayColor;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)clickAction {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.block) {
        self.block();
    }
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
