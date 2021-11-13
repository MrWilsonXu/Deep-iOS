//
//  FVC.m
//  TEST
//
//  Created by Wilson on 2021/8/27.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "MethodVC.h"
#import "Wilson.h"

@interface MethodVC ()

@property (nonatomic, strong) Wilson *wilson;

@end

@implementation MethodVC

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addObserver];
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.orangeColor;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 40)];
    [btn setTitle:@"点我返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *kvoBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 100, 200, 40)];
    [kvoBtn setTitle:@"person赋值测试KVO" forState:UIControlStateNormal];
    [kvoBtn addTarget:self action:@selector(clickKVOAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kvoBtn];
}

- (void)addObserver {
    [self.wilson addObserver:self forKeyPath:@"enName" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.wilson]) {
        NSLog(@"新的值为：%@",object);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Action

- (void)clickAction {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.block) {
        self.block();
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSMapTable *mapTable = [[NSMapTable alloc] initWithKeyOptions: NSPointerFunctionsWeakMemory | NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsWeakMemory capacity:10];
    [mapTable setObject:weakSelf forKey:@"wilson"];
    NSLog(@"%@",mapTable);
}

- (void)clickKVOAction {
    self.wilson.enName = @"Wilson";
}

#pragma mark - Getter

- (Wilson *)wilson {
    if (!_wilson) {
        _wilson = [[Wilson alloc] init];
    }
    return _wilson;
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
