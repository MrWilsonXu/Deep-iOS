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

@interface CViewController ()

@property(copy, nonatomic) void (^block)(void);
@property(nonatomic, copy) NSString *strCopy;
@property(nonatomic, strong) NSString *strStrong;
@property(strong, nonatomic) Person *p1;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送通知" style:UIBarButtonItemStylePlain target:self action:@selector(clickSend)];
//    [self testSemaphore];
    [self testMethodKVO];
}

- (void)testSemaphore {
    // 创建信号量，可以控制最大并发量，如设置为x，则最大并发为x
    dispatch_semaphore_t sem = dispatch_semaphore_create(5);
    dispatch_queue_t queue = dispatch_queue_create("Wilson", DISPATCH_QUEUE_CONCURRENT);
    
    //同时执行100个任务
     for (int i = 0; i < 100; i++) {
        dispatch_async(queue, ^{
            //当前信号量-1
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    
            NSLog(@"任务%d执行",i+1);
                    
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1721232-1ba01fe953f04eee.png"]];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"执行刷新页面%@",data);
            });
                    
            //当前信号量+1
            dispatch_semaphore_signal(sem);
        });
    }
}

- (void)clickSend {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CViewControllerPost" object:nil userInfo:nil];
    [self testSemaphore];
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
    NSMutableArray *array = [@[@"name"] mutableCopy];
    self.block = ^{
        [array addObject:@"age"];
    };
    self.block();
    NSLog(@"array=%@",array);
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

@end