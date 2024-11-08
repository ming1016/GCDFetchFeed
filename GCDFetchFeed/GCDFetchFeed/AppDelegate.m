//
//  AppDelegate.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/19.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "AppDelegate.h"

#import "SMRootViewController.h"
#import "SMFeedListViewController.h"
#import "SMStyle.h"
#import "SMFeedModel.h"
#import "SMLagMonitor.h"
#import "SMCallTraceDemo.h"

#import <dlfcn.h>
#import <MetricKit/MetricKit.h>
#import "AppLaunchTime.h"
#import "SMCallTrace.h"

@interface AppDelegate ()
@property (nonatomic, assign) os_log_t log;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [SMCallTrace start];
    self.log = [AppLaunchTime creatWithBundleId:"com.starming.log" key:"launch"]; // 渲染时间
    [AppLaunchTime beginTime:self.log];
    // 监测方法耗时，需要时打开注释
//    [SMCallTraceDemo test];
    
    //这里是做卡顿监测
//    [[SMLagMonitor shareInstance] beginMonitor];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //首页
    SMRootViewController *rootVC = [[SMRootViewController alloc] init];
    UINavigationController *homeNav = [self styleNavigationControllerWithRootController:rootVC];
    self.window.rootViewController = homeNav;
    [self.window makeKeyAndVisible];
    return YES;
}

// 渲染完成
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [AppLaunchTime mark]; // 进程启动开始，到渲染完成的时间
    [AppLaunchTime endTime:self.log];
    [AppLaunchTime stopMonitoring];
//    [SMCallTrace stop];
//    [SMCallTrace save];
}

- (UINavigationController *)styleNavigationControllerWithRootController:(UIViewController *)vc {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.backgroundColor = [SMStyle colorPaperLight];
    UIView *shaowLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(nav.navigationBar.frame), CGRectGetWidth(nav.navigationBar.frame), 0.5)];
    shaowLine.backgroundColor = [UIColor colorWithHexString:@"D8D7D3"];
    [nav.navigationBar addSubview:shaowLine];
    nav.navigationBar.translucent = NO;
    return nav;
}

// MARK: - 代码覆盖回调函数
//void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
//                                         uint32_t *stop) {
//    static uint64_t N;
//    if (start == stop || *start) return;
//    printf("INIT: %p %p\n", start, stop);
//    for (uint32_t *x = start; x < stop; x++)
//        *x = ++N;
//}
//
//void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return;
//    void *PC = __builtin_return_address(0);
//    Dl_info info;
//    dladdr(PC, &info);
//    printf("调用了方法: %s \n", info.dli_sname);
//}

@end
