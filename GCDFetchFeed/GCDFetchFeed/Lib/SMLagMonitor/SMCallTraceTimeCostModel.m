//
//  SMCallTraceTimeCostModel.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/7/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMCallTraceTimeCostModel.h"

@implementation SMCallTraceTimeCostModel

- (NSString *)des {
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"%2d| ",(int)_callDepth];
    [str appendFormat:@"%6.2f|",_timeCost * 1000.0];
    for (NSUInteger i = 0; i < _callDepth; i++) {
        [str appendString:@"  "];
    }
    [str appendFormat:@"%s[%@ %@]", (_isClassMethod ? "+" : "-"), _className, _methodName];
    return str;
}

@end
