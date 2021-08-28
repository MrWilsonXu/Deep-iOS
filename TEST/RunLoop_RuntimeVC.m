//
//  RunLoop和RuntimeVC.m
//  TEST
//
//  Created by Wilson on 2021/8/19.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "RunLoop_RuntimeVC.h"

@interface RunLoop_RuntimeVC ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) dispatch_queue_t wilson_queue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger times;

@end

CFRunLoopObserverRef __observer;

@implementation RunLoop_RuntimeVC

- (void)dealloc {
    NSLog(@"RunLoop_RuntimeVC --> release");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

NSMutableDictionary *runloops;

void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.textView];
    self.view.backgroundColor = [UIColor orangeColor];
    self.title = @"RunLoop和Runtime";
    
//    NSRunLoop *runloop;
//    CFRunLoopRef runloop2;
    
//    runloops[thread] = runloop;
    
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//    CFRunLoopRef runloop2 = CFRunLoopGetCurrent();
    
//    NSArray *array;
//    CFArrayRef arry2;
//
//    NSString *string;
//    CFStringRef string2;
    
//    NSLog(@"%p %p", [NSRunLoop currentRunLoop], [NSRunLoop mainRunLoop]);
//    NSLog(@"%p %p", CFRunLoopGetCurrent(), CFRunLoopGetMain());
    
    // 有序的
//    NSMutableArray *array;
//    [array addObject:@"123"];
//    array[0];
    
    // 无序的
//    NSMutableSet *set;
//    [set addObject:@"123"];
//    [set anyObject];
//
//    kCFRunLoopDefaultMode;
//    NSDefaultRunLoopMode;
//    NSLog(@"%@", [NSRunLoop mainRunLoop]);

    
    // kCFRunLoopCommonModes默认包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
    self.wilson_queue = dispatch_queue_create("wilson_queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.wilson_queue, ^{
        NSLog(@"当前线程--> %@", [NSThread currentThread]);
        // 创建Observer 1
        __observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
        
        // 创建 block 的Observer
//        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//            switch (activity) {
//                case kCFRunLoopEntry: {
//                    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
//                    NSLog(@"kCFRunLoopEntry - %@", mode);
//                    CFRelease(mode);
//                    break;
//                }
//
//                case kCFRunLoopExit: {
//                    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
//                    NSLog(@"kCFRunLoopExit - %@", mode);
//                    CFRelease(mode);
//                    break;
//                }
//
//                default:
//                    break;
//            }
//        });
        // 添加Observer到RunLoop中
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), __observer, kCFRunLoopCommonModes);
        // 释放
        CFRelease(__observer);
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    dispatch_async(self.wilson_queue, ^{
        self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        // NSMachPort 相当于是添加 sources1事件
//        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

        // 任务完成，runloop退出
        NSLog(@"currentRunLoop ---> 退出 --> %@",[NSRunLoop currentRunLoop]);
    });
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

#pragma mark - Getter

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 150, 200)];
    }
    return _textView;
}

@end
