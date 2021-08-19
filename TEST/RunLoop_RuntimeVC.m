//
//  RunLoop和RuntimeVC.m
//  TEST
//
//  Created by Wilson on 2021/8/19.
//  Copyright © 2021 Wilson. All rights reserved.
//

#import "RunLoop_RuntimeVC.h"

@interface RunLoop_RuntimeVC ()

@end

@implementation RunLoop_RuntimeVC

NSMutableDictionary *runloops;

void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
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
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

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

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"当前线程--> %@", [NSThread currentThread]);
        // 创建Observer
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
        
        // 创建 block 的Observer
    //    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
    //        switch (activity) {
    //            case kCFRunLoopEntry: {
    //                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
    //                NSLog(@"kCFRunLoopEntry - %@", mode);
    //                CFRelease(mode);
    //                break;
    //            }
    //
    //            case kCFRunLoopExit: {
    //                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
    //                NSLog(@"kCFRunLoopExit - %@", mode);
    //                CFRelease(mode);
    //                break;
    //            }
    //
    //            default:
    //                break;
    //        }
    //    });
        // 添加Observer到RunLoop中
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        // 释放
        CFRelease(observer);
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"定时器-----------");
    }];
}


@end
