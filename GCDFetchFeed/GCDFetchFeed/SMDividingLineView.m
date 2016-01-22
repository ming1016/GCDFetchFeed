//
//  SMDividingLineView.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMDividingLineView.h"

@implementation SMDividingLineView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [SMStyle colorGrayLight];
    }
    return self;
}

+ (CGFloat)defaultSize {
    return 0.5;
}

@end
