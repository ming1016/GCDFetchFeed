//
//  SMCallStackModel.h
//  GCDFetchFeed
//
//  Created by DaiMing on 2017/8/18.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMCallStackModel : NSObject

@property (nonatomic, copy) NSString *stackStr;       //完整堆栈信息
@property (nonatomic) BOOL isStuck;                   //是否被卡住
@property (nonatomic, assign) NSTimeInterval dateString;   //可展示信息

@end
