//
//  CViewController.m
//  TEST
//
//  Created by Wilson on 2020/3/18.
//  Copyright © 2020 Wilson. All rights reserved.
//

#import "CViewController.h"
#import "objc/runtime.h"
#import "Person.h"
#import "CustomButton.h"
#import "FVC.h"

@interface CViewController ()

@property(nonatomic, copy) void (^block)(void);
@property(nonatomic, copy) NSString *strCopy;
@property(nonatomic, strong) NSString *strStrong;
@property(strong, nonatomic) Person *p1;
@property (nonatomic, strong) CustomButton *customBtn;
@property (nonatomic, strong) NSMutableArray *testBlockArray;

@end

@implementation CViewController

- (void)dealloc {
    NSLog(@"%@ --> release", [self class]);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.p1.observationInfo) {
        [self.p1 removeObserver:self forKeyPath:@"name"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor yellowColor];
    self.customBtn = [[CustomButton alloc] initWithFrame:CGRectMake(20, 100, 200, 200)];
    [self.customBtn addTarget:self action:@selector(clickCustomBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customBtn];
    UIBarButtonItem *noti = [[UIBarButtonItem alloc] initWithTitle:@"发送通知" style:UIBarButtonItemStylePlain target:self action:@selector(clickSend)];
    UIBarButtonItem *showFVC = [[UIBarButtonItem alloc] initWithTitle:@"显示FVC" style:UIBarButtonItemStylePlain target:self action:@selector(clickFVC)];
    self.navigationItem.rightBarButtonItems = @[noti, showFVC];
    
    [self testSemaphore];
//    [self testMethodKVO];
//    [self testTagedPointer];
//    [self testRunLoop];
//    [self testBlock];
//    [self testGCD];
}

- (void)testSemaphore {
    //使用GCD的信号量 dispatch_semaphore_t 结合 dispatch_group_async 创建同步请求，控制请求顺序等操作
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, globalQueue, ^{
        dispatch_semaphore_t semaphoreA = dispatch_semaphore_create(0);
        
        //模拟网络多线程耗时操作
        dispatch_group_async(group, globalQueue, ^{
            sleep(3);
            NSLog(@"模拟网络请求%@---block1结束。。。",[NSThread currentThread]);
            dispatch_semaphore_signal(semaphoreA);
        });
        NSLog(@"%@---1结束。。。",[NSThread currentThread]);
        dispatch_semaphore_wait(semaphoreA, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, globalQueue, ^{
        dispatch_semaphore_t semaphoreB = dispatch_semaphore_create(0);
        
        //模拟网络多线程耗时操作
        dispatch_group_async(group, globalQueue, ^{
            sleep(5);
            NSLog(@"模拟网络请求%@---block2结束。。。",[NSThread currentThread]);
            dispatch_semaphore_signal(semaphoreB);
        });
        
        NSLog(@"%@---2结束。。。",[NSThread currentThread]);
        dispatch_semaphore_wait(semaphoreB, DISPATCH_TIME_FOREVER);
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"全部任务完成结束--%@",[NSThread currentThread]);
    });
}

- (void)clickSend {
    // 在子线程中发送通知
    dispatch_queue_t subQueue = dispatch_queue_create("com.wilson", DISPATCH_QUEUE_SERIAL);
    dispatch_async(subQueue, ^{
        NSLog(@"当前线程为：%@",[NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CViewControllerPost" object:nil userInfo:nil];
    });
}

- (void)clickFVC {
    FVC *vc = [[FVC alloc] init];
    
    __weak typeof(self)weakSelf = self;
    vc.block = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"执行回调");
        [strongSelf blockInvoke];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)blockInvoke {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"block回调延时任务执行");
    });
}

- (void)clickCustomBtn {
    NSLog(@"自定义按钮，测试事件响应者链条关系");
}

- (void)testAutoReleasePool {
    for(int i = 0; i<1000;i++){
        NSString *string = @"Abc";
        string = [string lowercaseString];
        string = [string stringByAppendingString:@"xyz"];
        NSLog(@"%@",string);
    }
}

- (void)testArray {
    NSMutableArray *old = [@[@"1",@"2",@"3"] mutableCopy];
    NSArray *new = old;
    old[0] = @"0";
    NSLog(@"%@--%@",old,new);
}

- (void)testBlock {
    //block的内部结构
    self.testBlockArray = [@[@"name"] mutableCopy];
    __weak typeof(self) weakSelf = self;
    
    self.block = ^{
        [weakSelf.testBlockArray addObject:@"age"];
    };
    self.block();
    NSLog(@"array=%@",self.testBlockArray);
}

