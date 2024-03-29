//
//  SMCallTrace.m
//  HomePageTest
//
//  Created by DaiMing on 2017/7/8.
//  Copyright © 2017年 DiDi. All rights reserved.
//

#import "SMCallTrace.h"
#import "SMCallLib.h"
#import "SMCallTraceTimeCostModel.h"
#import "SMLagDB.h"


@implementation SMCallTrace

#pragma mark - Trace
#pragma mark - OC Interface
+ (void)start {
    smCallTraceStart();
}
+ (void)startWithMaxDepth:(int)depth {
    smCallConfigMaxDepth(depth);
    [SMCallTrace start];
}
+ (void)startWithMinCost:(double)ms {
    smCallConfigMinTime(ms * 1000);
    [SMCallTrace start];
}
+ (void)startWithMaxDepth:(int)depth minCost:(double)ms {
    smCallConfigMaxDepth(depth);
    smCallConfigMinTime(ms * 1000);
    [SMCallTrace start];
}
+ (void)stop {
    smCallTraceStop();
}
+ (void)save {
    NSMutableString *mStr = [NSMutableString new];
    NSArray<SMCallTraceTimeCostModel *> *arr = [self loadRecords];
    for (SMCallTraceTimeCostModel *model in arr) {
        //记录方法路径
        model.path = [NSString stringWithFormat:@"[%@ %@]",model.className,model.methodName];
        [self appendRecord:model to:mStr];
    }
    NSLog(@"\n%@",mStr);
}
+ (void)stopSaveAndClean {
    [SMCallTrace stop];
    [SMCallTrace save];
    smClearCallRecords();
}
+ (void)appendRecord:(SMCallTraceTimeCostModel *)cost to:(NSMutableString *)mStr {
    if (cost.callDepth == 0) {
        [mStr appendFormat:@"\n"];
    }
    [mStr appendFormat:@"%@\n", [cost des]];
//    [mStr appendFormat:@"%@\n path%@\n",[cost des],cost.path];
    if (cost.subCosts.count < 1) {
        cost.lastCall = YES;
        //记录到数据库中
        [[SMLagDB shareInstance] addWithClsCallModel:cost];
    } else {
        for (SMCallTraceTimeCostModel *model in cost.subCosts) {
            if ([model.className isEqualToString:@"SMCallTrace"]) {
                break;
            }
            //记录方法的子方法的路径
            model.path = [NSString stringWithFormat:@"%@ - [%@ %@]",cost.path,model.className,model.methodName];
            [self appendRecord:model to:mStr];
        }
    }
    
}
+ (NSArray<SMCallTraceTimeCostModel *>*)loadRecords {
    NSMutableArray<SMCallTraceTimeCostModel *> *arr = [NSMutableArray new];
    int num = 0;
    smCallRecord *records = smGetCallRecords(&num);
    for (int i = 0; i < num; i++) {
        smCallRecord *rd = &records[i];
        SMCallTraceTimeCostModel *model = [SMCallTraceTimeCostModel new];
        model.className = NSStringFromClass(rd->cls);
        model.methodName = NSStringFromSelector(rd->sel);
        model.isClassMethod = class_isMetaClass(rd->cls);
        model.timeCost = (double)rd->time / 1000000.0;
        model.callDepth = rd->depth;
        model.lr = rd->lr;
        
        if (rd->caller_record != NULL) {
            model.callerLr = rd->caller_record->lr;
        }

        [arr addObject:model];
    }
    NSUInteger count = arr.count;
    for (NSUInteger i = 0; i < count; i++) {
        SMCallTraceTimeCostModel *model = arr[i];
        if (model.callDepth > 0) {
            [arr removeObjectAtIndex:i];
            //Todo:不需要循环，直接设置下一个，然后判断好边界就行
            for (NSUInteger j = i; j < count - 1; j++) {
                // 下一个深度小的话就开始将后面的递归的往 sub array 里添加
                // ⚠️⚠️ 这里的bug：不能根据 callDepth 来判断，不然所有层级相等的深度，都在一个调用链路中了
                // 需要根据调用链路来关联
                if (arr[j].lr == model.callerLr) {
                    NSMutableArray *sub = (NSMutableArray *)arr[j].subCosts;
                    if (!sub) {
                        sub = [NSMutableArray new];
                        arr[j].subCosts = sub;
                    }
                    if (![sub containsObject:model]) {
                        [sub addObject:model];
                    }
                }
            }
            i--;
            count--;
        }
    }
    return arr;
}


@end
