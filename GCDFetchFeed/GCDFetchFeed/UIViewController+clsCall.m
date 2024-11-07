//
//  UIViewController+clsCall.m
//  GCDFetchFeed
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "UIViewController+clsCall.h"
#import "DCHook.h"
#import <objc/runtime.h>
#import "SMCallTrace.h"

@implementation UIViewController (clsCall)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //
        SEL fromSelectorAppear = @selector(viewWillAppear:);
        SEL toSelectorAppear = @selector(clsCallHookViewWillAppear:);
        [DCHook hookClass:self fromSelector:fromSelectorAppear toSelector:toSelectorAppear];
        
        SEL fromSelectorDisappear = @selector(viewWillDisappear:);
        SEL toSelectorDisappear = @selector(clsCallHookViewWillDisappear:);
        
        [DCHook hookClass:self fromSelector:fromSelectorDisappear toSelector:toSelectorDisappear];
    });
}

#pragma mark - Method Hook
- (void)clsCallHookViewWillAppear:(BOOL)animated {
    //执行插入代码
//    [self clsCallInsertToViewWillAppear]; // 检测页面载入时间，需要时打开注释
    [self clsCallHookViewWillAppear:animated];
}
- (void)clsCallHookViewWillDisappear:(BOOL)animated {
    //执行插入代码
//    [self clsCallInsertToViewWillDisappear]; // 检测页面载入时间，需要时打开注释
    [self clsCallHookViewWillDisappear:animated];
}

- (void)clsCallInsertToViewWillAppear {
    //显示
    [SMCallTrace startWithMaxDepth:0];
}
- (void)clsCallInsertToViewWillDisappear {
    //消失
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [SMCallTrace stopSaveAndClean];
    });
    
}
@end