- (void)testCopyString {
    //数据源是不可变字符串
    NSString *a = @"origin";
    self.strCopy = a;
    self.strStrong = a;
    NSLog(@"a = %@，地址= %p",a,a);
    a = @"newa";
    NSLog(@"值改变后 a = %@，地址= %p",a,a);
    NSLog(@"copy = %@，地址= %p",self.strCopy,self.strCopy);
    NSLog(@"strong = %@，地址= %p \n",self.strStrong,self.strStrong);
    //数据源是可变字符串
    NSMutableString *b = [@"originB" mutableCopy];
    self.strCopy = b;
    self.strStrong = b;
    NSLog(@"b = %@，地址= %p",b,b);
    [b appendString:@"+new"];
    NSLog(@"值改变后 b = %@，地址= %p",b,b);
    NSLog(@"copy = %@，地址= %p",self.strCopy,self.strCopy);
    NSLog(@"strong = %@，地址= %p",self.strStrong,self.strStrong);
    /*
     1 copy操作会把可变字符串重新变为不可变，但编译期不会检查到，运行期若执行了可变字符串操作，会奔溃
     2 使用(nonatomic copy)属性修饰，赋值给不可变字符串时，会执行深拷贝
     */
}

- (void)testCopyArray {
    NSString *a = @"abc";
    NSString *b = [a copy];
    NSMutableString *c = [a mutableCopy];
    NSMutableString *d = [a copy];
    NSString *k = @"abc";
    
    BOOL equalAB = a==b;
    BOOL equalAC = a==c;
    BOOL equalAD = a==d;
    BOOL equalAK = a==k;
    BOOL AB = [a isEqual:b];
    BOOL AC = [a isEqual:c];
    
    NSLog(@"a==b：%d",equalAB);
    NSLog(@"a==c：%d",equalAC);
    NSLog(@"a==d：%d",equalAD);
    NSLog(@"a==k：%d",equalAK);
    NSLog(@"a isEqual:b：%d",AB);
    NSLog(@"a isEqual:c： %d",AC);
    /*
     1 在iOS中，==是比较内存地址，isEqual比较值是否相同;
     2 执行copy命令，都会变为不可变对象，都为浅拷贝，内存地址并没有发生变化
     */
}

- (void)testMethodKVO {
    self.p1 = [[Person alloc] init];
    Person *p2 = [[Person alloc] init];
   
    id cls1 = object_getClass(self.p1);
    id cls2 = object_getClass(p2);
    NSLog(@"添加 KVO 之前: cls1 = %@  cls2 = %@ ",cls1,cls2);
   
    [self.p1 addObserver:self forKeyPath:@"gender" options:NSKeyValueObservingOptionNew context:NULL];
    [self.p1 addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    
    // KVO在注册观察者时会以被观察者为 父类 生成一个中间类
    cls1 = object_getClass(self.p1);
    cls2 = object_getClass(p2);
    NSLog(@"添加 KVO 之后: cls1 = %@  cls2 = %@",cls1,cls2);
   
    [self printPersonMethods:cls1];
    [self printPersonMethods:cls2];
    
    self.p1 -> height;
    //属性值改变时，自动触发kvo
//    self.p1.name = @"jack";
    //手动触发kvo
    [self.p1 willChangeValueForKey:@"name"];
    [self.p1 didChangeValueForKey:@"name"];
}

- (void)printPersonMethods:(id)obj {
    unsigned int count = 0;
    Method *methods = class_copyMethodList([obj class], &count);
    NSMutableArray *arrayMethods = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        [arrayMethods addObject:NSStringFromSelector(sel)];
    }
    free(methods);
    NSLog(@"arrayMethods: %@", arrayMethods);
    
    Ivar *ivars = class_copyIvarList([obj class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = ivars[i];
        NSLog(@"arrayIvars: %s", ivar_getName(var));
    }
    free(ivars);
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"触发了kvo");
    }
}

- (void)testTagedPointer {
    NSString *a = @"a";
    NSNumber *num1 = @24;
    NSNumber *num2 = @8;
    
    NSLog(@"测试Taged_Pointer \n a = %p; num1 = %p, num2 = %p, person = %p",a,num1,num2, self.p1);
}

- (void)testRunLoop {
//    NSLog(@"打印主线程的RunLoop：\n %@", [NSRunLoop mainRunLoop]);
}

- (void)testGCD {
    NSLog(@"1");

    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });

    NSLog(@"5");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"GCD当前线程--> %@", [NSThread currentThread]);
        NSLog(@"6");
        // afterDelay 函数本质是在RunLoop中添加Timer执行
        [self performSelector:@selector(asyncSelectorMethod) withObject:nil afterDelay:0];
        NSLog(@"8");
    });
    NSLog(@"9");
}

- (void)asyncSelectorMethod {
    NSLog(@"7");
}

@end
