//
//  SMCallTrace.h
//  HomePageTest
//
//  Created by DaiMing on 2017/7/8.
//  Copyright © 2017年 DiDi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMCallTraceCore.h"


@interface SMCallTrace : NSObject
+ (void)start; //开始记录
+ (void)startWithMaxDepth:(int)depth;
+ (void)startWithMinCost:(double)ms;
+ (void)startWithMaxDepth:(int)depth minCost:(double)ms;
+ (void)stop; //停止记录
+ (void)save; //保存和打印记录，如果不是短时间 stop 的话使用 saveAndClean
+ (void)stopSaveAndClean; //停止保存打印并进行内存清理
//int smRebindSymbols(struct smRebinding rebindings[], size_t rebindings_nel);

@end
