//
//  RunLoop和RuntimeVC.m
//  TEST
//
//  Created by Wilson on 2021/8/19.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "RunLoop_RuntimeVC.h"
#import "LXDBacktraceLogger.h"
#import "LXDAppFluecyMonitor.h"
#import "Person.h"
#import "Student.h"
#import <objc/runtime.h>

@interface RunLoop_RuntimeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *methodBtn;
@property (nonatomic, strong) UIButton *runloopBtn;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, readonly, strong) dispatch_queue_t wilson_queue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger times;

@end

CFRunLoopObserverRef __asyncObserver;
CFRunLoopObserverRef __mainObserver;

@implementation RunLoop_RuntimeVC

- (void)dealloc {
    NSLog(@"RunLoop_RuntimeVC --> release");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LXDAppFluecyMonitor sharedMonitor] startMonitoring];

    self.methodBtn.frame = CGRectMake(0, 88, 100, 40);
    self.runloopBtn.frame = CGRectMake(0, 200, 80, 40);
    self.tableView.frame = CGRectMake(0, 130, 200, 500);
    self.tableView.backgroundColor = UIColor.orangeColor;
    
    [self.view addSubview:self.methodBtn];
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.title = @"RunLoop和Runtime";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    return;
    
    // 测试子线程 runloop 保活
    dispatch_async(self.wilson_queue, ^{
        self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        // NSMachPort 相当于是添加 sources1事件
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        
        // kCFRunLoopCommonModes标识：包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

        // 任务完成，runloop退出
        NSLog(@"currentRunLoop ---> 退出 --> %@",[NSRunLoop currentRunLoop]);
    });
    
    
}

#pragma mark - Action

- (void)methodAction {
    // 测试内部消息转发
    Person *p = [[Person alloc] init];
    [p testResolveMethod];
    [p testUnkonwMsg];
    
    // runtime常用函数
    NSLog(@"--------------runtime常用函数-------------");
    Student *st = [[Student alloc] init];
    NSLog(@"类对象Student地址：%p", [Student class]);
    NSLog(@"实例对象Student地址：%p", st);
    NSLog(@"实例对象运行时获取地址：%p", object_getClass(st));
    NSLog(@"类对象运行时获取地址：%p（元类对象地址）", object_getClass([Student class]));
    objc_getClass("person");
    
    // 动态创建类
    NSLog(@"--------------动态创建类并且需要注册-------------");
    Class newClass = objc_allocateClassPair([NSObject class], "YSDog", 0);
    objc_registerClassPair(newClass);
    id dog = [[newClass alloc] init];
    
    // 若已经注册过，则不能在添加成员变量
    NSLog(@"动态创建Dog：%@",dog);
    
    NSLog(@"--------------获取成员变量-------------");
    unsigned int count;
    Ivar *ivars = class_copyIvarList([Person class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"成员变量：%s %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    Ivar heightIvar = class_getInstanceVariable([Person class], "_height");
    object_setIvar(p, heightIvar, (__bridge id)(void *)226);
    NSLog(@"动态更改成员变量的值_height=%d", p->_height);
    free(ivars);
}

- (void)runloopAction {
    [self startAsyncObserver];
}

#pragma mark - RunLoop

- (void)startMainRunLoopObserver {
    // 创建 block 的Observer
    __mainObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
        switch (activity) {
            case kCFRunLoopEntry: {
                NSLog(@"kCFRunLoopEntry - %@", mode);
                CFRelease(mode);
                break;
            }

            case kCFRunLoopBeforeTimers:
                NSLog(@"kCFRunLoopBeforeTimers- %@", mode);
                break;

            case kCFRunLoopBeforeSources:
                NSLog(@"kCFRunLoopBeforeSources- %@", mode);
                break;

            case kCFRunLoopBeforeWaiting:
                NSLog(@"kCFRunLoopBeforeWaiting- %@", mode);
                break;

            case kCFRunLoopAfterWaiting:
                NSLog(@"kCFRunLoopAfterWaiting - %@", mode);
                break;

            case kCFRunLoopExit: {
                NSLog(@"kCFRunLoopExit - %@", mode);
                CFRelease(mode);
                break;
            }

            default:
                break;
        }
    });
    // 添加Observer到RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), __mainObserver, kCFRunLoopCommonModes);
    // 释放
    CFRelease(__mainObserver);
}

- (void)startAsyncObserver {
    dispatch_async(self.wilson_queue, ^{
        NSLog(@"当前线程--> %@", [NSThread currentThread]);
        // 创建回调方法的 Observer
        __asyncObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
        // 添加Observer到RunLoop中
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), __asyncObserver, kCFRunLoopCommonModes);
        // 释放
        CFRelease(__asyncObserver);
    });
}

void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: {
            NSLog(@"kCFRunLoopEntry");
            CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
            NSLog(@"kCFRunLoopEntry - %@", mode);
            CFRelease(mode);
        }
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:{
            NSLog(@"kCFRunLoopExit");
            CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
            NSLog(@"kCFRunLoopExit - %@", mode);
            CFRelease(mode);
        }
            break;
        default:
            break;
    }
}

- (void)timerAction {
    NSLog(@"定时器触发");
    ++self.times;
    if (self.times > 3) {
        // timer 事件从RunLoop中移除
        [self.timer invalidate];
        self.timer = nil;
        
        // 测试任务在执行完成后，重新创建任务，RunLoop 是否激活
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        });
    }
}

#pragma mark - Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row+1];
    if (indexPath.row > 0 && indexPath.row % 30 == 0) {
        usleep(2000000);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选择了第%ld行", indexPath.row);
    sleep(3);
    [self.tableView reloadData];
    NSLog(@"tableView reloadData");
}

#pragma mark - Getter

- (dispatch_queue_t)wilson_queue {
    return dispatch_queue_create("wilson_queue", DISPATCH_QUEUE_SERIAL);
}

- (UIButton *)methodBtn {
    if (!_methodBtn) {
        _methodBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_methodBtn setTitle:@"消息发送" forState:UIControlStateNormal];
        [_methodBtn addTarget:self action:@selector(methodAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _methodBtn;
}

- (UIButton *)runloopBtn {
    if (!_runloopBtn) {
        _runloopBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_runloopBtn setTitle:@"runloop监听" forState:UIControlStateNormal];
        [_runloopBtn addTarget:self action:@selector(runloopAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _runloopBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 68;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

@end
