//
//  SMCallStack.h
//
//  Created by DaiMing on 2017/6/22.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMCallLib.h"

typedef NS_ENUM(NSUInteger, SMCallStackType) {
    SMCallStackTypeAll,     //全部线程
    SMCallStackTypeMain,    //主线程
    SMCallStackTypeCurrent  //当前线程
};



@interface SMCallStack : NSObject

+ (NSString *)callStackWithType:(SMCallStackType)type;

extern NSString *smStackOfThread(thread_t thread);

@end
