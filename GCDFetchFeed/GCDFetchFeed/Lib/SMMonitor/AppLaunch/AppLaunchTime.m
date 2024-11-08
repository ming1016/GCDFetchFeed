//
//  AppLaunchTime.m
//  GCDFetchFeed
//
//  Created by Ming on 2024/11/7.
//  Copyright © 2024 Starming. All rights reserved.
//

#import "AppLaunchTime.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

#import <objc/runtime.h>
#import <dlfcn.h>
#import <QuartzCore/QuartzCore.h>

@implementation AppLaunchTime

// MARK: - 获取 +load 方法的执行时间
//// 保存原始的 +load 实现
//static void (*original_load)(Class, SEL);
//
//// 记录类和执行时间
//static NSMutableDictionary *loadTimings;
//
//// 包装后的 +load 实现
//void wrapped_load(Class cls, SEL sel) {
//    CFTimeInterval start = CACurrentMediaTime();
//    
//    // 调用原始的 +load 方法
//    if (original_load) {
//        original_load(cls, sel);
//    }
//    
//    CFTimeInterval end = CACurrentMediaTime();
//    CFTimeInterval duration = end - start;
//    
//    // 记录耗时
//    if (loadTimings && cls) {
//        @synchronized(loadTimings) {
//            loadTimings[NSStringFromClass(cls)] = @(duration);
//        }
//    }
//}
//
//__attribute__((constructor))
//static void initializeLoadTimeTracking(void) {
//    loadTimings = [NSMutableDictionary dictionary];
//    
//    // 获取所有已注册的类
//    unsigned int count = 0;
//    Class *classes = objc_copyClassList(&count);
//    
//    for (unsigned int i = 0; i < count; i++) {
//        Class cls = classes[i];
//        Method m = class_getClassMethod(cls, @selector(load));
//        if (m) {
//            // 保存原始实现
//            original_load = (void *)method_getImplementation(m);
//            // 替换为包装后的实现
//            method_setImplementation(m, (IMP)wrapped_load);
//        }
//    }
//    
//    free(classes);
//    
//    // 注册一个回调在所有 +load 方法执行完后输出统计结果
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSArray *sortedClasses = [loadTimings keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *t1, NSNumber *t2) {
//            return [t2 compare:t1];
//        }];
//        
//        NSLog(@"=== +load Methods Execution Time ===");
//        for (NSString *className in sortedClasses) {
//            NSLog(@"%@: %.4f ms", className, [loadTimings[className] doubleValue] * 1000);
//        }
//    });
//}

// MARK: - 获取 Pre-main 阶段的时间以及整个启动时间
double timeProcess;
double timeBeforeMain;
double timeDidFinsh;


// 通过调用 sysctl 函数获取进程信息，并从中提取进程的启动时间。
+ (CFAbsoluteTime)processStartTime {
    if (timeProcess == 0) {
        struct kinfo_proc procInfo;
        int pid = [[NSProcessInfo processInfo] processIdentifier];
        int cmd[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
        size_t size = sizeof(procInfo);
        if (sysctl(cmd, sizeof(cmd)/sizeof(*cmd), &procInfo, &size, NULL, 0) == 0) {
            timeProcess = procInfo.kp_proc.p_un.__p_starttime.tv_sec * 1000.0 + procInfo.kp_proc.p_un.__p_starttime.tv_usec / 1000.0;
        }
    }
    return timeProcess;
}

// 用于记录应用程序完成启动的时间，并计算和打印启动的各个阶段的时间。
+ (void)mark {
    double timeProcess =  [AppLaunchTime processStartTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timeDidFinsh == 0) {
            timeDidFinsh = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
        }
        
        double pret = timeBeforeMain - timeProcess / 1000;
        double didfinish = timeDidFinsh - timeBeforeMain;
        double total = timeDidFinsh - timeProcess / 1000;
        
        NSLog(@"pre-main:%f",pret);
        NSLog(@"post-main:%f",didfinish);
        NSLog(@"total:%f",total);
    });
}

// 该函数会在 main 函数之前执行
void static __attribute__((constructor)) before_main(void) {
    if (timeBeforeMain == 0) {
        timeBeforeMain = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    }
}


// MARK: - 使用 os_signnpost 函数记录启动时间
+ (os_log_t)creatWithBundleId:(const char *)bundleId key:(const char *)key {
   return os_log_create(bundleId, key);
}

+ (void)beginTime:(os_log_t)logger {
    os_signpost_id_t signPostId = os_signpost_id_make_with_pointer(logger,sin);
    os_signpost_interval_begin(logger, signPostId, "LaunchTime","%{public}s","");
    os_signpost_interval_end(logger, signPostId, "LaunchTime");
}

+ (void)endTime:(os_log_t)logger {
    os_signpost_id_t signPostId = os_signpost_id_make_with_pointer(logger,sin);
    os_signpost_interval_end(logger, signPostId, "LaunchTime");
}

// MARK: - 编码监测。手动记录启动时间
static CFAbsoluteTime startTime;

+ (void)startMonitoring {
    startTime = CFAbsoluteTimeGetCurrent();
}

+ (void)stopMonitoring {
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"post-main: %f sec", endTime - startTime);
}

@end
