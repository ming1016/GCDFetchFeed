//
//  AppLaunchTime.h
//  GCDFetchFeed
//
//  Created by Ming on 2024/11/7.
//  Copyright © 2024 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <os/signpost.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppLaunchTime : NSObject

+ (void)mark;

+ (os_log_t)creatWithBundleId:(const char *)bundleId key:(const char *)key;
+ (void)beginTime:(os_log_t)logger;
+ (void)endTime:(os_log_t)logger;

+ (void)startMonitoring;
+ (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
